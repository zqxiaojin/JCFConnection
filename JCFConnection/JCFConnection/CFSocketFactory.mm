//
//  CFSocketFactory.cpp
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#include "CFSocketFactory.h"
#include "CFSocketHandler.h"

namespace J
{
    CFSocketFactory* CFSocketFactory::global()
    {
        static CFSocketFactory* f = new CFSocketFactory();
        return f;
    }
    
    CFSocketHandler* CFSocketFactory::socketWithClient(CFSocketHandlerClient* client)
    {
        return new CFSocketHandler(client);
    }
    
    
    void CFSocketFactory::recycleSocket(CFSocketHandler* socketHandle)
    {
        //FIXME: should resue the socket for keep alive
        socketHandle->release();
    }
}
