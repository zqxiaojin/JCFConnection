//
//  BaseTestListViewController.m
//  JCFConnection
//
//  Created by Jin on 10/31/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "BaseTestListViewController.h"
#import "JTestCaseTableViewDataSource.h"
#import "JTestCaseDataItem.h"
#import "BaseTestCase.h"

@interface BaseTestListViewController ()<UITableViewDelegate,TestCaseDelegate>


@property (nonatomic,retain)UITableView*   testCaseTableView;
@property (nonatomic,retain)JTestCaseTableViewDataSource* tableViewDatasource;

@property (nonatomic,retain)id currentTestCase;

@property (nonatomic,assign)BOOL isAutoRuning;



@end

@implementation BaseTestListViewController

@synthesize testCaseTableView = m_testCaseTableView;
@synthesize tableViewDatasource = m_tableViewDatasource;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.testCaseTableView.dataSource = nil;
    self.testCaseTableView.delegate = nil;
}

- (void)buildTestDataArray
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self buildTestDataArray];
    
    self.testCaseTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.testCaseTableView.delegate = self;
    self.testCaseTableView.autoresizesSubviews = YES;
    self.testCaseTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ;
    
    self.tableViewDatasource = [[JTestCaseTableViewDataSource alloc] initWithDataArray:self.dataArray];
    self.testCaseTableView.dataSource = self.tableViewDatasource;
    [self.view addSubview:self.testCaseTableView];
    
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setTitle: @"Run All Tests" forState: UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(runAllTest) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = button;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)runAllTest
{
    self.isAutoRuning = YES;
    [self startCaseAtIndex:0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self startCaseAtIndex:[indexPath row]];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
    
    
}

- (JTestCaseDataItem*)itemOfTestCase:(BaseTestCase*)testCase
{
    JTestCaseDataItem* item = NULL;
    for (JTestCaseDataItem* aItem in self.dataArray)
    {
        if (aItem.testCase == testCase)
        {
            item = aItem;
            break;
        }
    }
    return item;
}
- (void)reloadRowAtIndex:(int)index
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.testCaseTableView beginUpdates];
    [self.testCaseTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.testCaseTableView endUpdates];
}

#pragma mark - testCase

- (void)startCaseAtIndex:(int)index
{
    JTestCaseDataItem* item = [self.dataArray objectAtIndex:index];
    
    [self startCase:item];
}

- (void)startCase:(JTestCaseDataItem*)item
{
    if (item.testCase)
    {
        return;
    }
    BaseTestCase* testCase = [[item.testClass alloc] init];
    [testCase start];
    testCase.delegate = self;
    item.testCase = testCase;
}

#pragma mark - TestCaseDelegate
- (void)testCaseDidStart:(BaseTestCase*)testCase
{
    JTestCaseDataItem* item = [self itemOfTestCase:testCase];
    item.state = ETestCaseDataItemState_Running;
    [self reloadRowAtIndex:item.index];
}

- (void)testCaseDidSetp:(BaseTestCase *)testCase
{
    JTestCaseDataItem* item = [self itemOfTestCase:testCase];
    item.step = testCase.step;
    [self reloadRowAtIndex:item.index];
}

- (void)testCaseDidFinish:(BaseTestCase*)testCase
{
    JTestCaseDataItem* item = [self itemOfTestCase:testCase];
    if (testCase.isPass)
    {
        item.state = ETestCaseDataItemState_Pass;
    }
    else
    {
        item.state = ETestCaseDataItemState_Fail;
    }
    [self reloadRowAtIndex:item.index];
    
    if (self.isAutoRuning)
    {
        int nextIndex = item.index + 1;
        if (nextIndex < self.dataArray.count)
        {
            [self startCaseAtIndex:nextIndex];
        }
        else
        {
            self.isAutoRuning = NO;
        }
    }
    item.testCase = NULL;
}
@end
