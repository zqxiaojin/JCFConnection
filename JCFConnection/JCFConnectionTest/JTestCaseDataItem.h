//
//  JTestCaseDataItem.h
//  JCFConnection
//
//  Created by Jin on 10/29/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseTestCase;

enum JTestCaseDataItemState
{
    ETestCaseDataItemState_Idle = 0
    ,ETestCaseDataItemState_Running
    ,ETestCaseDataItemState_Pass
    ,ETestCaseDataItemState_Fail
};

@interface JTestCaseDataItem : NSObject

@property (nonatomic,assign)SEL selector;
@property (nonatomic,assign)int index;
@property (nonatomic,strong)NSString* title;
@property (nonatomic,assign)JTestCaseDataItemState state;
@property (nonatomic,strong)BaseTestCase* testCase;
@property (nonatomic,assign)Class testClass;
@end
