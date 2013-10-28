//
//  JTestCaseTableViewDataSource.m
//  JCFConnection
//
//  Created by Jin on 10/28/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "JTestCaseTableViewDataSource.h"

@interface JTestCaseTableViewDataSource ()
@property (nonatomic,retain)NSArray*    dataArray;

@end

@implementation JTestCaseTableViewDataSource

- (instancetype) initWithDataArray:(NSArray*)array
{
    self = [super init];
    if (self)
    {
        self.dataArray = array;
    }
    return self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const KReuseKey = @"JTestCaseTable";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:KReuseKey];
    if (cell == NULL)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KReuseKey];
    }
    cell.textLabel.text = [self.dataArray objectAtIndex:[indexPath indexAtPosition:0]];
    
    return cell;
}

@end
