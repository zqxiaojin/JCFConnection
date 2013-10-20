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

namespace J
{
    extern CFStringRef KHTTPHeader_Location;
    extern CFStringRef KHTTPHeader_Cookie;
    extern CFStringRef KHTTPHeader_ContentLength;
    extern CFStringRef KHTTPHeader_ContentDisposition;
    extern CFStringRef KHTTPHeader_SetCookie;
    
    extern CFStringRef KHTTPHeader_UserAgent;
}


#endif /* defined(__JCFConnection__HTTPDefine__) */
