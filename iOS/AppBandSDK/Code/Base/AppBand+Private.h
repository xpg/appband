//
//  AppBand+Private.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/9/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#if Production
    #define kAppBandProductionServer @"https://api.appmocha.com/v1"
#else
    #define kAppBandProductionServer @"https://api.apphub.com/v1"
#endif


#import "AppBand.h"

#import "ABConstants.h"

#import "ABConfiguration.h"
#import "ABAppUser.h"
#import "ABNetworkQueue.h"

@interface AppBand()

@property(readwrite,copy) NSString *appKey;
@property(readwrite,copy) NSString *appSecret;

@property(nonatomic,retain) ABConfiguration *configuration;
@property(nonatomic,retain) ABAppUser *appUser;
@property(nonatomic,retain) ABNetworkQueue *networkQueue;

- (id)initWithKey:(NSString *)appKey secret:(NSString *)secret;

- (void)initializeEnvironment:(NSDictionary *)config;

- (ABConfiguration *)initializeConfiguration:(NSDictionary *)config;

- (ABAppUser *)initializeAppUser:(ABAppUserSettings *)setting;

- (void)doProvisioningWhenKickoff;

- (NSString*)parseDeviceToken:(NSString*)tokenStr;

@end