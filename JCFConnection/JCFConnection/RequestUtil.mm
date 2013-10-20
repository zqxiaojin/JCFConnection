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
            const char* headValueUTF8 = CFStringGetCStringPtr(headValue, kCFStringEncodingUTF8);
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
            const char* pathUTF8 = CFStringGetCStringPtr(path, kCFStringEncodingUTF8);
            CFStringRef resourceSpecifier = CFURLCopyResourceSpecifier(url);
            const char* resourceSpecifierUTF8 = CFStringGetCStringPtr(resourceSpecifier, kCFStringEncodingUTF8);
            CFDataAppendBytes(mData, (const Byte*)methodC, strlen(methodC));
            CFDataAppendBytes(mData, (const Byte*)pathUTF8, strlen(pathUTF8));
            CFDataAppendBytes(mData, (const Byte*)resourceSpecifierUTF8, strlen(resourceSpecifierUTF8));
            
            const char HTTPVersion[] = " HTTP/1.1\r\n";
            CFDataAppendBytes(mData, (const Byte*)HTTPVersion, sizeof(HTTPVersion)-1);
            
            CFRelease(resourceSpecifier);
            CFRelease(path);
        }
        //Header
        CFDictionaryRef header = (CFDictionaryRef)[request allHTTPHeaderFields];
        //Host
        {
            CFStringRef host = header ? (CFStringRef)CFDictionaryGetValue(header,KHTTPHeader_Host) : NULL;
            if (host == NULL || CFStringGetLength(host) == 0)
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
                CFStringRef headValue = CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%@: %@\r\n"),KHTTPHeader_Host,host);
                const char* headValueUTF8 = CFStringGetCStringPtr(headValue, kCFStringEncodingUTF8);
                CFDataAppendBytes(mData, (const Byte*)headValueUTF8, strlen(headValueUTF8));
                CFRelease(headValue);
            }
        }
        //Cookie
        {
            
        }
        ///Accept-Encoding
        ///Example : Accept-Encoding:gzip,deflate
        {
            CFStringRef acceptEncoding = header ? (CFStringRef)CFDictionaryGetValue(header,KHTTPHeader_AcceptEncoding) : NULL;
            if (acceptEncoding == NULL || CFStringGetLength(acceptEncoding) == 0)
            {
                acceptEncoding = CFSTR("gzip,deflate");
                CFStringRef headValue = CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%@: %@\r\n"),KHTTPHeader_AcceptEncoding,acceptEncoding);
                const char* headValueUTF8 = CFStringGetCStringPtr(headValue, kCFStringEncodingUTF8);
                CFDataAppendBytes(mData, (const Byte*)headValueUTF8, strlen(headValueUTF8));
                CFRelease(headValue);
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
}