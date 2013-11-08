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


namespace J {
    class CFConnectionCore;
}

@protocol CFConnectionCoreDelegate <NSObject>

- (void)connection:(J::CFConnectionCore *)connection
  didFailWithError:(NSError *)error;

- (NSURLRequest *)connection:(J::CFConnectionCore *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response;

- (void)connection:(J::CFConnectionCore *)connection
didReceiveResponse:(NSURLResponse *)response;

- (void)connection:(J::CFConnectionCore *)connection
    didReceiveData:(NSData *)data;

- (NSCachedURLResponse *)connection:(J::CFConnectionCore *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse;

- (void)connectionDidFinishLoading:(J::CFConnectionCore *)connection;


@end

namespace J
{
    class ResponseParser;
    class ChunkedStreamDecoder;
    class GzipStreamDecoder;
    class CFConnectionCore : protected CFSocketHandlerClient
    {
    public:
        CFConnectionCore(NSURLRequest* aRequest
                         , id<CFConnectionCoreDelegate> aConnection);
        ~CFConnectionCore();
        
    public:
        void start();
        void cancel();
        
        NSURLRequest* currentRequest(){return m_curRequest;}
        NSURLRequest* originalRequest(){return m_oriRequest;}
        
    public:
        void setConnection(id<CFConnectionCoreDelegate> connection);
        
    protected://notify from CFSocketHandlerClient
        virtual void didReceiveSocketStreamData(CFSocketHandler*, CFDataRef);
        virtual void didFailSocketStream(CFSocketHandler*, CFErrorRef);
        virtual void didCloseSocketStream(CFSocketHandler*);
        
    protected://data source
        virtual bool dataShouldSend(const Byte*& data, uint& dataLength);
        virtual void dataDidSend(uint datalength);
        
        virtual CFStringRef host();
        virtual UInt32 port();
        
    protected:
        void handleResponseData(CFDataRef data);
        void handleBodyData(CFDataRef data);
        
        void freeSocket();
    protected:
        id<CFConnectionCoreDelegate>        m_connectionCallBack;
        
        NSMutableURLRequest*                m_oriRequest;
        NSMutableURLRequest*                m_curRequest;
        
        CFMutableDataRef                    m_sendBuffer;
        uint                                m_sendBufferOffset;
        
        
        CFSocketHandler*                    m_handler;
        
        ResponseParser*                     m_responseParser;
        
        enum State {EIdle,EWaitingResponse,EReceivingData,EFinish,EError,ECancelByUse};
        State                               m_state;
        
        ChunkedStreamDecoder*               m_chunkedStreamDecoder;
        GzipStreamDecoder*                  m_gzipStreamDecoder;
        
        uint                                m_receivedDataSize;
    };
};

#endif /* defined(__JCFConnection__CFConnectionCore__) */
