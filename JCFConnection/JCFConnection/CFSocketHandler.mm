//
//  CFSocketHandler.cpp
//  JCFConnection
//
//  Created by Liang Jin on 10/12/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "CFSocketHandler.h"
#include "RequestUtil.h"
#include "CFSocketHandlerClient.h"

extern "C" const CFStringRef _kCFStreamSocketSetNoDelay;

namespace J
{
    CFSocketHandler::CFSocketHandler(CFSocketHandlerClient* aClient)
    :m_retainCount(1)
    ,m_client(aClient)
    ,m_readStream(NULL)
    ,m_writeStream(NULL)
    ,m_connectingSubstate(New)
    ,m_state(Connecting)
    ,m_requestBuffer(NULL)
    {
        assert(m_client);
    }
    
    CFSocketHandler::~CFSocketHandler()
    {
        close();
    }
    
    void CFSocketHandler::start()
    {
        createStreams();
        scheduleStreams();
    }
    
    void CFSocketHandler::cancel()
    {
        retain();
        close();
        m_state = Closed;
        release();
    }
    
    void CFSocketHandler::createStreams()
    {
        assert(m_state == Connecting);
        CFStringRef host = m_client->host();
        UInt32 port = m_client->port();
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &m_readStream, &m_writeStream);
        
        CFWriteStreamSetProperty(m_writeStream, _kCFStreamSocketSetNoDelay, kCFBooleanTrue);
    }

    void CFSocketHandler::scheduleStreams()
    {
        assert(m_readStream);
        assert(m_writeStream);
        
        CFStreamClientContext clientContext = { 0, this, retainConnectionCore, releaseConnectionCore, copyCFStreamDescription };
        // FIXME: Pass specific events we're interested in instead of -1.
        CFReadStreamSetClient(m_readStream, static_cast<CFOptionFlags>(-1), readStreamCallback, &clientContext);
        CFWriteStreamSetClient(m_writeStream, static_cast<CFOptionFlags>(-1), writeStreamCallback, &clientContext);

        CFRunLoopRef runloop = CFRunLoopGetCurrent();
        CFReadStreamScheduleWithRunLoop(m_readStream, runloop, kCFRunLoopCommonModes);
        CFWriteStreamScheduleWithRunLoop(m_writeStream, runloop, kCFRunLoopCommonModes);
        
        CFReadStreamOpen(m_readStream);
        CFWriteStreamOpen(m_writeStream);
        
        m_connectingSubstate = WaitingForConnect;
    }
    
#pragma mark - callback from stream
    
    void* CFSocketHandler::retainConnectionCore(void* info)
    {
        CFSocketHandler* core = static_cast<CFSocketHandler*>(info);
        core->retain();
        return core;
    }
    void CFSocketHandler::releaseConnectionCore(void* info)
    {
        CFSocketHandler* core = static_cast<CFSocketHandler*>(info);
        core->release();
    }
    CFStringRef CFSocketHandler::copyCFStreamDescription(void* info)
    {
        CFSocketHandler* core = static_cast<CFSocketHandler*>(info);
        return (CFStringRef)[NSString stringWithFormat:@"JCF connect %@:%d", core->m_client->host(),(int)core->m_client->port()];
    }
    void CFSocketHandler::readStreamCallback(CFReadStreamRef stream, CFStreamEventType type, void* clientCallBackInfo)
    {
        CFSocketHandler* core = static_cast<CFSocketHandler*>(clientCallBackInfo);
        core->readStreamCallback(type);

    }
    void CFSocketHandler::writeStreamCallback(CFWriteStreamRef stream, CFStreamEventType type, void* clientCallBackInfo)
    {
        CFSocketHandler* core = static_cast<CFSocketHandler*>(clientCallBackInfo);
        core->writeStreamCallback(type);
    }
    
