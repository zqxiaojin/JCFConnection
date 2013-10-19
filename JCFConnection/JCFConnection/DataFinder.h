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
        
        /**
         *	@brief	find the data by Target
         *
         *	@return	return firstMatchOffset if success , NSNotFound if fail;
         */
        uint find();

        
        CFDataRef getDataBuffer() const{return (CFDataRef)m_dataBuffer;}
        
        uint firstMatchOffset()const{return m_firstMatchOffset;}
        
        static uint findData(const Byte* dataToFind, uint dataToFindLength, const Byte* data, uint dataLength);
    protected:
        

        
    protected:
        CFMutableDataRef    m_dataBuffer;
        uint                m_currentIndex;
        uint                m_firstMatchOffset;
        CFDataRef           m_targetData;
    };
}

#endif /* defined(__JCFConnection__DataFinder__) */
