//
//  CFConnectionCore.cpp
//  JCFConnection
//
//  Created by Liang Jin on 10/13/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "CFConnectionCore.h"
#include "RequestUtil.h"
#include "JCFConnection_Internal.h"
#include "CFSocketHandler.h"
#include "CFSocketFactory.h"
#include "ResponseParser.h"
#include "ChunkedStreamDecoder.h"
#include "GzipStreamDecoder.h"
namespace J
{
    CFConnectionCore::CFConnectionCore(NSURLRequest* aRequest
                                       , id<CFConnectionCoreDelegate> aConnection)
    :m_oriRequest([aRequest mutableCopy])
    ,m_curRequest([m_oriRequest retain])
    ,m_sendBuffer(NULL)
    ,m_sendBufferOffset(0)
    ,m_handler(CFSocketFactory::global()->socketWithClient(this))
    ,m_responseParser(NULL)
    ,m_state(EIdle)
    ,m_chunkedStreamDecoder(NULL)
    ,m_gzipStreamDecoder(NULL)
    ,m_receivedDataSize(0)
    {
        setConnection(aConnection);
    }
    CFConnectionCore::~CFConnectionCore()
    {
        if (m_chunkedStreamDecoder) {
            delete m_chunkedStreamDecoder;
        }
        if (m_gzipStreamDecoder) {
            delete m_gzipStreamDecoder;
        }
        freeSocket();
    
        CFRelease(m_oriRequest);m_oriRequest = nil;
        CFRelease(m_curRequest);m_curRequest = nil;
        
        if (m_sendBuffer) {
            CFRelease(m_sendBuffer);
            m_sendBuffer = nil;
        }
        
        if (m_responseParser) {
            delete m_responseParser;
            m_responseParser = NULL;
        }
    }
    
