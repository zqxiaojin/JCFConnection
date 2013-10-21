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
    ,m_chunkedStreamDecoder(NULL)
    {
        
    }
    CFConnectionCore::~CFConnectionCore()
    {
        if (m_chunkedStreamDecoder) {
            delete m_chunkedStreamDecoder;
        }
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
                handleBodyData(data);
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
        assert(m_responseParser->state() != ResponseParser::Done);
        if (ResponseParser::WaitForData == m_responseParser->state())
        {
            int restOffSet = m_responseParser->appendDataAndParse(data);
            if (ResponseParser::Done == m_responseParser->state())
            {
                ///FIXME: It may be distory after this,should protect itself
                [m_connection connection:this didReceiveResponse:m_responseParser->makeResponseWithURL([m_curRequest URL])];
                
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
        }
    }
    void CFConnectionCore::handleBodyData(CFDataRef data)
    {
        CFDataRef resultData = data;
        if (m_responseParser->isChunked())
        {
            if (m_chunkedStreamDecoder == NULL) {
                m_chunkedStreamDecoder = new ChunkedStreamDecoder();
            }
            resultData = m_chunkedStreamDecoder->decode(data);
            if (m_chunkedStreamDecoder->isError())
            {
                ///FIXME: chunked error
                [m_connection connection:this didFailWithError:(NSError*)NULL];
                return;
            }
        }
        if (m_responseParser->isGzip())
        {
            ///FIXME: support gzip
        }
        [m_connection connection:this didReceiveData:(NSData*)resultData];
        
        if (m_chunkedStreamDecoder && m_chunkedStreamDecoder->isFinish())
        {
            [m_connection connectionDidFinishLoading:this];
        }
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