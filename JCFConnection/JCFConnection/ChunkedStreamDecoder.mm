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
    
    ChunkedStreamDecoder::ChunkedStreamDecoder()
    :m_orgDataBuffer(CFDataCreateMutable(kCFAllocatorDefault, 0))
    ,m_chunkSize(0)
    ,m_restSize(0)
    ,m_state(EWaitingChunkCount)
    ,m_skipSize(0)
    {
        
    }
    ChunkedStreamDecoder::~ChunkedStreamDecoder()
    {
        if (m_orgDataBuffer) {
            CFRelease(m_orgDataBuffer);
        }
    }
    
    CFDataRef ChunkedStreamDecoder::decode(CFDataRef chunkedData)
    {
        CFMutableDataRef result = NULL;
        COMPILE_ASSERT(sizeof(short) == 2);
        const Byte* chunkedDataStartPtr = CFDataGetBytePtr(chunkedData);
        const Byte* chunkedDataPtr = chunkedDataStartPtr;
        uint chunkedDataLength = CFDataGetLength(chunkedData);
        uint chunkedDataRestLength = chunkedDataLength;
        while (chunkedDataRestLength != 0)
        {
            switch (m_state)
            {
                case EWaitingChunkCount:
                {
                    handleWaitingChunkCount(chunkedDataPtr,chunkedDataRestLength);
                }
                    break;
                case EReadingData:
                {
                    if (result == NULL) {
                        result = CFDataCreateMutable(kCFAllocatorDefault, 0);
                        Util::CFAutoRelease(result);
                    }
                    handleReadingData(result, chunkedDataPtr, chunkedDataRestLength);
                }
                    break;
                case ESkipDataBreak:
                {
                    handleSkipDataBreak(chunkedDataPtr, chunkedDataRestLength);
                }
                    break;
                case EError:
                {
                    chunkedDataLength = 0;
                }
                    break;
                default:
                    break;
            }
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
        LOG_DEC(@"%@ -> %x == %u" , [[[NSString alloc] initWithBytes:data length:dataLength encoding:NSUTF8StringEncoding] autorelease] , orgDataLength, orgDataLength);
        return orgDataLength;
    }
    
    void ChunkedStreamDecoder::handleWaitingChunkCount(const Byte*& chunkedData,uint& chunkedDataLength)
    {
        assert(chunkedDataLength > 0);
        uint unuseBufferLength = CFDataGetLength(m_orgDataBuffer);
        if (unuseBufferLength > 0)
        {
            const Byte* orgDataPtr = CFDataGetBytePtr(m_orgDataBuffer);
            const Byte* lastChar = orgDataPtr + unuseBufferLength - 1;
            if (*lastChar == '\r')///last we get "\r"
            {
                if (*chunkedData == '\n')//check "\n"
                {
                    if (unuseBufferLength == 1)///<just a "\r\n" ,so finish
                    {
                        CFDataSetLength(m_orgDataBuffer, 0);
                        m_state = EFinish;
                    }
                    else
                    {
                        uint orgDataLength = chunkDataToCount(orgDataPtr , unuseBufferLength -1);
                        m_chunkSize = orgDataLength;
                        m_restSize = m_chunkSize;
                        chunkedData += 1;
                        chunkedDataLength -= 1;
                        
                        if (orgDataLength == 0)///<chunk size can be zero
                        {
                            m_state = EWaitingChunkCount;
                        }
                        else
                        {
                            CFDataSetLength(m_orgDataBuffer, 0);
                            m_state = EReadingData;
                        }
                    }
                }
                else
                {
                    m_state = EError;
                }
            }
            else///<has some byte of chunksize
            {
                uint linkeBreakOffset = DataFinder::findData(chunkedData, chunkedDataLength, KChunkLengthBreak, SizeOfArray(KChunkLengthBreak));
                if (linkeBreakOffset == NSNotFound) {
                    CFDataAppendBytes(m_orgDataBuffer, chunkedData, chunkedDataLength);
                    chunkedData += chunkedDataLength;
                    chunkedDataLength = 0;
                }
                else//get the "\r\n" , so we can get the size
                {
                    CFDataAppendBytes(m_orgDataBuffer, chunkedData, linkeBreakOffset);
                    
                    uint orgDataLength = chunkDataToCount(CFDataGetBytePtr(m_orgDataBuffer)
                                                          , CFDataGetLength(m_orgDataBuffer));
                    
                    m_chunkSize = orgDataLength;
                    m_restSize = m_chunkSize;
                    chunkedData += linkeBreakOffset + SizeOfArray(KChunkLengthBreak);
                    chunkedDataLength -= linkeBreakOffset+ SizeOfArray(KChunkLengthBreak);
                    if (orgDataLength == 0)///<chunk size can be zero
                    {
                        m_state = EWaitingChunkCount;
                    }
                    else
                    {
                        CFDataSetLength(m_orgDataBuffer, 0);
                        m_state = EReadingData;
                    }
                }
            }
        }
        else
        {
            uint linkeBreakOffset = DataFinder::findData(chunkedData, chunkedDataLength, KChunkLengthBreak, SizeOfArray(KChunkLengthBreak));
            if (linkeBreakOffset == NSNotFound) {
                CFDataAppendBytes(m_orgDataBuffer, chunkedData, chunkedDataLength);
                chunkedData += chunkedDataLength;
                chunkedDataLength = 0;
            }
            else//get the "\r\n" , so we can get the size
            {
                if (linkeBreakOffset == 0)
                {
                    chunkedData += 2;
                    chunkedDataLength -= 2;
                    m_state = EFinish;
                }
                else
                {
                    CFDataAppendBytes(m_orgDataBuffer, chunkedData, linkeBreakOffset);
                    
                    uint orgDataLength = chunkDataToCount(CFDataGetBytePtr(m_orgDataBuffer)
                                                          , CFDataGetLength(m_orgDataBuffer));
                    
                    if (orgDataLength == 0)///<chunk size can be zero
                    {
                        m_state = EWaitingChunkCount;
                    }
                    else
                    {
                        m_state = EReadingData;
                    }
                    
                    m_chunkSize = orgDataLength;
                    m_restSize = m_chunkSize;
                    chunkedData += linkeBreakOffset + SizeOfArray(KChunkLengthBreak);
                    chunkedDataLength -= linkeBreakOffset + SizeOfArray(KChunkLengthBreak);
                    CFDataSetLength(m_orgDataBuffer, 0);
                }
            }
        }
    }
    
    void ChunkedStreamDecoder::handleReadingData(CFMutableDataRef bufferToAppend
                                                 ,const Byte*& chunkedData,uint& chunkedDataLength)
    {
        assert(m_restSize > 0);
        if (m_restSize > chunkedDataLength)
        {
            LOG_DEC(@"read %u", chunkedDataLength);
            CFDataAppendBytes(bufferToAppend, chunkedData, chunkedDataLength);
            m_restSize -= chunkedDataLength;
            chunkedData += chunkedDataLength;
            chunkedDataLength = 0;
            
        }
        else
        {
            LOG_DEC(@"read %u", m_restSize);
            CFDataAppendBytes(bufferToAppend, chunkedData, m_restSize);
            chunkedData += m_restSize;
            chunkedDataLength -= m_restSize;
            m_restSize = 0;
            m_state = ESkipDataBreak;
            m_skipSize = 2;
        }
    }
    
    void ChunkedStreamDecoder::handleSkipDataBreak(const Byte*& chunkedData,uint& chunkedDataLength)
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
            m_state = EWaitingChunkCount;
        }
    }
}