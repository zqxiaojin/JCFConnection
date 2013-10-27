//
//  ChunkedStreamDecoder.cpp
//  JCFConnection
//
//  Created by Jin on 10/21/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "ChunkedStreamDecoder.h"
#include "Util.h"
#include "DataFinder.h"

#define DEBUG_ENABLE_LOG_DECODER

#ifdef DEBUG_ENABLE_LOG_DECODER
#define LOG_DEC     NSLog
#else
#define LOG_DEC(...)
#endif//DEBUG_ENABLE_LOG_DECODER

namespace J
{
    const Byte  KChunkLengthBreak[] = "\r\n";
    
    ChunkedStreamDecoder::StateHandleFunction ChunkedStreamDecoder::KStateHandleFunction[] =
    {
         &ChunkedStreamDecoder::handleChunk_Size
        ,&ChunkedStreamDecoder::handleChunk_Ext
        ,&ChunkedStreamDecoder::handleChunk_ExtCRLF
        ,&ChunkedStreamDecoder::handleChunk_Data
        ,&ChunkedStreamDecoder::handleChunk_DataCRLF
        ,&ChunkedStreamDecoder::handleLastChunk_Ext
        ,&ChunkedStreamDecoder::handleLastChunk_ExtCRLF
        ,&ChunkedStreamDecoder::handleTrailer
    };
    
    ChunkedStreamDecoder::ChunkedStreamDecoder()
    :m_orgDataBuffer(NULL)
    ,m_chunkSize(0)
    ,m_restSize(0)
    ,m_state(EChunk_Size)
    ,m_skipSize(0)
    ,m_CRLFState(EEmpty)
    ,m_tempDataBuffer(NULL)
    ,m_entityHeaderState(EUnknow)
    {
        
    }
    
    bool ChunkedStreamDecoder::init()
    {
        bool isSuccess = false;
        
        do {
            ;
            if (NULL == (m_orgDataBuffer = CFDataCreateMutable(kCFAllocatorDefault, 0))) {
                break;
            }
            isSuccess = true;
        } while (false);
        assert(m_orgDataBuffer);
        return isSuccess;
    }
    ChunkedStreamDecoder::~ChunkedStreamDecoder()
    {
        if (m_orgDataBuffer) {
            CFRelease(m_orgDataBuffer);
        }
        assert(m_tempDataBuffer == NULL);
        if (m_tempDataBuffer) {
            CFRelease(m_tempDataBuffer);
        }
    }
    
    CFDataRef ChunkedStreamDecoder::decode(CFDataRef chunkedData)
    {
        COMPILE_ASSERT(sizeof(short) == 2);
        const Byte* chunkedDataStartPtr = CFDataGetBytePtr(chunkedData);
        const Byte* chunkedDataPtr = chunkedDataStartPtr;
        uint chunkedDataLength = CFDataGetLength(chunkedData);
        uint chunkedDataRestLength = chunkedDataLength;
        
        while (chunkedDataRestLength != 0 && m_state != EError)
        {
            ((*this).*((KStateHandleFunction[m_state])))(chunkedDataPtr,chunkedDataRestLength);
        }
        if (m_state == EError)
        {
            ///FIXME:give some errorcode
        }
        CFDataRef result = NULL;
        if (m_tempDataBuffer)
        {
            result = m_tempDataBuffer;
            Util::CFAutoRelease(m_tempDataBuffer);
            m_tempDataBuffer = NULL;
        }
        return result;
    }
    
    uint ChunkedStreamDecoder::chunkDataToCount(const Byte* data,uint dataLength)
    {
        uint orgDataLength = 0;
        for (uint i = 0 ; i < dataLength; ++i)
        {
            Byte c = data[dataLength - 1 - i];
            Byte value ;
            if (c >= 'a') {
                value = c - 'a' + 10;
            }
            else if ( c >= 'A'){
                value = c - 'A' + 10;
            }
            else{
                value = c - '0';
            }
            
            orgDataLength += value << (i*4);
        }
//        LOG_DEC(@"%@ -> %x == %u" , [[[NSString alloc] initWithBytes:data length:dataLength encoding:NSUTF8StringEncoding] autorelease] , orgDataLength, orgDataLength);
        return orgDataLength;
    }
    
