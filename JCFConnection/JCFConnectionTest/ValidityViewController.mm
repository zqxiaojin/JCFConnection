//
//  ValidityViewController.m
//  JCFConnection
//
//  Created by Jin on 10/30/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "ValidityViewController.h"
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
     {@"No Zip Validity"        ,@"NoZipValidityTestCase"}
    ,{@"Gzip Validity"          ,@"GzipValidityTestCase"}
    ,{@"Chunk Validity"         ,@"ChunkValidityTestCase"}
    ,{@"Chunk & Gzip Validity"  ,@"ChunkAndGzipValidityTestCase"}
    ,{@"HTTPS Validity"  ,@"HTTPSValidityTestCase"}
};


@interface ValidityViewController ()



@end

@implementation ValidityViewController



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
