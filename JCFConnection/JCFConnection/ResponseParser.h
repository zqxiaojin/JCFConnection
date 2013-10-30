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
        
        uint appendDataAndParse(CFDataRef data);
        
        enum State { WaitForData , Done , Error};
        State state()const{return m_state;}
        
        static HTTPResponse* parse(const Byte* data,uint dataLength);
        static void handleHTTPFieldParse(CFMutableDictionaryRef outputDic, CFStringRef headerName , const Byte* valueData , uint valueDataLength);
        
        NSHTTPURLResponse* makeResponseWithURL(NSURL* url);
        
        bool isChunked()const{return m_isChunked;}
        bool isGzip()const{return m_isGzip;}
        
        bool hasContentLength()const {return m_hasRawContentLength;}
        uint contentLength()const { return m_rawContentLength;}
        
        bool hasGzipContentLength()const {return m_hasGzipContentLength;}
        uint gzipContentLength()const { return m_gzipContentLength;}
        
    protected:
        bool  isHeaderContainString(CFStringRef headerName, CFStringRef str);
        
        void parseContentLength();
        
    protected:
        bool                m_isChunked;
        bool                m_isGzip;
        HTTPResponse*       m_HTTPResponse;
        State               m_state;
        DataFinder*         m_dataFinder;
        
        bool                m_hasRawContentLength;
        uint                m_rawContentLength;///<data datalength without compress
        
        bool                m_hasGzipContentLength;
        uint                m_gzipContentLength;///<data after gzip compress datalength
    };
}

#endif /* defined(__JCFConnection__ResponseParser__) */
