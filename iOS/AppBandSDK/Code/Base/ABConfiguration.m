//
//  ABConfiguration.m
//  AppBandSDK
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABConfiguration+Private.h"

@implementation ABConfiguration

@synthesize server = _server;

@synthesize handlePushAuto = _handlePushAuto;
@synthesize handleRichAuto = _handleRichAuto;

#pragma mark - ABHttpRequestDelegate

- (void)httpRequest:(ABHttpRequest *)httpRequest didFinishLoadingWithError:(NSError *)error {
    if (!error) {
        NSString *responseStr = [[[NSString alloc] initWithData:httpRequest.responseData encoding:NSUTF8StringEncoding] autorelease];
        
        AB_SBJSON *json = [[[AB_SBJSON alloc] init] autorelease];
        NSError *error = nil;
        NSDictionary *responseDic = [json objectWithString:responseStr error:&error];
        if (!error && responseDic) {
            self.server = [responseDic objectForKey:AB_Best_Server_Address];
        }
    }
}

#pragma mark - Private

- (ABHttpRequest *)initializeRequest {
    NSString *url = [NSString stringWithFormat:@"%@/app_provisions", self.server];
    
    NSString *token = [[[AppBand shared] appUser] token] ? [[[AppBand shared] appUser] token] : @"";
    NSString *appKey = [[AppBand shared] appKey];
    NSString *appSecret = [[AppBand shared] appSecret];
    NSString *udid = [[[AppBand shared] appUser] udid];
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];

    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:udid, AB_DEVICE_UDID, bundleId, AB_APP_BUNDLE_IDENTIFIER, appKey, AB_APP_KEY, appSecret, AB_APP_SECRET, token, AB_DEVICE_TOKEN, nil];
    
    ABHttpRequest *request = [ABHttpRequest requestWithKey:nil url:url parameter:getParameterData(parameters) timeout:AppBandSettingsTimeout delegate:self];
    [request setContentType:@"application/json"];
    
    return request;
}

- (void)addToBaseNetworkQueue:(ABHttpRequest *)request {
    [[[AppBand shared] networkQueue] addOperation:request];
}

#pragma mark - Public

/*
 * Get configuration paramters from server. 
 * 
 */
- (void)provisioning {
    ABLogInfo(@"Starting provisioning service");
    ABHttpRequest *request = [self initializeRequest];
    [self addToBaseNetworkQueue:request];
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
    [self setServer:nil];
    [super dealloc];
}

@end
