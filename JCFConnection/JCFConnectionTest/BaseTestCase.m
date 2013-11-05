//
//  BaseTestCase.m
//  JCFConnection
//
//  Created by Jin on 10/29/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "BaseTestCase.h"
#import "BaseTestCase_Internal.h"
@implementation BaseTestCase
@synthesize isCanceled = m_isCancelled;

- (void)start
{
    if (self.thread == NULL)
    {
        
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
    [self.thread setName:@"TestThread"];
    
    [(id)self.delegate performSelectorOnMainThread:@selector(testCaseDidStart:) withObject:self waitUntilDone:YES];
    [self.callDelegate setUp];
    
    [self performSelector:@selector(thread_firstCall)
                 onThread:[NSThread currentThread]
               withObject:Nil
            waitUntilDone:NO];
    
    [self setupRunLoop];
    
    [self.callDelegate tearDown];
    
      [(id)self.delegate performSelectorOnMainThread:@selector(testCaseDidFinish:) withObject:self waitUntilDone:YES];
}

@end
