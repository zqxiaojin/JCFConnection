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

@implementation JCFConnection

#pragma mark - public Function
- (instancetype)initWithRequest:(NSURLRequest *)request
                       delegate:(id<JCFConnectionDelegate>)delegate
               startImmediately:(BOOL)startImmediately
{
    m_delegate = delegate;
    m_core = new CFConnectionCore(request,self);
    if (startImmediately)
    {
        m_core->start();
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
    return NULL;//m_core->originalRequest();
}
- (NSURLRequest *)currentRequest
{
    return NULL;//m_core->currentRequest();
}

- (void)start
{
    m_core->start();
}
- (void)cancel
{
    m_core->cancel();
}

//- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
//- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
#pragma mark - for Core CallBack
- (void)connection:(CFConnectionCore *)connection
  didFailWithError:(NSError *)error
{
    [m_delegate connection:self
          didFailWithError:error];
}

- (NSURLRequest *)connection:(CFConnectionCore *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response
{
    return [m_delegate connection:self
           willSendRequest:request
          redirectResponse:response];
}

- (void)connection:(CFConnectionCore *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [m_delegate connection:self
        didReceiveResponse:response];
}

- (void)connection:(CFConnectionCore *)connection
    didReceiveData:(NSData *)data
{
    [m_delegate connection:self
            didReceiveData:data];
}

- (NSCachedURLResponse *)connection:(CFConnectionCore *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return [m_delegate connection:self
         willCacheResponse:cachedResponse];
}

- (void)connectionDidFinishLoading:(CFConnectionCore *)connection;
{
    [m_delegate connectionDidFinishLoading:self];
}
@end
