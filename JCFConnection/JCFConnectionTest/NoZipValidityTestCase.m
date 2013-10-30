//
//  NoZipValidityTestCase.m
//  JCFConnection
//
//  Created by Jin on 10/31/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "NoZipValidityTestCase.h"

@implementation NoZipValidityTestCase

- (void)onWillSendRequest:(NSMutableURLRequest*)request
{
    NSURL* url = [NSURL URLWithString:@"http://bbs.uc.cn/template/uc_style/uc_img/logo.png"];
    [request setURL:url];
}

@end
