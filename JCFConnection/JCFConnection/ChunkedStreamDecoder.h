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
        void handleChunk_Ext(const Byte*& chunkedData,uint& chunkedDataLength);
        void handleChunk_ExtCRLF(const Byte*& chunkedData,uint& chunkedDataLength);
        void handleChunk_Data(const Byte*& chunkedData,uint& chunkedDataLength);
        void handleChunk_DataCRLF(const Byte*& chunkedData,uint& chunkedDataLength);
        
        void handleLastChunk_Ext(const Byte*& chunkedData,uint& chunkedDataLength);
        void handleLastChunk_ExtCRLF(const Byte*& chunkedData,uint& chunkedDataLength);
        
        void handleTrailer(const Byte*& chunkedData,uint& chunkedDataLength);

        
        
    protected://declare function
        typedef void (ChunkedStreamDecoder::*StateHandleFunction)(const Byte*& chunkedData,uint& chunkedDataLength);
        
        static StateHandleFunction KStateHandleFunction[];
    
    protected:
        bool skipChunkExtension(const Byte*& chunkedData,uint& chunkedDataLength);
        uint chunkDataToCount(const Byte* data,uint dataLength);
    protected:
        
        CFMutableDataRef    m_orgDataBuffer;
        uint                m_chunkSize;
        uint                m_restSize;
        uint                m_skipSize;
        
       /*
        copy from http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html
        
        Chunked-Body   = *chunk
                         last-chunk
                         trailer
                         CRLF
        
        chunk          = chunk-size [ chunk-extension ] CRLF
                         chunk-data CRLF
        chunk-size     = 1*HEX
        last-chunk     = 1*("0") [ chunk-extension ] CRLF
        chunk-extension= *( ";" chunk-ext-name [ "=" chunk-ext-val ] )
        chunk-ext-name = token
        chunk-ext-val  = token | quoted-string
        chunk-data     = chunk-size(OCTET)
        trailer        = *(entity-header CRLF)
        */
        enum State
        {
             EChunk_Size = 0
            ,EChunk_Ext
            ,EChunk_ExtCRLF
            ,EChunk_Data
            ,EChunk_DataCRLF
            ,ELastChunk_Ext
            ,ELastChunk_ExtCRLF
            ,ETrailer
            
            
            ,EFinish
            ,EError
        };
        State               m_state;
        
        
        enum CRLFState{EEmpty,ECR,ECRLF};
        CRLFState           m_CRLFState;
        
        CFMutableDataRef    m_tempDataBuffer;
        
        enum EntityHeaderState {EUnknow,EEntity,EEntityCR};
        EntityHeaderState   m_entityHeaderState;
    };
}

#endif /* defined(__JCFConnection__ChunkedStreamDecoder__) */
