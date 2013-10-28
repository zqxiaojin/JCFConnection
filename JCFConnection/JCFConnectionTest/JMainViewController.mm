//
//  JMainViewController.m
//  JCFConnection
//
//  Created by Jin on 10/28/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "JMainViewController.h"
#import "JTestCaseTableViewDataSource.h"
#import "GzipTestCase.h"

struct TestCaseStruct
{
    NSString* title;
    SEL       selector;
};

static TestCaseStruct KTestCase[]=
{
    @"gzip" ,@selector(startGzipAndChunk),
};


@interface JMainViewController () <UITableViewDelegate>

@property (nonatomic,retain)UITableView*   testCaseTableView;
@property (nonatomic,retain)JTestCaseTableViewDataSource* tableViewDatasource;

@property (nonatomic,retain)id currentTestCase;

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
    
    NSMutableArray* dataArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0 , ic = sizeof(KTestCase)/sizeof(KTestCase[0]); i < ic; ++i)
    {
        [dataArray addObject:KTestCase[i].title];
    }
    
    self.tableViewDatasource = [[JTestCaseTableViewDataSource alloc] initWithDataArray:dataArray];
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
    SEL selector = KTestCase[[indexPath indexAtPosition:0]].selector;
    NSInvocation* invoke = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    invoke.selector = selector;
    invoke.target = self;
    [invoke invoke];
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

#pragma mark - testCase

- (void)startGzipAndChunk
{
    GzipTestCase* testCase = [[GzipTestCase alloc] init];
    [testCase start];
    self.currentTestCase = testCase;
}



@end
