//
//  HTTPResponse.cpp
//  JCFConnection
//
//  Created by Jin on 10/18/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "HTTPResponse.h"
#include "Util.h"

namespace J
{
    HTTPResponse::HTTPResponse()
    :m_HTTPHeader(NULL)
    ,m_statusCode(0)
    ,m_HTTPVersion(NULL)
    {
        
    }
    HTTPResponse::~HTTPResponse()
    {
        if (m_HTTPVersion) {
            CFRelease(m_HTTPVersion);
        }
        if (m_HTTPHeader) {
             CFRelease(m_HTTPHeader);
        }
    }
    
    void HTTPResponse::setHTTPHeaderDict(CFMutableDictionaryRef newDict)
    {
        QuickSetRetainValue(m_HTTPHeader,newDict);
    }

    void HTTPResponse::setHTTPVersion(CFStringRef newHTTPVersion)
    {
        QuickSetRetainValue(m_HTTPVersion,newHTTPVersion);
    }

}