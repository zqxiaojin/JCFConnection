//
//  ResponseParser.cpp
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "ResponseParser.h"
#include "DataFinder.h"

namespace J
{
    ResponseParser::ResponseParser()
    :m_state(WaitForData)
    ,m_dataFinder(new DataFinder())
    {
        CFDataRef bodyEOF = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)"\r\n\r\n", 4, kCFAllocatorNull);
        m_dataFinder->setTargetData(bodyEOF);
        CFRelease(bodyEOF);
    }
    ResponseParser::~ResponseParser()
    {
        delete m_dataFinder;
    }
    uint ResponseParser::appendData(CFDataRef data)
    {
        m_dataFinder->appendData(data);
        uint result = m_dataFinder->find();
        if (result != kCFNotFound)
        {
            //TODO: parse Response HTTP Header
            
            m_state = Done;
        }
        return result;
    }
}