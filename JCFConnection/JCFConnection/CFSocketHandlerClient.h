//
//  CFSocketHandlerClient.h
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef JCFConnection_CFSocketHandlerClient_h
#define JCFConnection_CFSocketHandlerClient_h

namespace J
{
    class CFSocketHandler;
    class CFSocketHandlerClient
    {
    public://notify
        virtual void willOpenSocketStream(CFSocketHandler* handler) { }
        virtual void didOpenSocketStream(CFSocketHandler* handler) { }
        virtual void didCloseSocketStream(CFSocketHandler* handler) { }
        virtual void didReceiveSocketStreamData(CFSocketHandler* handler, CFDataRef data) { }
        virtual void didFailSocketStream(CFSocketHandler* handler, CFErrorRef error) { }
        
    public://data source
        virtual bool dataShouldSend(const Byte*& data, uint& dataLength){return true;}
        virtual void dataDidSend(uint datalength){};
        
        virtual CFStringRef host(){return CFSTR("");}
        virtual UInt32 port(){return 80;}
    public:
        virtual ~CFSocketHandlerClient() { }
    };
}

#endif
