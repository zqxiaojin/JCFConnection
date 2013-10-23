//
//  ChunkedStreamDecoder.h
//  JCFConnection
//
//  Created by Jin on 10/21/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__ChunkedStreamDecoder__
#define __JCFConnection__ChunkedStreamDecoder__

namespace J
{

    class ChunkedStreamDecoder
    {
    public:
        ChunkedStreamDecoder();
        ~ChunkedStreamDecoder();
        
        CFDataRef decode(CFDataRef chunkedData);
        
        bool isFinish()const {return m_state == EFinish;}
        bool isError()const{return m_state == EError;}
        
    protected:
        
        
        void handleChunk_Size(const Byte*& chunkedData,uint& chunkedDataLength);

        
        
        
//        void handleWaitingChunkCount(const Byte*& chunkedData,uint& chunkedDataLength);
//        
//        void handleReadingData(CFMutableDataRef bufferToAppend,const Byte*& chunkedData,uint& chunkedDataLength);
//        
//        void handleSkipDataBreak(const Byte*& chunkedData,uint& chunkedDataLength);
//        
//        void handleLastChunk(const Byte*& chunkedData,uint& chunkedDataLength);
    protected:
        
        uint chunkDataToCount(const Byte* data,uint dataLength);
    protected:
        
        CFMutableDataRef    m_orgDataBuffer;
        uint                m_chunkSize;
        uint                m_restSize;
        uint                m_skipSize;
        
        enum State
        {
             EChunk_Size
            ,EChunk_Ext
            ,EChunk_ExtCRLF
            ,EChunk_Data
            ,EChunk_ChunkCRLF
            ,ELastChunk_Zero
            ,ELastChunk_Ext
            ,ELastChunk_ExtCRLF
            ,ETrailer
            ,EEND_CRLF
            
            
            ,EFinish
            ,EError
        };
        State               m_state;
    };
}

#endif /* defined(__JCFConnection__ChunkedStreamDecoder__) */
