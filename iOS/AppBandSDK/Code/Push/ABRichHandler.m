//
//  ABRichHandler.m
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//


#import "ABRichHandler.h"

#import "AppBand+Private.h"
#import "ABRichResponse.h"
#import "ABHttpRequest.h"
#import "ABUtilty.h"
#import "ABPrivateConstants.h"

#import "AB_SBJSON.h"

@interface ABRichHandler() <ABHttpRequestDelegate>

@property(nonatomic,assign) id<ABRichHandlerDelegate> handlerDelegate;

@property(nonatomic,readwrite,copy) NSString *fetchKey;
@property(nonatomic,readwrite,copy) NSString *impressionKey;

- (void)impressionEnd:(NSDictionary *)response;

@end

@implementation ABRichHandler

@synthesize rid = _rid;
@synthesize richDelegate = _richDelegate;
@synthesize handlerDelegate = _handlerDelegate;

@synthesize fetchKey = _fetchKey;
@synthesize impressionKey = _impressionKey;

#pragma mark - Private

- (void)impressionEnd:(NSDictionary *)response {
    if ([self.handlerDelegate respondsToSelector:@selector(getRichEnd:)]) {
        [self.handlerDelegate getRichEnd:self];
    }
}

#pragma mark - ABHttpRequestDelegate

- (void)httpRequest:(ABHttpRequest *)httpRequest didFinishLoadingWithError:(NSError *)error {
    ABRichResponse *response = [[[ABRichResponse alloc] init] autorelease]; 
    response.code = (ABResponseCode)httpRequest.status;
    response.error = error;
    
    if (!error && httpRequest.responseData) {
        NSString *responseStr = [[NSString alloc] initWithData:httpRequest.responseData encoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        AB_SBJSON *json = [[AB_SBJSON alloc] init];
        NSDictionary *richDic = [json objectWithString:responseStr error:&error];
        [json release];
        
        if (richDic && !error) {
            [response setRichTitle:[richDic objectForKey:AB_Rich_Title]];
            [response setRichContent:[richDic objectForKey:AB_Rich_Content]];
            [response setNotificationId:self.rid];
        } else {
            response.code = ABResponseCodeError;
            response.error = [NSError errorWithDomain:ABHttpRequestErrorDomain code:ABResponseCodeError userInfo:nil];
        }
        
    }
    
    if ([self.richDelegate respondsToSelector:@selector(didRecieveRichContent:)]) {
        [self.richDelegate didRecieveRichContent:response];
    }
    
    if (response.code == ABResponseCodeSuccess) {
        NSString *urlString = [NSString stringWithFormat:@"%@/notifications/%@/confirm",
                               [[[AppBand shared] configuration] server], self.rid];
        
        NSString *token = [[[AppBand shared] appUser] token] ? [[[AppBand shared] appUser] token] : @"";
        NSString *appKey = [[AppBand shared] appKey];
        NSString *appSecret = [[AppBand shared] appSecret];
        NSString *udid = [[[AppBand shared] appUser] udid];
        NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:udid, AB_DEVICE_UDID, bundleId, AB_APP_BUNDLE_IDENTIFIER, appKey, AB_APP_KEY, appSecret, AB_APP_SECRET, token, AB_DEVICE_TOKEN, nil];
        
        ABHttpRequest *request = [ABHttpRequest requestWithKey:self.impressionKey url:urlString parameter:getParameterData(parameters) timeout:AppBandSettingsTimeout target:self finishSelector:@selector(impressionEnd:)];
        
        //ToDo add request to operation queue
    } else {
        if ([self.handlerDelegate respondsToSelector:@selector(getRichEnd:)]) {
            [self.handlerDelegate getRichEnd:self];
        }
    }
    
}

#pragma mark - Public

- (void)begin {
    NSString *token = [[[AppBand shared] appUser] token] ? [[[AppBand shared] appUser] token] : @"";
    NSString *appKey = [[AppBand shared] appKey];
    NSString *appSecret = [[AppBand shared] appSecret];
    NSString *udid = [[[AppBand shared] appUser] udid];
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@?udid=%@&bundleid=%@&token=%@&k=%@&s=%@",
                           [[AppBand shared] server], @"/rich_contents/",self.rid,udid,bundleId,token,appKey,appSecret];
    
//    ABHTTPRequest *request = [ABHTTPRequest requestWithKey:self.fetchKey 
//                                                       url:urlString 
//                                                 parameter:nil
//                                                   timeout:kAppBandRequestTimeout
//                                                  delegate:self
//                                                    finish:@selector(getRichEnd:)
//                                                      fail:@selector(getRichEnd:)];
//    [[ABRestCenter shared] addRequest:request];
    
    ABHttpRequest *request = [ABHttpRequest requestWithKey:self.fetchKey url:urlString parameter:nil timeout:AppBandSettingsTimeout delegate:self];
    
    //ToDo add request to operation queue
}

- (void)cancel {
//    NSEnumerator *enumerator = [[[[ABRestCenter shared] queue] operations] objectEnumerator];
//    ABHTTPRequest *request = nil;
//    while (request = [enumerator nextObject]) {
//        if ([request.key isEqualToString:self.fetchKey] || [request.key isEqualToString:self.impressionKey]) {
//            [request cancel];
//        }
//    }
}

#pragma mark - livecycle

+ (ABRichHandler *)handlerWithRichID:(NSString *)richID 
                        richDelegate:(id<ABRichDelegate>)richDelegate 
                     handlerDelegate:(id<ABRichHandlerDelegate>)handlerDelegate {
    ABRichHandler *handle = [[[ABRichHandler alloc] init] autorelease];
    [handle setFetchKey:[NSString stringWithFormat:@"%@%@",Fetch_Rich_ID_Prefix,richID]];
    [handle setImpressionKey:[NSString stringWithFormat:@"%@%@",Impression_Rich_ID_Prefix,richID]];
    [handle setRid:richID];
    [handle setRichDelegate:richDelegate];
    [handle setHandlerDelegate:handlerDelegate];
    
    return handle;
}

- (void)dealloc {
    [self setRid:nil];
    [self setFetchKey:nil];
    [self setImpressionKey:nil];
    [super dealloc];
}

@end
