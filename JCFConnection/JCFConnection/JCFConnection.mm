//
//  JCFConnection.m
//  JCFConnection
//
//  Created by Liang Jin on 10/12/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "JCFConnection.h"
#import "CFConnectionCore.h"
#import "JCFConnection_Internal.h"
#include "Util.h"

#define PROTECTSELF()   {J::Util::CFAutoRelease(CFRetain(self));}

@implementation JCFConnection

#pragma mark - public Function
- (instancetype)initWithRequest:(NSURLRequest *)request
                       delegate:(id<JCFConnectionDelegate>)delegate
               startImmediately:(BOOL)startImmediately
{
    self = [super init];
    if (self)
    {
        m_delegate = [delegate retain];
        m_core = new CFConnectionCore(request,self);
        if (startImmediately)
        {
            m_core->start();
        }
    }
    return self;
}
- (instancetype)initWithRequest:(NSURLRequest *)request
                       delegate:(id<JCFConnectionDelegate>)delegate
{
    return [self initWithRequest:request delegate:delegate startImmediately:YES];
}

- (void)dealloc
{
    delete m_core;
    [super dealloc];
}
+ (JCFConnection*)connectionWithRequest:(NSURLRequest *)request
                               delegate:(id<JCFConnectionDelegate>)delegate
{
    return [[[JCFConnection alloc] initWithRequest:request delegate:delegate] autorelease];
}

- (NSURLRequest *)originalRequest
{
    return m_core->originalRequest();
}
- (NSURLRequest *)currentRequest
{
    return m_core->currentRequest();
}

- (void)start
{
    m_core->start();
}
- (void)cancel
{
    if (!m_isTerminal)
    {
        m_core->cancel();
        m_isTerminal = true;
        [m_delegate autorelease];
        m_delegate = NULL;
    }
}

//- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
//- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
#pragma mark - for Core CallBack
- (void)connection:(CFConnectionCore *)connection
  didFailWithError:(NSError *)error
{
    PROTECTSELF();
    if (!m_isTerminal)
    {
        [m_delegate connection:self
              didFailWithError:error];
        [self cancel];
    }

}

- (NSURLRequest *)connection:(CFConnectionCore *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response
{
    PROTECTSELF();
    return [m_delegate connection:self
           willSendRequest:request
          redirectResponse:response];
}

- (void)connection:(CFConnectionCore *)connection
didReceiveResponse:(NSURLResponse *)response
{
    PROTECTSELF();
    [m_delegate connection:self
        didReceiveResponse:response];
}

- (void)connection:(CFConnectionCore *)connection
    didReceiveData:(NSData *)data
{
    PROTECTSELF();
    [m_delegate connection:self
            didReceiveData:data];
}

- (NSCachedURLResponse *)connection:(CFConnectionCore *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    PROTECTSELF();
    return [m_delegate connection:self
         willCacheResponse:cachedResponse];
}

- (void)connectionDidFinishLoading:(CFConnectionCore *)connection;
{
    PROTECTSELF();
    if (!m_isTerminal)
    {
        [m_delegate connectionDidFinishLoading:self];
         [self cancel];
    }
    
}
@end
