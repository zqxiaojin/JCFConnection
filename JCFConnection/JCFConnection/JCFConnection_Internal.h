//
//  JCFConnection_Internal.h
//  JCFConnection
//
//  Created by Liang Jin on 10/12/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import "JCFConnection.h"

using namespace J;
@interface JCFConnection ()<JCFConnectionDelegate>
{
    CFConnectionCore*          m_core;
    id<JCFConnectionDelegate>   m_delegate;
}

#pragma mark - only use for CFSocketHandler callback
- (void)connection:(CFConnectionCore *)connection
  didFailWithError:(NSError *)error;

- (NSURLRequest *)connection:(CFConnectionCore *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response;

- (void)connection:(CFConnectionCore *)connection
didReceiveResponse:(NSURLResponse *)response;

- (void)connection:(CFConnectionCore *)connection
    didReceiveData:(NSData *)data;

- (NSCachedURLResponse *)connection:(CFConnectionCore *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse;

- (void)connectionDidFinishLoading:(CFConnectionCore *)connection;



@end
