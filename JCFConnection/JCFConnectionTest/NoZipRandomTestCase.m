//
//  NoZipRandomTestCase.m
//  JCFConnection
//
//  Created by Jin on 10/31/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "NoZipRandomTestCase.h"

@implementation NoZipRandomTestCase

- (void)onWillSendRequest:(NSMutableURLRequest*)request
{
    NSURL* url = [NSURL URLWithString:@"http://www.uc.cn/images/home/index_bbs.jpg"];
    [request setURL:url];
}

@end
