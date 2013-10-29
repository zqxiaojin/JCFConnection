//
//  BaseTestCase_Internal.h
//  JCFConnection
//
//  Created by Jin on 10/29/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "BaseTestCase.h"


@protocol TestCaseCallDelegate <NSObject>

- (void)setUp;

- (void)tearDown;

- (void)thread_firstCall;

@end

@interface BaseTestCase ()

@property (nonatomic,assign)BOOL isCanceled;
@property (nonatomic,retain)NSThread* thread;
@property (nonatomic,assign)id<TestCaseCallDelegate> callDelegate;

#pragma mark - Util
- (void)setupRunLoop;




@end
