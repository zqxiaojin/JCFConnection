//
//  RequestTool.h
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__RequestTool__
#define __JCFConnection__RequestTool__


namespace J
{
    class RequestTool
    {
    public:
        static CFStringRef host(NSURLRequest* request);
        static UInt32 port(NSURLRequest* request);
        static CFMutableDataRef serialization(NSURLRequest* request);
    };
};


#endif /* defined(__JCFConnection__RequestTool__) */
