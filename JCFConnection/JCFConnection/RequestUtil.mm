//
//  RequestUtil.cpp
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "RequestUtil.h"
#include "HTTPDefine.h"
#include "Util.h"
namespace J
{
    CFStringRef RequestUtil::host(NSURLRequest* request)
    {
        return (CFStringRef)[[request URL] host];
    }
    UInt32 RequestUtil::port(NSURLRequest* request)
    {
        UInt32 port = (UInt32)CFURLGetPortNumber((CFURLRef)[request URL]);
        if (port == -1)
        {
            port = 80;
        }
        return port;
    }
    static void HTTPHeaderDictionaryApplierFunction(CFStringRef key, CFStringRef value, CFMutableDataRef mData)
    {
        assert([(id)key isKindOfClass:[NSString class]]);
        assert([(id)value isKindOfClass:[NSString class]]);
        assert(mData);
        if (value == NULL)
        {
            assert(0);
            return;
        }
        assert([(NSString*)key isEqualToString:(NSString*)Util::standardizeHeaderName(key)]);
        CFStringRef headValue = CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%@: %@\r\n"),key,value);
        if (headValue)
        {
            const char* headValueUTF8 = Util::getUTF8String(headValue);
            assert(headValueUTF8);
            if (headValueUTF8) {
                CFDataAppendBytes(mData, (const Byte*)headValueUTF8, strlen(headValueUTF8));
                CFRelease(headValue);
            }
            
        }
        
    }
    CFMutableDataRef RequestUtil::serialization(NSURLRequest* request)
    {
        CFMutableDataRef mData = CFDataCreateMutable(kCFAllocatorDefault, 0);
        CFURLRef url = (CFURLRef)[request URL];
        //GET /path+resourceSpecifier HTTP/1.1
        {
            const char* methodC = NULL;
            CFStringRef method = (CFStringRef)[request HTTPMethod];
            if (kCFCompareEqualTo != CFStringCompare(CFSTR("POST"), method, kCFCompareCaseInsensitive))
            {
                methodC = "GET ";
            }
            else
            {
                methodC = "POST ";
            }
            
            CFStringRef path = CFURLCopyPath(url);
            const char* pathUTF8 = Util::getUTF8String(path);
  
            CFDataAppendBytes(mData, (const Byte*)methodC, strlen(methodC));
            CFDataAppendBytes(mData, (const Byte*)pathUTF8, strlen(pathUTF8));
            
            CFStringRef resourceSpecifier = CFURLCopyResourceSpecifier(url);
            if (resourceSpecifier)
            {
                const char* resourceSpecifierUTF8 = Util::getUTF8String(resourceSpecifier);
                CFDataAppendBytes(mData, (const Byte*)resourceSpecifierUTF8, strlen(resourceSpecifierUTF8));
                CFRelease(resourceSpecifier);
            }

            const char HTTPVersion[] = " HTTP/1.1\r\n";
            CFDataAppendBytes(mData, (const Byte*)HTTPVersion, sizeof(HTTPVersion)-1);
            
            
            CFRelease(path);
        }
        //Header
        CFDictionaryRef header = (CFDictionaryRef)[request allHTTPHeaderFields];
        //Host
        {
            CFStringRef host = NULL;
            bool isPresent = header ? CFDictionaryGetValueIfPresent(header
                                                           , (const void *)KHTTPHeader_Host
                                                                    , (const void **)&host):false;
            if (!isPresent)
            {
                CFStringRef tempHost = CFURLCopyHostName(url);
                [(id)tempHost autorelease];
                UInt32 port = RequestUtil::port(request);
                if (port != 80)
                {
                    tempHost = CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%@:%d"),tempHost,(int)port);
                    [(id)tempHost autorelease];
                }
                host = tempHost;
                
                if (host && CFStringGetLength(host) > 0)
                {
                    appendDataWithHeaderAndValue(mData, KHTTPHeader_Host, host);
                }
            }
            
        }
        //Cookie
        {
            CFStringRef cookies = NULL;
            bool isPresent = CFDictionaryGetValueIfPresent(header
                                                           , (const void *)KHTTPHeader_Cookie
                                                           , (const void **)&host);
            if (!isPresent)
            {
                NSHTTPCookieStorage* share = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                NSArray* cookiesArray = [share cookiesForURL:(NSURL*)url];
                NSDictionary* headerDict = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
                assert([headerDict count] < 2);
                cookies = (CFStringRef)CFDictionaryGetValue((CFDictionaryRef)headerDict, (const void*)KHTTPHeader_Cookie);
                if (cookies && CFStringGetLength(cookies) > 0)
                {
                    appendDataWithHeaderAndValue(mData, KHTTPHeader_Cookie, cookies);
                }
            }
            
        }
        ///Accept-Encoding
        ///Example : Accept-Encoding:gzip,deflate
        {
            CFStringRef acceptEncoding = NULL;
            bool isPresent = header ? CFDictionaryGetValueIfPresent(header
                                                                    , (const void *)KHTTPHeader_AcceptEncoding
                                                                    , (const void **)&acceptEncoding):false;
            if (!isPresent)
            {
                acceptEncoding = CFSTR("gzip,deflate");
                appendDataWithHeaderAndValue(mData, KHTTPHeader_AcceptEncoding, acceptEncoding);
            }
            
        }
        //User-Agent
        {
            
        }
        //Connection
        {
            
        }
        //Rest Header
        {
            CFDictionaryApplyFunction(header, (CFDictionaryApplierFunction)HTTPHeaderDictionaryApplierFunction, mData);
        }
        const char endOFBody[] = "\r\n";
        CFDataAppendBytes(mData, (const Byte*)endOFBody, sizeof(endOFBody)-1);
        
        return mData;
    }
    
    bool RequestUtil::appendDataWithHeaderAndValue(CFMutableDataRef data, CFStringRef header, CFStringRef value)
    {
        //FIXME: handle error
        CFStringRef headValue = CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%@: %@\r\n"),header,value);
        const char* headValueUTF8 = Util::getUTF8String(headValue);
        CFDataAppendBytes(data, (const Byte*)headValueUTF8, strlen(headValueUTF8));
        CFRelease(headValue);
        return  true;
    }
}