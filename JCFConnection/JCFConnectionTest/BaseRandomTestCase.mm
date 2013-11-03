//
//  BaseRandomTestCase.m
//  JCFConnection
//
//  Created by Jin on 10/31/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "BaseRandomTestCase.h"
#import "JCFConnection.h"
#import "BaseTestCase_Internal.h"

@interface BaseRandomTestCase ()<JCFConnectionDelegate,TestCaseCallDelegate>

@property (nonatomic,retain)JCFConnection* connection;
@property (nonatomic,retain)NSMutableURLRequest* request;
@property (nonatomic,retain)NSMutableData* result;
@property (nonatomic,retain)NSTimer* cancelTimer;

@end

NSString *const KDefaultUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36";

@implementation BaseRandomTestCase


- (id)init
{
    self = [super init];
    if (self) {
        self.callDelegate = self;
    }
    return self;
}
- (void)onWillSendRequest:(NSMutableURLRequest*)request
{
    
}
- (void)setUp
{
    self.result = [NSMutableData dataWithCapacity:4];
    self.request = [[NSMutableURLRequest alloc] init];
    
    
    [self.request setValue:KDefaultUserAgent forHTTPHeaderField:@"User-Agent"];
    
    [self onWillSendRequest:self.request];
    
}

- (void)tearDown
{   
    self.request = nil;
    self.result = nil;
    self.connection = nil;
}


- (void)thread_firstCall
{
    [self startConnection];
    
    self.cancelTimer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(cancelTimerFired) userInfo:nil repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:self.cancelTimer forMode:NSRunLoopCommonModes];
}

- (void)cancelTimerFired
{
    [self.connection cancel];
    
    //1~2 second
    double ranTime = 1 + 1.0f*((arc4random()%100)/100.0f);
    
    self.cancelTimer = [NSTimer timerWithTimeInterval:ranTime target:self selector:@selector(cancelTimerFired) userInfo:nil repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:self.cancelTimer forMode:NSRunLoopCommonModes];
}

- (void)startConnection
{
    self.connection = (JCFConnection*)[JCFConnection connectionWithRequest:self.request delegate:self];
}

- (void)nextConnection
{
    ++self.step;
    [self.delegate testCaseDidSetp:self];
    
    self.result = [[NSMutableData alloc] initWithCapacity:0];
    [self performSelector:@selector(startConnection) withObject:Nil afterDelay:1.0f];
    
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(JCFConnection *)connection
  didFailWithError:(NSError *)error;
{
    [self nextConnection];
}
- (NSURLRequest *)connection:(JCFConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response;
{
    return request;
}

- (void)connection:(JCFConnection *)connection
didReceiveResponse:(NSHTTPURLResponse *)response;
{
    
}

- (void)connection:(JCFConnection *)connection
    didReceiveData:(NSData *)data;
{
    [self.result appendData:data];
}

- (NSCachedURLResponse *)connection:(JCFConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse;
{
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(JCFConnection *)connection;
{
    [self nextConnection];
}

@end
