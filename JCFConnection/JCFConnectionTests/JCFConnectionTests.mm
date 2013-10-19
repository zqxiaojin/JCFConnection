//
//  JCFConnectionTests.m
//  JCFConnectionTests
//
//  Created by Liang Jin on 10/12/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JCFConnection.h"
@interface JCFConnectionTests : XCTestCase<JCFConnectionDelegate>
{
    bool m_isCancelled;
    JCFConnection* m_connection;
    NSMutableData* m_result;
}
@end

@implementation JCFConnectionTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    m_result = [NSMutableData dataWithCapacity:4];

    // 添加一个port，让runloop有事做，否则在runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]时会立刻返回，不会阻塞，从而消耗CPU。
    NSPort *port = [[NSMachPort alloc] init];
    [[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
    
    [self performSelector:@selector(startConnection) onThread:[NSThread currentThread] withObject:Nil waitUntilDone:NO];
    
    m_isCancelled = false;
	while (!m_isCancelled)
	{
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		// 这里会阻塞，直到这个线程/runloop有事件触发
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        [pool drain];
	}
    
    NSString* string = [NSString stringWithUTF8String:(const char *)[m_result bytes]];
    NSLog(@"result :\r\n%@", string);
}

- (void)startConnection
{
    
//    NSURL* url = [NSURL URLWithString:@"http://www.uc.cn"];
    NSURL* url = [NSURL URLWithString:@"http://cn.bing.com/search?q=zq&go=&qs=n&form=QBLH&pq=zq&sc=8-0&sp=-1&sk="];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
//    m_connection = (JCFConnection*)[[NSURLConnection connectionWithRequest:request delegate:self] retain];
    m_connection = (JCFConnection*)[[JCFConnection connectionWithRequest:request delegate:self] retain];
    
    NSLog(@"start connect %@", url);
}

- (void)connection:(JCFConnection *)connection
  didFailWithError:(NSError *)error;
{
    NSLog(@"error : %@", error);
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
    [m_result appendData:data];
}

- (NSCachedURLResponse *)connection:(JCFConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse;
{
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(JCFConnection *)connection;
{
    m_isCancelled = true;
}

@end
