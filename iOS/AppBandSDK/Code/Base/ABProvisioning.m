//
//  ABProvisioning.m
//  AppBandSDK
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABProvisioning.h"
#import "ABProvisioning+Private.h"

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
    NSString *url = [NSString stringWithFormat:@"%@/app_provisions", [[AppBand shared] server], [[AppBand shared] appKey]];
    
    NSString *token = [[AppBand shared] token] ? [[AppBand shared] token] : @"";
    NSString *appKey = [[AppBand shared] appKey];
    NSString *appSecret = [[AppBand shared] appSecret];
    NSString *udid = [[AppBand shared] udid];
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:udid, AB_DEVICE_UDID, bundleId, AB_APP_BUNDLE_IDENTIFIER, appKey, AB_APP_KEY, appSecret, AB_APP_SECRET, token, AB_DEVICE_TOKEN, nil];
    
    ABHttpRequest *request = [ABHttpRequest requestWithKey:nil url:url parameter:getParameterData(parameters) timeout:AppBandSettingsTimeout delegate:self];
    [request setContentType:@"application/json"];
    
    return request;
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
