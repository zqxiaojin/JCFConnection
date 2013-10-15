//
//  DataArrayReader.cpp
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "DataArrayReader.h"


namespace J
{
    DataArrayReader::DataArrayReader()
    :m_dataArray(CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks))
    {
        
    }
    DataArrayReader::~DataArrayReader()
    {
        CFRelease(m_dataArray);
    }
    void DataArrayReader::appendData(CFDataRef data)
    {
        CFArrayAppendValue(m_dataArray, data);
    }
    
    uint DataArrayReader::locationOfBytes(uint offset, Byte* bytes, uint length)
    {
        return -1;
    }
    
    uint DataArrayReader::dataIndexAtOffSet(uint offset)
    {
        uint result = 0;
        uint datalength = 0;
        CFDataRef data = NULL;
        for (uint i = 0 , ic = CFArrayGetCount(m_dataArray); i < ic ; ++i)
        {
            data = (CFDataRef)CFArrayGetValueAtIndex(m_dataArray, i);
            if (data)
            {
                datalength += CFDataGetLength(data);
                if (datalength > offset)
                {
                    result = i;
                    break;
                }
            }
        }
        return result;
    }
}