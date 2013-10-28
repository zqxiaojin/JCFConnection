//
//  GzipTestCase.m
//  JCFConnection
//
//  Created by Jin on 10/28/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "GzipTestCase.h"
#import "JCFConnection.h"


enum Progress
{
    EJConnection = 0
    ,ENSURLConnection
};

NSString *const KDefaultUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36";


@interface GzipTestCase ()<JCFConnectionDelegate>
{
    bool            m_isCancelled;
    Progress        m_progress;
}

@property (nonatomic,retain)NSThread* thread;
@property (nonatomic,retain)JCFConnection* connection;
@property (nonatomic,retain)NSMutableURLRequest* request;
@property (nonatomic,retain)NSMutableData* result;
@property (nonatomic,retain)NSMutableData* resultJCFConnection;
@property (nonatomic,retain)NSMutableData* resultNSURLConnection;

@end


@implementation GzipTestCase


- (void)start
{
    if (self.thread == NULL)
    {
        [self setUp];
        self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(thread_run) object:nil];
        [self.thread start];
    }
}


- (void)setupRunLoop
{
    // 添加一个port，让runloop有事做，否则在runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]时会立刻返回，不会阻塞，从而消耗CPU。
    NSPort *port = [[NSMachPort alloc] init];
    [[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
    
    m_isCancelled = false;
	while (!m_isCancelled)
	{
		// 这里会阻塞，直到这个线程/runloop有事件触发
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
	}
    
}



- (void)thread_run
{
    NSURL* url = [NSURL URLWithString:@"http://zlib.net/zpipe.c"];
    [self.request setURL:url];
    
    [self.request setValue:KDefaultUserAgent forHTTPHeaderField:@"User-Agent"];
    
    [self.request setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSLog(@"start connect %@", url);
    
    [self performSelector:@selector(startConnection)
                 onThread:[NSThread currentThread]
               withObject:Nil
            waitUntilDone:NO];
    
    [self setupRunLoop];
    
    assert([self.resultJCFConnection isEqualToData:self.resultNSURLConnection]);
    
    [self tearDown];
}


- (void)setUp
{
    
    self.result = [NSMutableData dataWithCapacity:4];
    self.request = [[NSMutableURLRequest alloc] init];
    m_progress = EJConnection;
}

- (void)tearDown
{
    
    self.request = nil;
    self.result = nil;
    self.connection = nil;
    
    NSString* string = [NSString stringWithUTF8String:(const char *)[self.resultJCFConnection bytes]];
    if (string == NULL)
    {
        string = [[NSString alloc] initWithBytes:[self.resultJCFConnection bytes]
                                          length:[self.resultJCFConnection length]
                                        encoding:NSISOLatin1StringEncoding];
    }
    NSLog(@"result :\r\n%@", string);
}


- (void)startConnection
{
    switch (m_progress)
    {
        case EJConnection:
        {
            self.connection = (JCFConnection*)[JCFConnection connectionWithRequest:self.request delegate:self];
        }
            break;
        case ENSURLConnection:
        {
            self.connection = (JCFConnection*)[NSURLConnection connectionWithRequest:self.request delegate:self];
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
            self.resultJCFConnection = self.result;
            self.result = [[NSMutableData alloc] initWithCapacity:0];
            m_progress = ENSURLConnection;
            [self performSelector:@selector(startConnection) withObject:Nil afterDelay:0.0f];
        }
            break;
        case ENSURLConnection:
        {
            self.resultNSURLConnection = self.result;
            self.result = [[NSMutableData alloc] initWithCapacity:0];
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
