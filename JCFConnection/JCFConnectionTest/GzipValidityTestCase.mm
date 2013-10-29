//
//  GzipValidityTestCase.m
//  JCFConnection
//
//  Created by Jin on 10/28/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "GzipValidityTestCase.h"
#import "JCFConnection.h"
#import "BaseTestCase_Internal.h"




@implementation GzipValidityTestCase

- (void)onWillSendRequest:(NSMutableURLRequest*)request
{
    NSURL* url = [NSURL URLWithString:@"http://zlib.net/zpipe.c"];
    [request setURL:url];
    [request setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
}

@end
