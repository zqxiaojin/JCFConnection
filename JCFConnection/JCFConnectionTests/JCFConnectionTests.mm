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

NSString *const KDefaultUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36";

@interface JCFConnectionTests : XCTestCase<JCFConnectionDelegate>
{
    bool           m_isCancelled;
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
    
    m_result = [NSMutableData dataWithCapacity:4];
    m_request = [[NSMutableURLRequest alloc] init];
    m_progress = EJConnection;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [m_request release];
    [m_result release];
    [m_connection release];
    
    NSString* string = [NSString stringWithUTF8String:(const char *)[m_resultNSURLConnection bytes]];
    if (string == NULL)
    {
        string = [[NSString alloc] initWithBytes:[m_resultNSURLConnection bytes]
                                                 length:[m_resultNSURLConnection length]
                                                 encoding:NSISOLatin1StringEncoding];
        [string autorelease];
    }
    NSLog(@"result :\r\n%@", string);
}

- (void)testChunk
{
    NSURL* url = [NSURL URLWithString:@"http://jigsaw.w3.org/HTTP/ChunkedScript"];
    [m_request setURL:url];
    
    [m_request setValue:KDefaultUserAgent forHTTPHeaderField:@"User-Agent"];
    [m_request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSLog(@"start connect %@", url);

    [self performSelector:@selector(startConnection)
                 onThread:[NSThread currentThread]
               withObject:Nil
            waitUntilDone:NO];
    
    [self setupRunLoop];
    
    XCTAssertEqualObjects(m_resultJCFConnection,m_resultNSURLConnection, @"data result not the same");

}

- (void)testGzip
{
    
    NSURL* url = [NSURL URLWithString:@"http://zlib.net/zpipe.c"];
    [m_request setURL:url];
    
    [m_request setValue:KDefaultUserAgent forHTTPHeaderField:@"User-Agent"];
    
    [m_request setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSLog(@"start connect %@", url);
    
    [self performSelector:@selector(startConnection)
                 onThread:[NSThread currentThread]
               withObject:Nil
            waitUntilDone:NO];
    
    [self setupRunLoop];
    
    XCTAssertEqualObjects(m_resultJCFConnection,m_resultNSURLConnection, @"data result not the same");
}

- (void)testGzipAndChunk
{
    //test case from http://www.cnts.ua.ac.be/conll2000/chunking/
    NSURL* url = [NSURL URLWithString:@"http://www.cnts.ua.ac.be/conll2000/chunking/test.txt.gz"];
    [m_request setURL:url];
    
    [m_request setValue:KDefaultUserAgent forHTTPHeaderField:@"User-Agent"];
    
    [m_request setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [m_request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [m_request setValue:@"en-us" forHTTPHeaderField:@"Accept-Language"];
    [m_request setValue:@"Close" forHTTPHeaderField:@"Connection"];
    [m_request setValue:nil forHTTPHeaderField:@"Cookie"];
    NSLog(@"start connect %@", url);
    
    [self performSelector:@selector(startConnection)
                 onThread:[NSThread currentThread]
               withObject:Nil
            waitUntilDone:NO];
    
    [self setupRunLoop];
    
    
    XCTAssert([m_resultJCFConnection isEqualToData:m_resultNSURLConnection], @"data result not the same");
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

- (void)nextConnection
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


#pragma mark - NSURLConnectionDelegate

- (void)connection:(JCFConnection *)connection
  didFailWithError:(NSError *)error;
{
    assert(0);
    NSLog(@"error : %@", error);
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
    [m_result appendData:data];
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
