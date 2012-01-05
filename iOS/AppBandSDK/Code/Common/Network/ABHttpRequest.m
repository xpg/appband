//
//  ABHttpRequest.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/5/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABHttpRequest.h"

@implementation ABHttpRequest

@synthesize delegate;

#pragma mark - Public

- (void)start {
    //TODO
    // initalize NSURLConnect 
}

- (void)finishLoadingWithContent:(NSString *)content error:(NSError *)error {
    [self.delegate httpRequest:self didFinishLoading:content error:error];
}

#pragma mark - lifecycle

+ (id)requestWithTarget:(id<ABHttpRequestDelegate>)del {
    ABHttpRequest *request = [[[ABHttpRequest alloc] init] autorelease];
    [request setDelegate:del];
    return request;
}

- (void)dealloc {
    [super dealloc];
}

@end
