//
//  AppBand+Private.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/9/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

//#define kAppBandProductionServer @"https://api.apphub.com/v1"
//#define kAppBandProductionServer @"http://192.168.1.138:3000/v1"

#define kAppBandProductionServer @"https://api.appmocha.com/v1"

#import "AppBand.h"

#import "ABConstants.h"

@interface AppBand()

@property(readwrite,copy) NSString *server;
@property(readwrite,copy) NSString *appKey;
@property(readwrite,copy) NSString *appSecret;
@property(readwrite,copy) NSString *token;
@property(readwrite,copy) NSString *udid;

@property(assign) BOOL handlePushAuto;
@property(assign) BOOL handleRichAuto;

- (void)doProvisioningWhenKickoff;

@end