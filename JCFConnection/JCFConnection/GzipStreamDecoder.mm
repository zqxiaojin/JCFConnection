//
//  GzipStreamDecoder.cpp
//  JCFConnection
//
//  Created by Jin on 10/27/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "GzipStreamDecoder.h"

#include <zlib.h>


#include "Util.h"

namespace J
{
    GzipStreamDecoder::GzipStreamDecoder()
    :m_zStream(NULL)
    ,m_tempDataBuffer(NULL)
    ,m_tempDataBufferLength(0)
    ,m_code(0)
    {
    }
    bool GzipStreamDecoder::init()
    {
        bool result = false;
        do
        {
            m_zStream = new z_stream();
            if (m_zStream == NULL) {
                break;
            }
            m_zStream->zalloc = Z_NULL;
            m_zStream->zfree = Z_NULL;
            m_zStream->opaque = Z_NULL;
            m_zStream->avail_in = 0;
            m_zStream->next_in = Z_NULL;
            int ret = inflateInit2(m_zStream, 16+MAX_WBITS);
            
            if (ret != Z_OK) {
                break;
            }
            
            result = true;
        } while (false);
        return result;
    }
    GzipStreamDecoder::~GzipStreamDecoder()
    {
        if (m_zStream) {
            inflateEnd(m_zStream);
        }
        if (m_tempDataBuffer) {
            free(m_tempDataBuffer);
        }
    }
    
    CFDataRef GzipStreamDecoder::decode(CFDataRef inputData)
    {
        
        CFDataRef result = NULL;
        
        m_code = decodeWithZLib(inputData);
        
        if (m_tempDataBuffer)
        {
            result = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, m_tempDataBuffer, m_tempDataBufferLength, kCFAllocatorMalloc);
            if (result == NULL)
            {
                free(m_tempDataBuffer);
            }
            m_tempDataBuffer = NULL;
        }
        return result;
    }
    
    int GzipStreamDecoder::decodeWithZLib(CFDataRef inputData)
    {
        int ret = Z_DATA_ERROR;
        unsigned have;
        do
        {
            /* decompress until deflate stream ends or end of file */
            m_zStream->avail_in = CFDataGetLength(inputData);
            if (m_zStream->avail_in == 0)
                break;
            m_zStream->next_in = (Byte*)CFDataGetBytePtr(inputData);
            
            if (m_tempDataBuffer == NULL) {
                m_tempDataBufferLength = 0;
                m_tempDataBuffer = (Byte*)malloc(KZibBufferSize);
            }
            
            /* run inflate() on input until output buffer not full */
            bool isContinue;
            do
            {
                Byte* startPtr = m_tempDataBuffer;
                uint  startLength = m_tempDataBufferLength;
                m_zStream->next_out = startPtr + startLength;
                m_zStream->avail_out = KZibBufferSize;
                
                ret = inflate(m_zStream, Z_NO_FLUSH);
                assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
                switch (ret)
                {
                    case Z_NEED_DICT:
                        ret = Z_DATA_ERROR;     /* and fall through */
                    case Z_DATA_ERROR:
                    case Z_MEM_ERROR:
                        return ret;
                }
                have = KZibBufferSize - m_zStream->avail_out;
                
                isContinue = m_zStream->avail_out == 0;
                m_tempDataBufferLength = startLength + have;
                if (isContinue)
                {
                    m_tempDataBuffer = (Byte*)realloc(m_tempDataBuffer, m_tempDataBufferLength + KZibBufferSize);
                }
                
                
            } while (isContinue);
            
        } while (false);

        return ret;
    }
    
    bool GzipStreamDecoder::isError()const
    {
        return m_code < Z_OK;
    }
    bool GzipStreamDecoder::isFinish()const
    {
        return m_code == Z_STREAM_END;
    }
}


