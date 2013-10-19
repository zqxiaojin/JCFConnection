//
//  HTTPResponse.h
//  JCFConnection
//
//  Created by Jin on 10/18/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__HTTPResponse__
#define __JCFConnection__HTTPResponse__

namespace J
{
    class HTTPResponse
    {
    public:
        HTTPResponse();
        ~HTTPResponse();
        

        CFMutableDictionaryRef  m_HTTPHeader;
        uint                    m_stateCode;
        CFStringRef             m_httpVersion;
    };
}

#endif /* defined(__JCFConnection__HTTPResponse__) */
