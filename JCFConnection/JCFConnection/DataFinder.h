//
//  DataFinder.h
//  JCFConnection
//
//  Created by Liang Jin on 10/14/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#ifndef __JCFConnection__DataFinder__
#define __JCFConnection__DataFinder__

namespace J
{
    class DataFinder
    {
    public:
        DataFinder();
        ~DataFinder();
        
        void setTargetData(CFDataRef targetData);
        
        void appendData(CFDataRef data);
        
        uint find();
        
        Byte* getBytePtr();
        
    protected:
        CFMutableDataRef    m_responseDataBuffer;
        uint                m_currentIndex;
        
        CFDataRef           m_targetData;
    };
}

#endif /* defined(__JCFConnection__DataFinder__) */
