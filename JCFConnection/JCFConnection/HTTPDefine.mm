//
//  HTTPDefine.mm
//  JCFConnection
//
//  Created by Jin on 10/20/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "HTTPDefine.h"

namespace J
{
    
    CFStringRef KHTTPMethod_GET                 = CFSTR("GET");
    CFStringRef KHTTPMethod_POST                = CFSTR("POST");
    
    CFStringRef KHTTPHeader_AcceptEncoding      = CFSTR("Accept-Encoding");
    CFStringRef KHTTPHeader_Cookie              = CFSTR("Cookie");
    CFStringRef KHTTPHeader_ContentDisposition  = CFSTR("Content-Disposition");
    CFStringRef KHTTPHeader_ContentEncoding     = CFSTR("Content-Encoding");
    CFStringRef KHTTPHeader_ContentLength       = CFSTR("Content-Length");
    
    CFStringRef KHTTPHeader_Host                = CFSTR("Host");
    CFStringRef KHTTPHeader_Location            = CFSTR("Location");
    CFStringRef KHTTPHeader_SetCookie           = CFSTR("Set-Cookie");
    CFStringRef KHTTPHeader_TransferEncoding    = CFSTR("Transfer-Encoding");
    CFStringRef KHTTPHeader_UserAgent           = CFSTR("User-Agent");
    
    
    CFStringRef KHTTPHeaderValue_chunked        = CFSTR("chunk");
    CFStringRef KHTTPHeaderValue_gzip           = CFSTR("gzip");
    
    
    ///header for backup 
    CFStringRef KHTTPHeader_ContentLength_Backup= CFSTR("X-Backup-Content-Length");
}
