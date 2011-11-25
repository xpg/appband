//
//  AppBand+Private.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import "ABHTTPRequest.h"

#import "ABRegisterTokenResponse.h"

#import "ABGlobal.h"
#import "ABConstant.h"

#import "ABPush.h"
#import "ABRestCenter.h"

#import "ABPurchase.h"
#import "ABProduct.h"

#import "UIDevice+IdentifierAddition.h"


@interface AppBand() <ABHTTPRequestDelegate>

@property(nonatomic,readwrite,copy) NSString *server;
@property(nonatomic,readwrite,copy) NSString *appKey;
@property(nonatomic,readwrite,copy) NSString *appSecret;
@property(nonatomic,readwrite,copy) NSString *deviceToken;
@property(nonatomic,readwrite,copy) NSString *udid;

@property(assign) id registerTarget;
@property(assign) SEL registerFinishSelector;

@property(assign) BOOL handlePushAuto;
@property(assign) BOOL handleRichAuto;

- (id)initWithKey:(NSString *)key secret:(NSString *)secret;

- (void)updateDeviceToken:(NSData*)tokenData;

- (NSString*)parseDeviceToken:(NSString*)tokenStr;

- (void)registerDeviceTokenWithExtraInfo:(NSDictionary *)info;

- (void)registerDeviceToken:(NSData *)token
              withExtraInfo:(NSDictionary *)info;

- (void)registerDeviceTokenEnd:(NSDictionary *)response;

@end