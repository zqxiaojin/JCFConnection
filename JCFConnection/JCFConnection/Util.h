//
//  Util.h
//  JCFConnection
//
//  Created by Jin on 10/19/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__Util__
#define __JCFConnection__Util__

#define SizeOfArray(arr)  (sizeof((arr))/sizeof((arr)[0]) - 1)

namespace J
{
    class Util
    {
    public:
        inline static CFTypeRef CFAutoRelease(CFTypeRef type)
        {
            return (CFTypeRef)[(id)type autorelease];
        }
        
        static CFStringRef standardizeHeaderName(CFStringRef headerName);
        
        static BOOL isEqualString(CFStringRef a, CFStringRef b);
    };
}


#define QuickSetRetainValue(oldValue,newValue) if ((newValue) != (oldValue)){\
if ((oldValue))CFRelease((oldValue));\
if ((newValue))CFRetain((newValue));\
(oldValue) = (newValue);\
}\

#endif /* defined(__JCFConnection__Util__) */
