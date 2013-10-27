//
//  GzipStreamDecoder.h
//  JCFConnection
//
//  Created by Jin on 10/27/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__GzipStreamDecoder__
#define __JCFConnection__GzipStreamDecoder__


typedef struct z_stream_s z_stream;

namespace J
{
    class GzipStreamDecoder
    {
    public:
        
        static const uint KZibBufferSize = 16*1024;
        
        GzipStreamDecoder();
        ~GzipStreamDecoder();
        
        bool init();
        
        CFDataRef decode(CFDataRef inputData);
        
        bool isError()const;
        bool isFinish()const;
        
    protected:
        
        int decodeWithZLib(CFDataRef inputData);
        
    protected:
        
        
        z_stream*           m_zStream;
        
        Byte*               m_tempDataBuffer;
        uint                m_tempDataBufferLength;
        
        int                 m_code;
        
    };
}

#endif /* defined(__JCFConnection__GzipStreamDecoder__) */
