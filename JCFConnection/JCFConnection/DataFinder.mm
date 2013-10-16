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
    ,m_responseDataBuffer(CFDataCreateMutable(kCFAllocatorDefault, 0))
    ,m_targetData(NULL)
    {
        
    }
    DataFinder::~DataFinder()
    {
        CFRelease(m_targetData);
        CFRelease(m_responseDataBuffer);
    }
    void DataFinder::appendData(CFDataRef data)
    {
        CFDataAppendBytes(m_responseDataBuffer, CFDataGetBytePtr(data), CFDataGetLength(data));
    }
    
    uint DataFinder::find()
    {
        uint dataLength = CFDataGetLength(m_responseDataBuffer);
        uint targetLength = CFDataGetLength(m_targetData);
        if (dataLength < targetLength)
        {
            return kCFNotFound;
        }
        CFRange result = CFDataFind(m_responseDataBuffer
                   , m_targetData
                   , CFRangeMake(m_currentIndex, dataLength - m_currentIndex)
                   , kCFDataSearchBackwards);
        
        if (result.location == kCFNotFound)
        {
            m_currentIndex += dataLength - targetLength + 1;
            return kCFNotFound;
        }
        else
        {
            return result.location + targetLength;
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