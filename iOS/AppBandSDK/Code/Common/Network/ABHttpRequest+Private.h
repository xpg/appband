//
//  ABHttpRequest+Private.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/6/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABHttpRequest.h"

#import "ABPrivateConstants.h"

@interface ABHttpRequest()

@property(nonatomic,readwrite,copy) NSString *key;
@property(nonatomic,readwrite,copy) NSString *url;
@property(nonatomic,readwrite,copy) NSData *parameter;
@property(nonatomic,readwrite,assign) NSTimeInterval timeout;
@property(nonatomic,readwrite,assign) ABHttpRequestStatus status;

@property(assign) BOOL isCompleted;

@property(nonatomic,retain) NSURLConnection *connection;
@property(nonatomic,readwrite,retain) NSMutableData *responseData;

- (void)initializeConnection:(ABHttpRequest *)request;

- (void)beginConnection:(NSMutableURLRequest *)request;

- (BOOL)hasAvailableNetwork;

- (BOOL)isAvailableURL:(NSURL *)url;

- (void)requestHasTimeout;

- (void)requestHasBeenCancelled;

- (void)finishLoadingWithError:(NSError *)error;

@end
