//
//  ChunkAndGzipValidityTestCase.m
//  JCFConnection
//
//  Created by Jin on 10/30/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "ChunkAndGzipValidityTestCase.h"

@implementation ChunkAndGzipValidityTestCase

- (void)onWillSendRequest:(NSMutableURLRequest*)request
{
    NSURL* url = [NSURL URLWithString:@"http://www.cnts.ua.ac.be/conll2000/chunking/test.txt.gz"];
    [request setURL:url];
    
    [request setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:@"en-us" forHTTPHeaderField:@"Accept-Language"];

}


@end
