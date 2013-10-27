//
//  RequestUtil.h
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__RequestUtil__
#define __JCFConnection__RequestUtil__


namespace J
{
    class RequestUtil
    {
    public:
        static CFStringRef host(NSURLRequest* request);
        static UInt32 port(NSURLRequest* request);
        static CFMutableDataRef serialization(NSURLRequest* request);
        
        static bool appendDataWithHeaderAndValue(CFMutableDataRef data, CFStringRef header, CFStringRef value);
    };
};


#endif /* defined(__JCFConnection__RequestUtil__) */
