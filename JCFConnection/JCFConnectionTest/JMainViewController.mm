//
//  JMainViewController.m
//  JCFConnection
//
//  Created by Jin on 10/28/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "JMainViewController.h"
#import "JTestCaseTableViewDataSource.h"
#import "JTestCaseDataItem.h"
#import "BaseTestCase.h"

struct TestCaseStruct
{
    NSString* title;
    NSString* className;
};

static TestCaseStruct KTestCase[]=
{
    {@"Gzip Validity" ,@"GzipValidityTestCase"}
    ,{@"Chunk Validity" ,@"ChunkValidityTestCase"}
};


@interface JMainViewController () <UITableViewDelegate,TestCaseDelegate>

@property (nonatomic,retain)UITableView*   testCaseTableView;
@property (nonatomic,retain)JTestCaseTableViewDataSource* tableViewDatasource;

@property (nonatomic,retain)id currentTestCase;
@property (nonatomic,retain)NSMutableArray* dataArray;//JTestCaseDataItem

@end

@implementation JMainViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.testCaseTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.testCaseTableView.delegate = self;
    self.testCaseTableView.autoresizesSubviews = YES;
    self.testCaseTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ;
    
    self.dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0 , ic = sizeof(KTestCase)/sizeof(KTestCase[0]); i < ic; ++i)
    {
        JTestCaseDataItem* item = [[JTestCaseDataItem alloc] init];
        TestCaseStruct& aTestCase = KTestCase[i];
        item.index = i;
        item.title = aTestCase.title;
        item.testClass = NSClassFromString(aTestCase.className);
        assert(item.testClass);
        [self.dataArray addObject:item];
    }
    
    self.tableViewDatasource = [[JTestCaseTableViewDataSource alloc] initWithDataArray:self.dataArray];
    self.testCaseTableView.dataSource = self.tableViewDatasource;
    
    [self.view addSubview:self.testCaseTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTestCaseDataItem* item = [self.dataArray objectAtIndex:[indexPath row]];
    
    [self startCase:item];
    
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
}



@end