#pragma mark - for deal with connection
    void CFSocketHandler::readStreamCallback(CFStreamEventType type)
    {
        switch(type)
        {
            case kCFStreamEventNone:
                return;
            case kCFStreamEventOpenCompleted:
                return;
            case kCFStreamEventHasBytesAvailable:
            {
                if (m_connectingSubstate == WaitingForCredentials)
                    return;
                
                if (m_connectingSubstate == WaitingForConnect)
                {
#if 0
                    if (m_connectionType == CONNECTProxy) {
                        RetainPtr<CFHTTPMessageRef> proxyResponse = adoptCF(wkCopyCONNECTProxyResponse(m_readStream.get(), m_httpsURL.get(), m_proxyHost.get(), m_proxyPort.get()));
                        if (!proxyResponse)
                            return;
                        
                        CFIndex proxyResponseCode = CFHTTPMessageGetResponseStatusCode(proxyResponse.get());
                        switch (proxyResponseCode) {
                            case 200:
                                // Successful connection.
                                break;
                            case 407:
                                addCONNECTCredentials(proxyResponse.get());
                                return;
                            default:
                                m_client->didFailSocketStream(this, SocketStreamError(static_cast<int>(proxyResponseCode), m_url.string(), "Proxy connection could not be established, unexpected response code"));
                                platformClose();
                                return;
                        }
                    }
#endif
                    m_connectingSubstate = Connected;
                    m_state = Open;
                    m_client->didOpenSocketStream(this);
                }
                
                // Not an "else if", we could have made a client call above, and it could close the connection.
                if (m_state == Closed)
                    return;
                
                assert(m_state == Open);
                assert(m_connectingSubstate == Connected);
                

                UInt8* localBuffer = (UInt8*)malloc(2048);
                int length = CFReadStreamRead(m_readStream, localBuffer, 2048);
                if (length > 0)
                {
                    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)localBuffer, length, kCFAllocatorMalloc);
                    m_client->didReceiveSocketStreamData(this, data);
                    CFRelease(data);
                }
                else
                {
                    free(localBuffer);
                }
                
                return;
            }
            case kCFStreamEventCanAcceptBytes:
                assert(0);
                return;
            case kCFStreamEventErrorOccurred:
            {
                CFErrorRef error = CFWriteStreamCopyError(m_writeStream);
                reportErrorToClient(error);
                CFRelease(error);
                return;
            }
            case kCFStreamEventEndEncountered:
                close();
                return;
            default:
                assert(0);
                break;
        }

    }
    void CFSocketHandler::writeStreamCallback(CFStreamEventType type)
    {
        switch(type)
        {
            case kCFStreamEventNone:
                return;
            case kCFStreamEventOpenCompleted:
                return;
            case kCFStreamEventHasBytesAvailable:
                assert(0);
                return;
            case kCFStreamEventCanAcceptBytes:
            {
                // Can be false if read stream callback just decided to retry a CONNECT with credentials.
                if (!CFWriteStreamCanAcceptBytes(m_writeStream))
                    return;

                if (m_connectingSubstate == WaitingForCredentials)
                    return;
                
                if (m_connectingSubstate == WaitingForConnect)
                {
#if 0
                    if (m_connectionType == CONNECTProxy) {
                        RetainPtr<CFHTTPMessageRef> proxyResponse = adoptCF(wkCopyCONNECTProxyResponse(m_readStream.get(), m_httpsURL.get(), m_proxyHost.get(), m_proxyPort.get()));
                        if (!proxyResponse)
                            return;
                        
                        // Don't write anything until read stream callback has dealt with CONNECT credentials.
                        // The order of callbacks is not defined, so this can be called before readStreamCallback's kCFStreamEventHasBytesAvailable.
                        CFIndex proxyResponseCode = CFHTTPMessageGetResponseStatusCode(proxyResponse.get());
                        if (proxyResponseCode != 200)
                            return;
                    }
#endif
                    ///FIXME:may crash here,m_client has been release
                    m_connectingSubstate = Connected;
                    m_state = Open;
                    m_client->didOpenSocketStream(this);
                }

                // Not an "else if", we could have made a client call above, and it could close the connection.
                if (m_state == Closed)
                    return;

                assert(m_state == Open);
                assert(m_connectingSubstate == Connected);

                sendPendingData();
                return;
            }
            case kCFStreamEventErrorOccurred:
            {
                CFErrorRef error = CFWriteStreamCopyError(m_writeStream);
                reportErrorToClient(error);
                CFRelease(error);
                return;
            }
            case kCFStreamEventEndEncountered:
                // FIXME: Currently, we handle closing in read callback, but these can come independently (e.g. a server can stop listening, but keep sending data).
                return;
        }
    }
    void CFSocketHandler::reportErrorToClient(CFErrorRef error)
    {
        m_client->didFailSocketStream(this, error);
    }
    
    void CFSocketHandler::sendPendingData()
    {
        if (!CFWriteStreamCanAcceptBytes(m_writeStream))
        {
            return;
        }
        const UInt8* data = NULL;
        uint length = 0;
        m_client->dataShouldSend(data, length);
        int written = CFWriteStreamWrite(m_writeStream,data,length);
        m_client->dataDidSend(written);
    }
    
    void CFSocketHandler::close()
    {
        if (!m_readStream)
        {
            if (m_connectingSubstate == New )
            {
                m_client->didCloseSocketStream(this);
            }
            return;
        }
        CFRunLoopRef runloop = CFRunLoopGetCurrent();
        CFReadStreamUnscheduleFromRunLoop(m_readStream, runloop, kCFRunLoopCommonModes);
        CFWriteStreamUnscheduleFromRunLoop(m_writeStream, runloop, kCFRunLoopCommonModes);

        CFReadStreamClose(m_readStream);
        CFWriteStreamClose(m_writeStream);
        
        CFRelease(m_readStream);m_readStream = NULL;
        CFRelease(m_writeStream);m_writeStream = NULL;

        m_client->didCloseSocketStream(this);
    }
};