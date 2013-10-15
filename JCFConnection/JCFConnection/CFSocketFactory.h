//
//  CFSocketFactory.h
//  JCFConnection
//
//  for keep alive
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__CFSocketFactory__
#define __JCFConnection__CFSocketFactory__

namespace J
{
    class CFSocketHandler;
    class CFSocketHandlerClient;
    class CFSocketFactory
    {
    public:
        static CFSocketFactory* global();
        
    public:
        CFSocketHandler* socketWithClient(CFSocketHandlerClient* client);
    };
}

#endif /* defined(__JCFConnection__CFSocketFactory__) */
