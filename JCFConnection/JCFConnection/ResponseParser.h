//
//  ResponseParser.h
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__ResponseParser__
#define __JCFConnection__ResponseParser__

namespace J
{
    class DataFinder;
    class ResponseParser
    {
    public:
        ResponseParser();
        ~ResponseParser();
        
        uint appendData(CFDataRef data);
        
        NSHTTPURLResponse* response(){return m_response;}
        
        enum State { WaitForData , Done};
        State state()const{return m_state;}
    protected:
        State               m_state;
        
        NSHTTPURLResponse*  m_response;
        
        DataFinder*         m_dataFinder;
    };
}

#endif /* defined(__JCFConnection__ResponseParser__) */
