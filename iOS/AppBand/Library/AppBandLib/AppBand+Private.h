//
//  AppBand+Private.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

//#define kAppBandProductionServer @"https://api.apphub.com/v1"
//#define kAppBandProductionServer @"http://192.168.1.138:3000/v1"

#define kAppBandProductionServer @"https://api.appmocha.com/v1"

#import "ABHTTPRequest.h"

#import "ABResponse.h"

#import "ABGlobal.h"
#import "ABConstant.h"

#import "ABPush.h"
#import "ABRestCenter.h"
#import "ABDataStoreCenter.h"

#import "ABPurchase.h"
#import "ABProduct.h"

#import "UIDevice+IdentifierAddition.h"
#import "AB_SBJSON.h"


@interface AppBand() <ABHTTPRequestDelegate>

@property(nonatomic,readwrite,copy) NSString *server;
@property(nonatomic,readwrite,copy) NSString *appKey;
@property(nonatomic,readwrite,copy) NSString *appSecret;
@property(nonatomic,readwrite,copy) NSString *deviceToken;
@property(nonatomic,readwrite,copy) NSString *udid;

@property(nonatomic,copy) NSString *appRegistrationKey;

@property(assign) id registerTarget;
@property(assign) SEL registerFinishSelector;

@property(assign) BOOL handlePushAuto;
@property(assign) BOOL handleRichAuto;
@property(assign) BOOL defaultViewSupportOrientation;

- (id)initWithKey:(NSString *)key secret:(NSString *)secret;

- (void)updateDeviceToken:(NSData*)tokenData;

- (NSString*)parseDeviceToken:(NSString*)tokenStr;

- (void)appRegisterWithExtraInfo:(NSDictionary *)info;

- (void)registerDeviceTokenEnd:(NSDictionary *)response;

- (NSString *)getTagsString:(NSDictionary *)tags;

- (NSArray *)getIntervalsArray:(NSArray *)array;

/*
 * Register Device Token
 * 
 * Paramters:
 *         target: the object takes charge of perform finish selector.
 *  finishSeletor: callback when registration finished. Notice that : The selector must only has one paramter, which is ABRegisterTokenResponse object. e.g. - (void)registerDeviceTokenFinished:(ABRegisterTokenResponse *)response
 */
- (void)appRegistrationWithTarget:(id)target finishSelector:(SEL)finishSeletor;

- (void)backgroundUpdate;

@end