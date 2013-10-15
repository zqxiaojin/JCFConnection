//
//  DataArrayReader.h
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__DataArrayReader__
#define __JCFConnection__DataArrayReader__

namespace J
{
    class DataArrayReader
    {
    public:
        DataArrayReader();
        ~DataArrayReader();
        void appendData(CFDataRef data);
        
        enum { NotFound = -1};
        uint locationOfBytes(uint offset
                                 , Byte* bytes
                                 , uint length);
        
    protected:
        
        uint dataIndexAtOffSet(uint offset);
        
    protected:
//        CFMutableDataRef   m_;
    };
}

#endif /* defined(__JCFConnection__DataArrayReader__) */
