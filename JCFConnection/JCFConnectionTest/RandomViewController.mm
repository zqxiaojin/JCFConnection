//
//  RandomViewController.m
//  JCFConnection
//
//  Created by Jin on 10/31/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "RandomViewController.h"
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
    {@"No Zip Random"        ,@"NoZipRandomTestCase"}
    ,{@"Gzip Random"          ,@"GzipRandomTestCase"}
    ,{@"Chunk & Gzip Random"  ,@"ChunkAndGzipRandomTestCase"}
};


@interface RandomViewController ()

@end

@implementation RandomViewController

- (void)buildTestDataArray
{
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
    
}

@end
