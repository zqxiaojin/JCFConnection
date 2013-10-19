//
//  HTTPResponse.cpp
//  JCFConnection
//
//  Created by Jin on 10/18/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "HTTPResponse.h"


namespace J
{
    HTTPResponse::HTTPResponse()
    :m_HTTPHeader(NULL)
    ,m_stateCode(0)
    ,m_httpVersion(NULL)
    {
        
    }
    HTTPResponse::~HTTPResponse()
    {
        if (m_httpVersion) {
            CFRelease(m_httpVersion);
        }
        if (m_HTTPHeader) {
             CFRelease(m_HTTPHeader);
        }
    }
}