    bool ChunkedStreamDecoder::skipChunkExtension(const Byte*& chunkedData,uint& chunkedDataLength)
    {
        bool isSkipFinish = false;
        assert(chunkedDataLength > 0);
        if (m_CRLFState == ECR)
        {
            if (*chunkedData == '\n')//check "\n"
            {
                m_CRLFState = ECRLF;
                ++chunkedData;
                --chunkedDataLength;
                m_state = EChunk_ExtCRLF;
            }
            else
            {
                m_CRLFState = EEmpty;
                ++chunkedData;
                --chunkedDataLength;
            }
        }
        else
        {
            uint linkeBreakOffset = DataFinder::findData(chunkedData, chunkedDataLength, KChunkLengthBreak, SizeOfArray(KChunkLengthBreak));
            if (linkeBreakOffset == NSNotFound)
            {
                if (chunkedData[chunkedDataLength - 1] == '\r')
                {
                    m_CRLFState = ECR;
                }
                chunkedData += chunkedDataLength;
                chunkedDataLength = 0;
            }
            else//get the "\r\n" , so we can get the size
            {
                chunkedData += linkeBreakOffset + SizeOfArray(KChunkLengthBreak);
                chunkedDataLength -= linkeBreakOffset + SizeOfArray(KChunkLengthBreak);
                m_CRLFState = ECRLF;
                isSkipFinish = true;
            }
        }
        
        return isSkipFinish;
    }
    

    
    void ChunkedStreamDecoder::handleChunk_Size(const Byte*& chunkedData,uint& chunkedDataLength)
    {
        uint notHexOffset = DataFinder::findNotHexData(chunkedData, chunkedDataLength);
        if (notHexOffset == NSNotFound)
        {
            ///FIXME: if too larget ,must handle error
            CFDataAppendBytes(m_orgDataBuffer, chunkedData, chunkedDataLength);
            if (CFDataGetLength(m_orgDataBuffer) > 8)
            {
                m_state = EError;
            }
            return;
        }
        
        const Byte* hexPointer = NULL;
        uint  hexLength = 0;
        uint  bufferLength = CFDataGetLength(m_orgDataBuffer);
        if (bufferLength > 0)
        {
            bufferLength += notHexOffset;
            CFDataAppendBytes(m_orgDataBuffer, chunkedData, notHexOffset);
            chunkedDataLength -= notHexOffset;
            chunkedData += notHexOffset;
            hexPointer = CFDataGetBytePtr(m_orgDataBuffer);
            hexLength = bufferLength;
        }
        else
        {
            hexPointer = chunkedData;
            hexLength = notHexOffset;
            chunkedDataLength -= notHexOffset;
            chunkedData += notHexOffset;
        }
        
        uint chunkSize = chunkDataToCount(hexPointer,hexLength);
        if (chunkSize == 0)
        {
            m_state = ELastChunk_Ext;
        }
        else
        {
            LOG_DEC(@"chunkSize:%u", chunkSize);
            m_chunkSize = chunkSize;
            m_restSize = m_chunkSize;
            m_state = EChunk_Ext;
        }
    }
    
    void ChunkedStreamDecoder::handleChunk_Ext(const Byte*& chunkedData,uint& chunkedDataLength)
    {
        bool isFinishSkip = skipChunkExtension(chunkedData, chunkedDataLength);
        if (isFinishSkip)
        {
            m_state = EChunk_ExtCRLF;
        }
    }
    
    void ChunkedStreamDecoder::handleChunk_ExtCRLF(const Byte*& chunkedData,uint& chunkedDataLength)
    {
        assert(m_CRLFState == ECRLF);
        m_state = EChunk_Data;
        m_CRLFState = EEmpty;
    }
    
