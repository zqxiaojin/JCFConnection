//
//  HTTPDefine.h
//  JCFConnection
//
//  Created by Jin on 10/19/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__HTTPDefine__
#define __JCFConnection__HTTPDefine__

#define KHTTPEndOfHeader "\r\n\r\n"

#define KHTTPHeaderLineBreak "\r\n"

#define KHTTPHeaderColon    ":"


#define isHexChar(c)   (('a'<=(c)&&(c)<='f')||('A'<=(c)&&(c)<='F')||('0'<=(c)&&(c)<='9'))

namespace J
{
    ///Method, uppercase
    extern CFStringRef KHTTPMethod_GET;
    extern CFStringRef KHTTPMethod_POST;
    
    ///Header
    extern CFStringRef KHTTPHeader_AcceptEncoding;
    extern CFStringRef KHTTPHeader_Cookie;
    extern CFStringRef KHTTPHeader_ContentDisposition;
    extern CFStringRef KHTTPHeader_ContentEncoding;
    extern CFStringRef KHTTPHeader_ContentLength;
    extern CFStringRef KHTTPHeader_Host;
    extern CFStringRef KHTTPHeader_Location;
    extern CFStringRef KHTTPHeader_SetCookie;
    extern CFStringRef KHTTPHeader_TransferEncoding;
    extern CFStringRef KHTTPHeader_UserAgent;
    
    ///HeaderValue, lowercase
    extern CFStringRef KHTTPHeaderValue_chunked;
    extern CFStringRef KHTTPHeaderValue_gzip;
    
    ///Header for backup
    extern CFStringRef KHTTPHeader_ContentLength_Backup;
}


#endif /* defined(__JCFConnection__HTTPDefine__) */
