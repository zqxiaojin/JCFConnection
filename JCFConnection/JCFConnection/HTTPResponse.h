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
        
        
    public:
        
        void setHTTPHeaderDict(CFMutableDictionaryRef newDict);
        CFMutableDictionaryRef HTTPHeaderDict(){return m_HTTPHeader;}
        
        void setSatusCode(uint statusCode){m_statusCode = statusCode;}
        uint statusCode()const{return m_statusCode;}
        
        void setHTTPVersion(CFStringRef newHTTPVersion);
        CFStringRef HTTPVersion()const{return m_HTTPVersion;}
        
    protected:
        CFMutableDictionaryRef  m_HTTPHeader;
        uint                    m_statusCode;
        CFStringRef             m_HTTPVersion;
    };
}

#endif /* defined(__JCFConnection__HTTPResponse__) */
