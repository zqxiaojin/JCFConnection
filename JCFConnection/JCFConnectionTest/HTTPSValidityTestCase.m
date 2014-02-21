//
//  HTTPSValidityTestCase.m
//  JCFConnection
//
//  Created by LiangJin on 14-1-23.
//  Copyright (c) 2014年 Jin. All rights reserved.
//

#import "HTTPSValidityTestCase.h"

@implementation HTTPSValidityTestCase

- (void)onWillSendRequest:(NSMutableURLRequest*)request
{
    NSURL* url = [NSURL URLWithString:@"https://github.com/"];
    [request setURL:url];
}

@end
