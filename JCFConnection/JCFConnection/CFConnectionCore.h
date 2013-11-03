//
//  CFConnectionCore.h
//  JCFConnection
//
//  Created by Liang Jin on 10/13/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__CFConnectionCore__
#define __JCFConnection__CFConnectionCore__
#include "CFSocketHandlerClient.h"

@class JCFConnection;

namespace J
{
    class ResponseParser;
    class ChunkedStreamDecoder;
    class GzipStreamDecoder;
    class CFConnectionCore : protected CFSocketHandlerClient
    {
    public:
        CFConnectionCore(NSURLRequest* request, JCFConnection* aConnection);
        ~CFConnectionCore();
        
    public:
        void start();
        void cancel();
        
        NSURLRequest* currentRequest(){return m_curRequest;}
        NSURLRequest* originalRequest(){return m_oriRequest;}
        
    public:
        void setConnection(JCFConnection* connection){m_connectionCallBack = connection;}
        
    protected://notify
        virtual void didReceiveSocketStreamData(CFSocketHandler*, CFDataRef);
        virtual void didFailSocketStream(CFSocketHandler*, CFErrorRef);
        virtual void didCloseSocketStream(CFSocketHandler*);
        
    protected://data source
        virtual bool dataShouldSend(const Byte*& data, uint& dataLength);
        virtual void dataDidSend(uint datalength);
        
        virtual CFStringRef host();
        virtual UInt32 port();
        
    protected:
        virtual void handleResponseData(CFDataRef data);
        virtual void handleBodyData(CFDataRef data);
    protected:
        JCFConnection*          m_connectionCallBack;
        
        NSMutableURLRequest*    m_oriRequest;
        NSMutableURLRequest*    m_curRequest;
        
        CFMutableDataRef        m_sendBuffer;
        uint                    m_sendBufferOffset;
        
        
        CFSocketHandler*        m_handler;
        
        ResponseParser*         m_responseParser;
        
        enum State {EWaitingResponse,EReceivingData,EFinish,EError,ECancelByUse};
        State                   m_state;
        
        ChunkedStreamDecoder*   m_chunkedStreamDecoder;
        GzipStreamDecoder*      m_gzipStreamDecoder;
        
        uint                    m_receivedDataSize;
    };
};

#endif /* defined(__JCFConnection__CFConnectionCore__) */
