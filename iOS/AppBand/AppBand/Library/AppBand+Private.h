//
//  AppBand+Private.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABHTTPRequest.h"
#import "ABGlobal.h"

@class ABRest;

@interface AppBand() <ABHTTPRequestDelegate>

@property(nonatomic,retain) ABRest *abRest;

@property(nonatomic,copy) NSString *server;
@property(nonatomic,copy) NSString *appKey;
@property(nonatomic,copy) NSString *appSecret;
@property(nonatomic,copy) NSString *deviceToken;

- (id)initWithKey:(NSString *)key secret:(NSString *)secret;

- (void)updateDeviceToken:(NSData*)tokenData;

- (NSString*)parseDeviceToken:(NSString*)tokenStr;

- (void)registerDeviceTokenWithExtraInfo:(NSDictionary *)info
                                  target:(id)target
                          finishSelector:(SEL)finishSeletor
                            failSelector:(SEL)failSelector;

- (void)registerDeviceToken:(NSData *)token
              withExtraInfo:(NSDictionary *)info
                     target:(id)target 
             finishSelector:(SEL)finishSeletor 
               failSelector:(SEL)failSelector;

@end