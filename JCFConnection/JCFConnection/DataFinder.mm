//
//  DataFinder.cpp
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "DataFinder.h"
#include "HTTPDefine.h"

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
        uint bufferStartMatchOffset = DataFinder::findData(bufferStart, dataLength - m_currentIndex, target, targetLength);
        
        if (bufferStartMatchOffset != NSNotFound)
        {
            m_firstMatchOffset = m_currentIndex + bufferStartMatchOffset + targetLength;
            return m_firstMatchOffset;
        }
        else
        {
            m_currentIndex += dataLength - targetLength + 1;
            return kCFNotFound;
        }
        
    }
    uint DataFinder::findNotHexData(const Byte* dataToFind, uint dataToFindLength)
    {
        assert(dataToFind );
        const Byte* buffer = dataToFind;
        bool isMatch = false;
        const Byte* bufferEnd = buffer + dataToFindLength ;
        while (buffer <= bufferEnd)
        {
            if (!isHexChar(*buffer))
            {
                isMatch = true;
                break;
            }
            ++buffer;
        }
        if (isMatch)
        {
            return buffer - dataToFind;
        }
        return NSNotFound;
    }
    
    uint DataFinder::findData(const Byte* dataToFind, uint dataToFindLength, const Byte* data, uint dataLength)
    {
        assert(dataToFind && data);
        const Byte* buffer = dataToFind;
        bool isMatch = false;
        const Byte* bufferEnd = buffer + dataToFindLength - dataLength;
        for (;
             buffer <= bufferEnd;
             ++buffer)
        {
            isMatch = true;
            for (uint i = 0 , ic = dataLength; i < ic ; ++i)
            {
                if (buffer[i] != data[i])
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
            return buffer - dataToFind;
        }
        return NSNotFound;
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