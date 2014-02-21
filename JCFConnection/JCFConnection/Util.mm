//
//  Util.cpp
//  JCFConnection
//
//  Created by Jin on 10/19/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "Util.h"
#include "HTTPDefine.h"

namespace J
{
    CFStringRef Util::standardizeHeaderName(CFStringRef headerName)
    {
        static CFMutableDictionaryRef headerDic = NULL;
        if (headerDic == NULL)
        {
            CFDictionaryKeyCallBacks callBack = kCFTypeDictionaryKeyCallBacks;
            callBack.equal = (CFDictionaryEqualCallBack)Util::isEqualString;
            headerDic = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &callBack, &kCFTypeDictionaryValueCallBacks);
            
            ///define by RFC http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.6
            CFStringRef standHeader[] = {
                 CFSTR("Accept")
                ,CFSTR("Accept-Charset")
                ,CFSTR("Accept-Encoding")
                ,CFSTR("Accept-Language")
                ,CFSTR("Accept-Ranges")
                ,CFSTR("Age")
                ,CFSTR("Allow")
                ,CFSTR("Authorization")
                ,CFSTR("Cache-Control")
                ,CFSTR("Connection")
                ,KHTTPHeader_ContentDisposition///<http://www.w3.org/Protocols/rfc2616/rfc2616-sec19.html
                ,CFSTR("Content-Encoding")
                ,CFSTR("Content-Language")
                ,KHTTPHeader_ContentLength
                ,CFSTR("Content-Location")
                ,CFSTR("Content-MD5")
                ,CFSTR("Content-Range")
                ,CFSTR("Content-Type")
                ,CFSTR("Date")
                ,CFSTR("ETag")
                ,CFSTR("Expect")
                ,CFSTR("Expires")
                ,CFSTR("From")
                ,CFSTR("Host")
                ,CFSTR("If-Match")
                ,CFSTR("If-Modified-Since")
                ,CFSTR("If-None-Match")
                ,CFSTR("If-Range")
                ,CFSTR("If-Unmodified-Since")
                ,CFSTR("Last-Modified")
                ,KHTTPHeader_Location
                ,CFSTR("Max-Forwards")
                ,CFSTR("Pragma")
                ,CFSTR("Proxy-Authenticate")
                ,CFSTR("Range")
                ,CFSTR("Referer")
                ,CFSTR("Retry-After")
                ,CFSTR("Server")
                ,KHTTPHeader_SetCookie
                ,CFSTR("TE")
                ,CFSTR("Trailer")
                ,CFSTR("Transfer-Encoding")
                ,CFSTR("Upgrade")
                ,KHTTPHeader_UserAgent
                ,CFSTR("Vary")
                ,CFSTR("Via")
                ,CFSTR("Warning")
                ,CFSTR("WWW-Authenticate")
            };
            uint standHeaderArrCount = SizeOfArray(standHeader);
            for (uint i = 0 ; i < standHeaderArrCount; ++i)
            {
                CFStringRef lowcase = (CFStringRef)[(NSString*)standHeader[i] lowercaseString];
                CFDictionarySetValue(headerDic, lowcase, standHeader[i]);
            }
        }
        CFStringRef lowcaseHeaderName = (CFStringRef)[(NSString*)headerName lowercaseString];
        CFStringRef result = (CFStringRef)CFDictionaryGetValue(headerDic, lowcaseHeaderName);
        return result ? result : headerName;
    }
    
    const char* Util::getUTF8String(CFStringRef cfstr)
    {
        const char* utf8Value = CFStringGetCStringPtr(cfstr, kCFStringEncodingUTF8);
        if (utf8Value == NULL)
        {
            utf8Value = [(NSString*)cfstr UTF8String];
        }
        return utf8Value;
    }
    
    BOOL Util::isEqualString(CFStringRef a, CFStringRef b)
    {
        return CFStringCompare(a, b, NULL) == kCFCompareEqualTo;
    }
}