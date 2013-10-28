//
//  JTestCaseTableViewDataSource.h
//  JCFConnection
//
//  Created by Jin on 10/28/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JTestCaseTableViewDataSource : NSObject<UITableViewDataSource>

- (instancetype) initWithDataArray:(NSArray*)array;

@end
