//
//  ChunkValidityTestCase.m
//  JCFConnection
//
//  Created by Jin on 10/30/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "ChunkValidityTestCase.h"

@implementation ChunkValidityTestCase

- (void)onWillSendRequest:(NSMutableURLRequest*)request
{
    NSURL* url = [NSURL URLWithString:@"http://jigsaw.w3.org/HTTP/ChunkedScript"];
    [request setURL:url];
    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
}

@end