    void ChunkedStreamDecoder::handleChunk_Data(const Byte*& chunkedData,uint& chunkedDataLength)
    {
        assert(m_restSize > 0);
        if (m_tempDataBuffer == NULL)
        {
            m_tempDataBuffer = CFDataCreateMutable(kCFAllocatorDefault, 0);
        }
        if (m_restSize > chunkedDataLength)
        {
            LOG_DEC(@"read %u", chunkedDataLength);
            CFDataAppendBytes(m_tempDataBuffer, chunkedData, chunkedDataLength);
            m_restSize -= chunkedDataLength;
            chunkedData += chunkedDataLength;
            chunkedDataLength = 0;

        }
        else
        {
            LOG_DEC(@"read %u", m_restSize);
            CFDataAppendBytes(m_tempDataBuffer, chunkedData, m_restSize);
            chunkedData += m_restSize;
            chunkedDataLength -= m_restSize;
            m_restSize = 0;
            m_chunkSize = 0;
            m_state = EChunk_DataCRLF;
            m_skipSize = 2;
        }
    }
    
    void ChunkedStreamDecoder::handleChunk_DataCRLF(const Byte*& chunkedData,uint& chunkedDataLength)
    {
        if (m_skipSize > chunkedDataLength)
        {
            m_skipSize -= chunkedDataLength;
            chunkedData += chunkedDataLength;
            chunkedDataLength = 0;
        }
        else
        {
            chunkedData += m_skipSize;
            chunkedDataLength -= m_skipSize;
            m_skipSize = 0;
            m_state = EChunk_Size;
        }
    }
    
    void ChunkedStreamDecoder::handleLastChunk_Ext(const Byte*& chunkedData,uint& chunkedDataLength)
    {
        bool isFinishSkip = skipChunkExtension(chunkedData, chunkedDataLength);
        if (isFinishSkip)
        {
            m_state = ELastChunk_ExtCRLF;
        }
    }
    
    void ChunkedStreamDecoder::handleLastChunk_ExtCRLF(const Byte*& chunkedData,uint& chunkedDataLength)
    {
        assert(m_CRLFState == ECRLF);
        m_state = ETrailer;
        m_CRLFState = EEmpty;
    }
    
    void ChunkedStreamDecoder::handleTrailer(const Byte*& chunkedData,uint& chunkedDataLength)
    {
        switch (m_entityHeaderState)
        {
            case EUnknow:
            {
                uint linkeBreakOffset = DataFinder::findData(chunkedData, chunkedDataLength, KChunkLengthBreak, SizeOfArray(KChunkLengthBreak));
                if (linkeBreakOffset == NSNotFound)
                {
                    if (chunkedData[chunkedDataLength - 1] == '\r')
                    {
                        m_entityHeaderState = EEntityCR;
                    }
                    else
                    {
                        m_entityHeaderState = EEntity;
                    }
                    chunkedData += chunkedDataLength;
                    chunkedDataLength = 0;
                }
                else
                {
                    if(linkeBreakOffset == 0)
                    {
                        m_state = EFinish;
                    }
                    else
                    {
                        m_entityHeaderState = EUnknow;
                    }
                    chunkedData += linkeBreakOffset + SizeOfArray(KChunkLengthBreak);
                    chunkedDataLength -= linkeBreakOffset + SizeOfArray(KChunkLengthBreak);
                }
                
            }
                break;
            case EEntity:
            {
                uint linkeBreakOffset = DataFinder::findData(chunkedData, chunkedDataLength, KChunkLengthBreak, SizeOfArray(KChunkLengthBreak));
                if (linkeBreakOffset == NSNotFound)
                {
                    if (chunkedData[chunkedDataLength - 1] == '\r')
                    {
                        m_entityHeaderState = EEntityCR;
                    }
                    chunkedData += chunkedDataLength;
                    chunkedDataLength = 0;
                }
                else
                {
                    m_entityHeaderState = EUnknow;
                    chunkedData += linkeBreakOffset + SizeOfArray(KChunkLengthBreak);
                    chunkedDataLength -= linkeBreakOffset + SizeOfArray(KChunkLengthBreak);
                }
            }
                break;
            case EEntityCR:
            {
                if (*chunkedData == '\n')//check "\n"
                {
                    m_entityHeaderState = EUnknow;
                    ++chunkedData;
                    --chunkedDataLength;
                }
                else
                {
                    m_entityHeaderState = EEntity;
                    ++chunkedData;
                    --chunkedDataLength;
                }
            }
                break;
            default:
                assert(0);
                break;
        }
    }
    
}