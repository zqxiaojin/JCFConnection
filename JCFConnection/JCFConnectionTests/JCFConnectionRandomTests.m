//
//  JCFConnectionRandomTests.m
//  JCFConnection
//
//  Created by Jin on 10/27/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JCFConnection.h"

NSString *const KDefaultUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36";

@interface JCFConnectionRandomTests : XCTestCase<JCFConnectionDelegate>
{
    bool                    m_isCancelled;
}

@property (nonatomic,retain) NSMutableURLRequest*   request;
@property (nonatomic,retain) JCFConnection*         connection;

@property (nonatomic,retain) NSTimer*               randomCancelTimer;

@end

@implementation JCFConnectionRandomTests
@synthesize request = m_request;
@synthesize connection = m_connection;
@synthesize randomCancelTimer = m_randomCancelTimer;

- (void)setupRunLoop
{
    // 添加一个port，让runloop有事做，否则在runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]时会立刻返回，不会阻塞，从而消耗CPU。
    NSPort *port = [[NSMachPort alloc] init];
    [[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
    
    m_isCancelled = false;
	while (!m_isCancelled)
	{
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		// 这里会阻塞，直到这个线程/runloop有事件触发
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        [pool drain];
	}
    
    [port release];
}

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    
    self.request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    [self startTimer];
}

- (void)startTimer
{
    [self.randomCancelTimer invalidate];
    
    int magic = arc4random();
    double internal = (magic%10);
    
    self.randomCancelTimer = [[[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:internal]
                                                       interval:0.0f
                                                         target:self
                                                       selector:@selector(timerFired)
                                                       userInfo:nil
                                                        repeats:NO] autorelease];
    
    [[NSRunLoop currentRunLoop] addTimer:self.randomCancelTimer forMode:NSRunLoopCommonModes];
}

- (void)timerFired
{
    [self.connection cancel];
    [self startConnection];
    [self startTimer];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    NSURL* url = [NSURL URLWithString:@"http://www.ucweb.com/"];
    [m_request setURL:url];
    
    [m_request setValue:KDefaultUserAgent forHTTPHeaderField:@"User-Agent"];
    [m_request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSLog(@"start connect %@", url);
    
    [self performSelector:@selector(startConnection)
                 onThread:[NSThread currentThread]
               withObject:Nil
            waitUntilDone:NO];
    
    [self setupRunLoop];
}
- (void)nextConnection
{
    [self performSelector:@selector(startConnection) withObject:Nil afterDelay:0.0f];
}

- (void)startConnection
{
    self.connection = [[JCFConnection connectionWithRequest:m_request delegate:self] retain];
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
