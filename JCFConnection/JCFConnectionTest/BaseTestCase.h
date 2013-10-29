//
//  BaseTestCase.h
//  JCFConnection
//
//  Created by Jin on 10/29/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseTestCase;

@protocol TestCaseDelegate <NSObject>

- (void)testCaseDidStart:(BaseTestCase*)testCase;

- (void)testCaseDidFinish:(BaseTestCase*)testCase;

@end



@interface BaseTestCase : NSObject


@property (nonatomic,assign)id<TestCaseDelegate> delegate;
@property (nonatomic,assign)BOOL isPass;

- (void)start;


@end
