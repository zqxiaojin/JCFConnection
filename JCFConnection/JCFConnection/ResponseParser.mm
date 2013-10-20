//
//  ResponseParser.cpp
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "ResponseParser.h"
#include "DataFinder.h"
#include "HTTPResponse.h"
#include "HTTPDefine.h"
#include "Util.h"

#define DEBUG_ENABLE_LOG_RESPONSE

#ifdef DEBUG_ENABLE_LOG_RESPONSE
#define LOG_RES     NSLog
#else
#define LOG_RES(...)
#endif//DEBUG_ENABLE_LOG_RESPONSE

namespace J
{
    ResponseParser::ResponseParser()
    :m_state(WaitForData)
    ,m_dataFinder(new DataFinder())
    ,m_HTTPResponse(NULL)
    ,m_isChunked(false)
    ,m_isGZip(false)
    {
        CFDataRef bodyEOF = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)KHTTPEndOfHeader, 4, kCFAllocatorNull);
        m_dataFinder->setTargetData(bodyEOF);
        CFRelease(bodyEOF);
    }
    ResponseParser::~ResponseParser()
    {
        delete m_HTTPResponse;
        delete m_dataFinder;
    }
    uint ResponseParser::appendDataAndParse(CFDataRef data)
    {
        m_dataFinder->appendData(data);
        uint result = m_dataFinder->find();
        if (result != kCFNotFound)
        {
            m_HTTPResponse = parse(CFDataGetBytePtr(m_dataFinder->getDataBuffer()), result);
            m_state = Done;
            
            if (isHeaderContainString(KHTTPHeader_TransferEncoding, KHTTPHeaderValue_chunked)) {
                m_isChunked = true;
            }
            if (isHeaderContainString(KHTTPHeader_ContentEncoding, KHTTPHeaderValue_gzip)) {
                m_isGZip = true;
            }
        }
        return result;
    }
    bool  ResponseParser::isHeaderContainString(CFStringRef headerName, CFStringRef str)
    {
        bool isContain = false;
        do {
            CFStringRef value = (CFStringRef)CFDictionaryGetValue(m_HTTPResponse->HTTPHeaderDict(), headerName);
            if (value)
            {
                break;
            }
            CFRange range = CFStringFind(value, str, kCFCompareCaseInsensitive);
            if (range.location != NSNotFound) {
                isContain = true;
            }
        } while (false);
        return isContain;
    }
    NSHTTPURLResponse* ResponseParser::makeResponseWithURL(NSURL* url)
    {
        NSHTTPURLResponse* nsResponse = NULL;
        do {
            if (url == NULL || m_HTTPResponse == NULL) {
                break;
            }
            nsResponse = [[NSHTTPURLResponse alloc] initWithURL:url
                                                     statusCode:m_HTTPResponse->statusCode()
                                                    HTTPVersion:(NSString*)m_HTTPResponse->HTTPVersion()
                                                   headerFields:(NSDictionary*)m_HTTPResponse->HTTPHeaderDict()];
            [nsResponse autorelease];
        } while (false);
        return nsResponse;
    }
    
    HTTPResponse* ResponseParser::parse(const Byte* data,uint dataLength)
    {
        LOG_RES(@"\nRaw Header:\n%@", (NSString*)Util::CFAutoRelease(CFStringCreateWithBytes(0,data,dataLength,kCFStringEncodingUTF8,0)));
        HTTPResponse* resultResponse = NULL;
        do
        {
            ///Parse Status Line
            ///Example:
            ///HTTP1.1 200 OK\r\n
            uint firstLineBreak = DataFinder::findData(data, dataLength, (const Byte *)KHTTPHeaderLineBreak, SizeOfArray(KHTTPHeaderLineBreak));
            if (firstLineBreak == NSNotFound)
            {
                break;
            }
            uint statusStart = DataFinder::findData(data, dataLength, (const Byte *)" ", 1);
            if (statusStart == NSNotFound || statusStart > firstLineBreak)
                break;

            CFStringRef httpVersion = CFStringCreateWithBytes(kCFAllocatorDefault, data, statusStart, kCFStringEncodingUTF8, false);
            if (httpVersion == NULL)
                break;
            Util::CFAutoRelease(httpVersion);
            
            ///<skip the space
            while (data[++statusStart] == ' ' && statusStart < firstLineBreak);
            if (!(statusStart < firstLineBreak)) {
                break;
            }
            
            uint statusEnd = DataFinder::findData(data + statusStart, dataLength - statusStart, (const Byte *)" ", 1);
            if (statusEnd == NSNotFound)
                break;
            CFStringRef statusCodeStr = CFStringCreateWithBytes(kCFAllocatorDefault, data + statusStart, statusEnd, kCFStringEncodingUTF8, false);
            if (statusCodeStr == NULL) {
                break;
            }
            Util::CFAutoRelease(statusCodeStr);
            uint statusCode = (int)CFStringGetIntValue(statusCodeStr);
            
            ///Parse Header
            ///Example:
            /*
             Date: Sat, 19 Oct 2013 16:52:06 GMT\r\n
             Transfer-Encoding:  chunked\r\n
             Connection: keep-alive\r\n
             Connection: Transfer-Encoding\r\n
             Set-Cookie: _FS=NU=1; domain=.bing.com; path=/\r\n
             */
            CFMutableDictionaryRef headerDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            if (headerDictionary == NULL) {
                break;
            }
            Util::CFAutoRelease(headerDictionary);
            const Byte* headerDataStart = data + firstLineBreak + SizeOfArray(KHTTPHeaderLineBreak);
            uint headerDataLength = dataLength - (firstLineBreak + SizeOfArray(KHTTPHeaderLineBreak));
            const Byte* headerDataStartPtr = headerDataStart;
            uint headerDataLengthRest = headerDataLength;
            uint headerLineBreakOffset = 0;//init value
            while (headerLineBreakOffset != NSNotFound && headerDataLengthRest <= headerDataLength)
            {
                headerLineBreakOffset = DataFinder::findData(headerDataStartPtr, headerDataLengthRest, (const Byte*)KHTTPHeaderLineBreak, SizeOfArray(KHTTPHeaderLineBreak));
                if (headerLineBreakOffset == NSNotFound) {
                    break;
                }
                const Byte* headerLineStartPtr = headerDataStartPtr;
                headerDataStartPtr += headerLineBreakOffset + SizeOfArray(KHTTPHeaderLineBreak);
                headerDataLengthRest -= headerLineBreakOffset + SizeOfArray(KHTTPHeaderLineBreak);
                uint colonOffset = DataFinder::findData(headerLineStartPtr, headerLineBreakOffset, (const Byte*)KHTTPHeaderColon, SizeOfArray(KHTTPHeaderColon));
                if (colonOffset > headerLineBreakOffset) {
                    continue;///missing key skip it
                }
                
                CFStringRef keyStr = CFStringCreateWithBytes(kCFAllocatorDefault, headerLineStartPtr, colonOffset, kCFStringEncodingUTF8, false);
                if (keyStr == NULL) {
                    continue;///missing key skip it
                }
                Util::CFAutoRelease(keyStr);
                
                uint spaceCount = colonOffset;
                ///<skip the space
                while (headerLineStartPtr[++spaceCount] == ' ' && spaceCount < headerLineBreakOffset);
                
                handleHTTPFieldParse(headerDictionary, keyStr, headerLineStartPtr + spaceCount, headerLineBreakOffset - spaceCount);
            }
            
            resultResponse = new HTTPResponse();
            if (resultResponse == NULL) {
                break;
            }
            resultResponse->setHTTPHeaderDict(headerDictionary);
            resultResponse->setSatusCode(statusCode);
            resultResponse->setHTTPVersion(httpVersion);
           
        } while (false);
        
        return resultResponse;
    }
    
    void ResponseParser::handleHTTPFieldParse(CFMutableDictionaryRef outputDic, CFStringRef headerName , const Byte* valueData , uint valueDataLength)
    {
        CFStringRef standHeader = Util::standardizeHeaderName(headerName);
        assert(standHeader);
        if (standHeader == NULL) {
            return;
        }
        CFMutableStringRef oldValue = (CFMutableStringRef)CFDictionaryGetValue(outputDic, standHeader);
        if (oldValue == NULL)
        {
            CFStringRef valueStr = CFStringCreateWithBytes(kCFAllocatorDefault, valueData, valueDataLength, kCFStringEncodingUTF8, false);
            CFMutableStringRef mutableValueStr = CFStringCreateMutable(kCFAllocatorDefault, 0);
            CFStringAppend(mutableValueStr, valueStr);
            CFDictionarySetValue(outputDic, standHeader, mutableValueStr);
            CFRelease(valueStr);
            CFRelease(mutableValueStr);
        }
        else
        {
            ///TODO: some header may not combine by "," , such as "Location" , "Content-Disposition"
            
            ///TODO: some header may contain illegal bytes , such as "Content-Disposition"  with gbk2312 encoding filename
            
            CFStringRef valueStr = CFStringCreateWithBytes(kCFAllocatorDefault, valueData, valueDataLength, kCFStringEncodingUTF8, false);
            CFStringAppend(oldValue, CFSTR(", "));
            CFStringAppend(oldValue, valueStr);
            CFDictionarySetValue(outputDic, standHeader, oldValue);
            CFRelease(valueStr);
        }
        
    }
}