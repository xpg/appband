//
//  ABProvisioning.m
//  AppBandSDK
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABProvisioning.h"
#import "ABProvisioning+Private.h"
#import "ABLog.h"

@implementation ABProvisioning

@synthesize serverEndpoint = _serverEndpoint;

#pragma mark - ABHttpRequestDelegate

- (void)httpRequest:(ABHttpRequest *)httpRequest didFinishLoading:(NSString *)content error:(NSError *)error {
    if (!error) {
        self.serverEndpoint = content;
    }
}

#pragma mark - Private

- (ABHttpRequest *)initializeRequest {
    return [ABHttpRequest requestWithBaseURL:@"" delegate:self];
}

#pragma mark - Public

- (void)start {
    ABLogInfo(@"Starting provisioning service");
    ABHttpRequest *request = [self initializeRequest];
    [request main];
}



#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        ABLogInitialize();
    }
    return self;
}

- (void)dealloc {
    [self setServerEndpoint:nil];
    [super dealloc];
}

@end
