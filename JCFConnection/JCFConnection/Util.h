//
//  Util.h
//  JCFConnection
//
//  Created by Jin on 10/19/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__Util__
#define __JCFConnection__Util__

namespace J
{
    class Util
    {
    public:
        static CFTypeRef CFAutoRelease(CFTypeRef type)
        {
            return (CFTypeRef)[(id)type autorelease];
        }
    };
}

#endif /* defined(__JCFConnection__Util__) */