    void CFConnectionCore::start()
    {
        if (EIdle != m_state)
        {
            return;
        }
        
        if ([m_connectionCallBack respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)])
        {
            NSURLRequest* result = [m_connectionCallBack connection:this willSendRequest:m_curRequest redirectResponse:nil];
            if (ECancelByUse == m_state)
            {
                return;
            }
            if (result == NULL)
            {
                cancel();
            }
            else
            {
                if (result != m_curRequest)
                {
                    [m_curRequest release];
                    if ([result isKindOfClass:[NSMutableURLRequest class]])
                    {
                        m_curRequest = [result mutableCopy];
                    }
                    else
                    {
                        m_curRequest = (NSMutableURLRequest*)[result retain];
                    }
                }
                m_handler->start();
            }
        }
        else
        {
            m_handler->start();
        }
        m_state = EWaitingResponse;
    }
    
    void CFConnectionCore::cancel()
    {
        m_state = ECancelByUse;
        m_handler->cancel();
        freeSocket();
        m_connectionCallBack = NULL;
    }
    
    void CFConnectionCore::setConnection(id<CFConnectionCoreDelegate> connection)
    {
        //FIXME: use impl cache
        m_connectionCallBack = connection;
    }

    void CFConnectionCore::didReceiveSocketStreamData(CFSocketHandler* handler, CFDataRef data)
    {
        switch (m_state)
        {
            case EWaitingResponse:
                handleResponseData(data);
                break;
            case EReceivingData:
                handleBodyData(data);
                break;
            default:
                assert(0);
                break;
        }
    }
    
    void CFConnectionCore::handleResponseData(CFDataRef data)
    {
        if (m_responseParser == NULL)
        {
            m_responseParser = new ResponseParser();
        }
        assert(m_responseParser && m_responseParser->state() != ResponseParser::Done);
        if (ResponseParser::WaitForData == m_responseParser->state())
        {
            int restOffSet = m_responseParser->appendDataAndParse(data);
            if (ResponseParser::Done == m_responseParser->state())
            {
                ///FIXME: It may be distory after this,should protect itself
                NSURLResponse* response = m_responseParser->makeResponseWithURL([m_curRequest URL]);
                if (response)
                {
                    //FIXME:should handle redirect
                    [m_connectionCallBack connection:this
                                  didReceiveResponse:response];
                    m_state = EReceivingData;
                    if (restOffSet > 0)
                    {
                        int restLength = CFDataGetLength(data) - restOffSet;
                        const UInt8 * restDataPtr = CFDataGetBytePtr(data) + restOffSet;
                        CFDataRef restData = CFDataCreate(kCFAllocatorDefault, restDataPtr, restLength);
                        handleBodyData(restData);
                        CFRelease(restData);
                    }
                }
                else
                {
                    m_state = EError;
                }
            }
        }
    }
    
    void CFConnectionCore::handleBodyData(CFDataRef data)
    {
        CFDataRef resultData = data;
        bool isError = true;
        do
        {
            if (m_responseParser->isChunked())
            {
                if (m_chunkedStreamDecoder == NULL)
                {
                    m_chunkedStreamDecoder = new ChunkedStreamDecoder();
                    if (!m_chunkedStreamDecoder->init()){
                        break;
                    }
                }
                resultData = m_chunkedStreamDecoder->decode(resultData);
                if (m_chunkedStreamDecoder->isError()) {
                    break;
                }
            }
            if (m_responseParser->isGzip())
            {
                if (m_responseParser->hasGzipContentLength())
                {
                    m_receivedDataSize += CFDataGetLength(resultData);
                }
                if (m_gzipStreamDecoder == NULL)
                {
                    m_gzipStreamDecoder = new GzipStreamDecoder();
                    if (!m_gzipStreamDecoder->init()){
                        break;
                    }
                }
                CFDataRef gzipData = resultData;
                resultData = m_gzipStreamDecoder->decode(gzipData);
                if (resultData == NULL || m_gzipStreamDecoder->isError()){
                    break;
                }
            }
            else if (m_responseParser->hasContentLength())
            {
                m_receivedDataSize += CFDataGetLength(resultData);
            }
            isError = false;
        } while (false);

        if (isError)
        {
            [m_connectionCallBack connection:this didFailWithError:(NSError*)NULL];
        }
        else
        {
            [m_connectionCallBack connection:this didReceiveData:(NSData*)resultData];
            bool isFinish = false;
            if (m_chunkedStreamDecoder && m_chunkedStreamDecoder->isFinish())
            {
                isFinish = true;
            }
            else if (m_gzipStreamDecoder
                     && (m_gzipStreamDecoder->isFinish()
                         || (m_responseParser->hasGzipContentLength()
                             && m_responseParser->gzipContentLength() == m_receivedDataSize
                             )
                         )
                     )
            {
                assert(!m_responseParser->hasGzipContentLength()
                       || m_receivedDataSize == m_responseParser->gzipContentLength());
                isFinish = true;
            }
            else if (m_responseParser->hasContentLength()
                     && m_receivedDataSize == m_responseParser->contentLength())
            {
                isFinish = true;
            }
            if (isFinish)
            {
                m_state = EFinish;
                [m_connectionCallBack connectionDidFinishLoading:this];
            }
        }
    }
    void CFConnectionCore::freeSocket()
    {
        if (m_handler)
        {
            CFSocketFactory::global()->recycleSocket(m_handler);
            m_handler = nil;
        }
    }
    void CFConnectionCore::didFailSocketStream(CFSocketHandler* handler, CFErrorRef error)
    {
        [m_connectionCallBack connection:this didFailWithError:(NSError*)error];
    }
    void CFConnectionCore::didCloseSocketStream(J::CFSocketHandler *handler)
    {
        if (EFinish != m_state && EError != m_state && ECancelByUse != m_state)
        {
            m_state = EFinish;
            [m_connectionCallBack connectionDidFinishLoading:this];
        }
    }
    
    bool CFConnectionCore::dataShouldSend(const Byte*& data, uint& dataLength)
    {
        if (m_sendBuffer == NULL)
        {
            ///FIXME: handle error
            m_sendBuffer = RequestUtil::serialization(m_curRequest);
            assert(m_sendBuffer);
        }
        data = CFDataGetMutableBytePtr(m_sendBuffer) + m_sendBufferOffset;
        dataLength = CFDataGetLength(m_sendBuffer) - m_sendBufferOffset;
        return true;
    }
    
    void CFConnectionCore::dataDidSend(uint datalength)
    {
        m_sendBufferOffset += datalength;
    }
    
    CFStringRef CFConnectionCore::host()
    {
        return RequestUtil::host(m_curRequest);
    }
    
    UInt32 CFConnectionCore::port()
    {
        return RequestUtil::port(m_curRequest);
    }
};