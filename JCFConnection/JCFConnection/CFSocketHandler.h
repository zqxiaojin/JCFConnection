//
//  CFSocketHandler.h
//  JCFConnection
//
//  Created by Liang Jin on 10/12/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__CFSocketHandler__
#define __JCFConnection__CFSocketHandler__
#import <Foundation/Foundation.h>

namespace J
{
    class CFSocketHandlerClient;
    class CFSocketHandler
    {
    public:
        CFSocketHandler(CFSocketHandlerClient* aClient);
        
    public://for retaincount, not thread safe
        CFSocketHandler* retain(){++m_retainCount;return this;}
        void release(){if(--m_retainCount == 0)delete this;}
        uint retainCount()const{return m_retainCount;}
    public:        
        void start();
        void cancel();
        
        enum StreamState
        {
            Connecting
            , Open
            , Closing
            , Closed
        };
        StreamState state()const { return m_state;}
    protected:
        ~CFSocketHandler();
        void createStreams();
        void scheduleStreams();
        
        void reportErrorToClient(CFErrorRef);
        
        void sendPendingData();
        
        void close();
        
    protected://callback by stream
        static void* retainConnectionCore(void*);
        static void releaseConnectionCore(void*);
        static CFStringRef copyCFStreamDescription(void*);
        static void readStreamCallback(CFReadStreamRef, CFStreamEventType, void*);
        static void writeStreamCallback(CFWriteStreamRef, CFStreamEventType, void*);
        
        void readStreamCallback(CFStreamEventType);
        void writeStreamCallback(CFStreamEventType);
        
    protected:
        enum ConnectingSubstate
        {
            New
            , WaitingForCredentials
            , WaitingForConnect
            , Connected
        };
        ConnectingSubstate      m_connectingSubstate;


        CFSocketHandlerClient*  m_client;
        
        CFReadStreamRef         m_readStream;
        CFWriteStreamRef        m_writeStream;
        
        
        unsigned                m_retainCount;
        
        StreamState             m_state;
        CFMutableDataRef        m_requestBuffer;
    };
}

#endif /* defined(__JCFConnection__CFSocketHandler__) */
