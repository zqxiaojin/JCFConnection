//
//  JCFConnection.h
//  JCFConnection
//
//  Created by Liang Jin on 10/12/13.
//  Copyright (c) 2013 Jin. All rights reserved.
//

#import <Foundation/Foundation.h>


@class JCFConnection;

@protocol JCFConnectionDelegate <NSObject>

- (void)connection:(JCFConnection *)connection
  didFailWithError:(NSError *)error;

- (NSURLRequest *)connection:(JCFConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response;

- (void)connection:(JCFConnection *)connection
didReceiveResponse:(NSURLResponse *)response;

- (void)connection:(JCFConnection *)connection
    didReceiveData:(NSData *)data;

- (NSCachedURLResponse *)connection:(JCFConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse;

- (void)connectionDidFinishLoading:(JCFConnection *)connection;


@end

@interface JCFConnection : NSObject

/* Designated initializer */
- (instancetype)initWithRequest:(NSURLRequest *)request
                       delegate:(id<JCFConnectionDelegate>)delegate
               startImmediately:(BOOL)startImmediately;

- (instancetype)initWithRequest:(NSURLRequest *)request
                       delegate:(id<JCFConnectionDelegate>)delegate;

+ (JCFConnection*)connectionWithRequest:(NSURLRequest *)request
                               delegate:(id<JCFConnectionDelegate>)delegate;

- (NSURLRequest *)originalRequest;
- (NSURLRequest *)currentRequest;

- (void)start;
- (void)cancel;

//- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
//- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

@end
