//
//  DataFinder.cpp
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "DataFinder.h"


namespace J
{
    DataFinder::DataFinder()
    :m_currentIndex(0)
    ,m_dataBuffer(CFDataCreateMutable(kCFAllocatorDefault, 0))
    ,m_targetData(NULL)
    ,m_firstMatchOffset(NSNotFound)
    {
        
    }
    DataFinder::~DataFinder()
    {
        CFRelease(m_targetData);
        CFRelease(m_dataBuffer);
    }
    void DataFinder::appendData(CFDataRef data)
    {
        CFDataAppendBytes(m_dataBuffer, CFDataGetBytePtr(data), CFDataGetLength(data));
    }
    
    uint DataFinder::find()
    {
        uint dataLength = CFDataGetLength(m_dataBuffer);
        uint targetLength = CFDataGetLength(m_targetData);
        if (dataLength < targetLength || targetLength == 0)
        {
            return kCFNotFound;
        }
        Byte* target = (Byte*)CFDataGetBytePtr(m_targetData);
        Byte* bufferStart = (Byte*)CFDataGetBytePtr(m_dataBuffer) + m_currentIndex;
        Byte* buffer = bufferStart;
        bool isMatch = false;
        Byte* bufferEnd = buffer + dataLength - m_currentIndex - targetLength;
        for (;
             buffer < bufferEnd;
             ++buffer)
        {
            isMatch = true;
            for (uint i = 0 , ic = targetLength; i < ic ; ++i)
            {
                if (buffer[i] != target[i])
                {
                    isMatch = false;
                    break;
                }
            }
            if (isMatch)
            {
                break;
            }
        }
        
        if (isMatch)
        {
            m_firstMatchOffset = buffer - bufferStart + targetLength;
            return m_firstMatchOffset;
        }
        else
        {
            m_currentIndex += dataLength - targetLength + 1;
            return kCFNotFound;
        }
        
    }
    
    void DataFinder::setTargetData(CFDataRef targetData)
    {
        assert(m_targetData != targetData);
        if (m_targetData)
        {
            CFRelease(m_targetData);
        }
        m_targetData = (CFDataRef)CFRetain(targetData);
        
    }
}