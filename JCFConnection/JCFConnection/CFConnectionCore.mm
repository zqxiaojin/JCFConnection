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
namespace J
{
    CFConnectionCore::CFConnectionCore(NSURLRequest* aRequest
                      , JCFConnection* aConnection)
    :m_connection(aConnection)
    ,m_oriRequest([aRequest mutableCopy])
    ,m_curRequest([m_oriRequest retain])
    ,m_sendBuffer(NULL)
    ,m_sendBufferOffset(0)
    ,m_handler(CFSocketFactory::global()->socketWithClient(this))
    ,m_responseParser(NULL)
    ,m_state(EWaitingResponse)
    {
        
    }
    CFConnectionCore::~CFConnectionCore()
    {
        m_handler->release();
        m_handler = NULL;
    }
    
    
    void CFConnectionCore::start()
    {
        m_handler->start();
    }
    
    void CFConnectionCore::cancel()
    {
        m_handler->cancel();
        m_connection = NULL;
    }

    void CFConnectionCore::didReceiveSocketStreamData(CFSocketHandler* handler, CFDataRef data)
    {
        switch (m_state)
        {
            case EWaitingResponse:
                handleResponseData(data);
                break;
            case EReceivingData:
                handleResponseData(data);
            default:
                break;
        }
    }
    void CFConnectionCore::handleResponseData(CFDataRef data)
    {
        if (m_responseParser == NULL)
        {
            m_responseParser = new ResponseParser();
        }
        if (ResponseParser::WaitForData == m_responseParser->state())
        {
            int restOffSet = m_responseParser->appendDataAndParse(data);
            if (ResponseParser::Done == m_responseParser->state())
            {
                ///FIXME: It may be distory after this,should protect itself
                [m_connection connection:this didReceiveResponse:m_responseParser->makeResponseWithURL([m_curRequest URL])];
                
                if (restOffSet > 0)
                {
                    int restLength = CFDataGetLength(data) - restOffSet;
                    const UInt8 * restDataPtr = CFDataGetBytePtr(data) + restOffSet;
                    CFDataRef restData = CFDataCreate(kCFAllocatorDefault, restDataPtr, restLength);
                    handleResponseData(restData);
                    CFRelease(restData);
                }
            }
        }
    }
    void CFConnectionCore::handleBodyData(CFDataRef data)
    {
        if (m_responseParser->isChunked())
        {
            
        }
        if (m_responseParser->isGZip())
        {
            
        }
        //[m_connection connection:this didReceiveData:(NSData*)data
    }
    void CFConnectionCore::didFailSocketStream(CFSocketHandler* handler, CFErrorRef error)
    {
        [m_connection connection:this didFailWithError:(NSError*)error];
    }
    
    bool CFConnectionCore::dataShouldSend(const Byte*& data, uint& dataLength)
    {
        if (m_sendBuffer == NULL)
        {
            m_sendBuffer = RequestUtil::serialization(m_curRequest);
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