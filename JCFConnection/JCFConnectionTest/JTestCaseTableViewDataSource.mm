//
//  JTestCaseTableViewDataSource.m
//  JCFConnection
//
//  Created by Jin on 10/28/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "JTestCaseTableViewDataSource.h"
#import "JTestCaseDataItem.h"
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
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.frame = CGRectMake(0, 0, 32, 32);
        cell.accessoryView = spinner;
    }
    JTestCaseDataItem* item = [self.dataArray objectAtIndex:[indexPath row]];
    
    if (item.step == 0)
    {
        cell.textLabel.text = item.title;
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %d", item.title , item.step];
    }
    
    
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)cell.accessoryView;
    if (item.state == ETestCaseDataItemState_Running)
    {
        [spinner startAnimating];
    }
    else
    {
        [spinner stopAnimating];
    }
    switch (item.state)
    {
        case ETestCaseDataItemState_Pass:
            [cell setBackgroundColor:[UIColor greenColor]];
            break;
        case ETestCaseDataItemState_Fail:
            [cell setBackgroundColor:[UIColor redColor]];
        default:
            break;
    }
    return cell;
}

@end
