//
//  BaseTestListViewController.h
//  JCFConnection
//
//  Created by Jin on 10/31/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTestListViewController : UIViewController

@property (nonatomic,retain)NSMutableArray* dataArray;//JTestCaseDataItem

- (void)buildTestDataArray;

@end
