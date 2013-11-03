//
//  GzipRandomTestCase.m
//  JCFConnection
//
//  Created by Jin on 10/31/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "GzipRandomTestCase.h"

@implementation GzipRandomTestCase

- (void)onWillSendRequest:(NSMutableURLRequest*)request
{
    NSURL* url = [NSURL URLWithString:@"http://zlib.net/zpipe.c"];
    [request setURL:url];
    [request setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
}

@end
