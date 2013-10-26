//
//  JCFConnectionTests.m
//  JCFConnectionTests
//
//  Created by Liang Jin on 10/12/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JCFConnection.h"

enum Progress
{
     EJConnection = 0
    ,ENSURLConnection
};

@interface JCFConnectionTests : XCTestCase<JCFConnectionDelegate>
{
    bool m_isCancelled;
    JCFConnection* m_connection;
    NSMutableData* m_result;
    
    NSMutableURLRequest*  m_request;
    
    Progress m_progress;
    
    NSMutableData* m_resultJCFConnection;
    NSMutableData* m_resultNSURLConnection;
}
@end

@implementation JCFConnectionTests

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
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testChunk
{
    m_result = [NSMutableData dataWithCapacity:4];
    
    
    //    NSURL* url = [NSURL URLWithString:@"http://www.uc.cn"];
    NSURL* url = [NSURL URLWithString:@"http://jigsaw.w3.org/HTTP/ChunkedScript"];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    NSLog(@"start connect %@", url);
    m_request = request;
    //    [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    

    [self performSelector:@selector(startConnection) onThread:[NSThread currentThread] withObject:Nil waitUntilDone:NO];
    
    [self setupRunLoop];
    
    XCTAssertEqualObjects(m_resultJCFConnection,m_resultNSURLConnection, @"data result not the same");
    
    
    NSString* string = [NSString stringWithUTF8String:(const char *)[m_resultJCFConnection bytes]];
    NSLog(@"result :\r\n%@", string);
    
}


- (void)startConnection
{
    switch (m_progress)
    {
        case EJConnection:
        {
            [m_connection release];
            m_connection = (JCFConnection*)[[JCFConnection connectionWithRequest:m_request delegate:self] retain];
        }
            break;
        case ENSURLConnection:
        {
            [m_connection release];
            m_connection = (JCFConnection*)[[NSURLConnection connectionWithRequest:m_request delegate:self] retain];
        }
        default:
            break;
    }
    
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
    switch (m_progress)
    {
        case EJConnection:
        {
            m_resultJCFConnection = m_result;
            m_result = [[NSMutableData alloc] initWithCapacity:0];
            m_progress = ENSURLConnection;
            [self performSelector:@selector(startConnection) withObject:Nil afterDelay:0.0f];
        }
            break;
        case ENSURLConnection:
        {
            m_resultNSURLConnection = m_result;
            m_result = [[NSMutableData alloc] initWithCapacity:0];
            m_isCancelled = true;
        }
        default:
            break;
    }
}

@end
