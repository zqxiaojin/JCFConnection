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
    class HTTPResponse;
    class ResponseParser
    {
    public:
        ResponseParser();
        ~ResponseParser();
        
        uint appendData(CFDataRef data);
        
        enum State { WaitForData , Done , Error};
        State state()const{return m_state;}
        
        static HTTPResponse* parse(const Byte* data,uint dataLength);
        static void handleHTTPFieldParse(CFMutableDictionaryRef outputDic, CFStringRef headerName , const Byte* valueData , uint valueDataLength);
        
        NSHTTPURLResponse* makeResponseWithURL(NSURL* url);
    protected:
        
        HTTPResponse*       m_HTTPResponse;
        State               m_state;
        DataFinder*         m_dataFinder;
    };
}

#endif /* defined(__JCFConnection__ResponseParser__) */
