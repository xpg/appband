//
//  AppBandBase.h
//  AppBandBase
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABLog.h"
#import "ABResponse.h"
///**
// Set the App logging component. This header
// file is generally only imported by apps that
// are pulling in all of RestKit. By setting the 
// log component to App here, we allow the app developer
// to use RKLog() in their own app.
// */
//#undef ABLogComponent
//#define ABLogComponent lcl_cApp

@protocol ABUpdateSettingsProtocol;

@interface AppBand : NSObject

//The Application Key
@property(readonly,copy) NSString *appKey;

//The Application Secret
@property(readonly,copy) NSString *appSecret;

/*
 * initialize AppBand and Set Configuration. 
 * 
 * Paramters:
 *          options: App Launch Options and AppBand Configuration.
 */
+ (void)kickoff:(NSDictionary *)options;

/*
 * Get AppBand Singleton Object
 * 
 */
+ (id)shared;

/*
 * Release
 * 
 */
+ (void)end;

/*
 * Update Settings
 * 
 * Paramters:
 *         target: ABUpdateSettingsProtocol implement object.
 */
- (void)updateSettingsWithTarget:(id<ABUpdateSettingsProtocol>)target;

/*
 * Set Device Token
 * 
 * Paramters:
 *          token: the token of the Device.
 */
- (void)setPushToken:(NSData *)token;

/*
 * Set Alias (Max Length 30)
 * 
 * Paramters:
 *          alias: the Alias of the Device.
 */
- (void)setAlias:(NSString *)alias;

/*
 * Get Alias
 * 
 */
- (NSString *)getAlias;

/*
 * Set Tags (Max 5 tags)
 * 
 * Paramters:
 *          tags: tag dictionary.
 */
- (void)setTags:(NSString *)tags;

/*
 * Get Tags
 * 
 */
- (NSString *)getTags;

@end


@protocol ABUpdateSettingsProtocol <NSObject>

@optional

- (void)finishUpdateSettings:(ABResponse *)response;

@end
