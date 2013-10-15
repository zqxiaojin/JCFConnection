//
//  ResponseParser.cpp
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "ResponseParser.h"


namespace J
{
    ResponseParser::ResponseParser()
    :m_state(WaitForData)
    {
        
    }
    ResponseParser::~ResponseParser()
    {
        
    }
    uint ResponseParser::appendData(CFDataRef data)
    {
        return 0;
    }
}