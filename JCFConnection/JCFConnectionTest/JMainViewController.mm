//
//  JMainViewController.m
//  JCFConnection
//
//  Created by Jin on 10/28/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "JMainViewController.h"
#import "JTestGroupItem.h"
#import "JMainNaviViewController.h"
struct TestCaseStruct
{
    NSString* title;
    NSString* className;
};

static TestCaseStruct KTestCase[]=
{
     {@"Validity"       ,@"ValidityViewController"}
    ,{@"Random"         ,@"RandomViewController"}
};



@interface JMainViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)UITableView*            tableView;
@property (nonatomic,retain)NSMutableArray* dataArray;//JTestCaseDataItem
@end

@implementation JMainViewController



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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    for (JTestGroupItem* item in self.dataArray)
    {
        item.viewController = nil;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"JCFConnection Test";
    
    self.dataArray = [[NSMutableArray alloc] initWithCapacity:4];
    for (int i = 0 , ic = sizeof(KTestCase)/sizeof(KTestCase[0]); i < ic; ++i)
    {
        JTestGroupItem* item = [[JTestGroupItem alloc] init];
        TestCaseStruct& aTestCase = KTestCase[i];
        item.index = i;
        item.title = aTestCase.title;
        item.itemClass = NSClassFromString(aTestCase.className);
        assert(item.itemClass);
        [self.dataArray addObject:item];
    }
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizesSubviews = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ;
    
    
    [self.view addSubview:self.tableView];
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
    int index = [indexPath row];
    cell.textLabel.text = KTestCase[index].title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
    
    int index = [indexPath row];
    JTestGroupItem* item = [self.dataArray objectAtIndex:index];
    UIViewController* vc =  NULL;
    if (item.viewController)
    {
        vc = item.viewController;
    }
    else
    {
        vc = [[item.itemClass alloc] init];
        item.viewController = vc;
    }
    [[JMainNaviViewController shareController] pushViewController:vc animated:YES];
}


@end
