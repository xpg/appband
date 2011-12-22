//
//  AppBand.h
//  AppHubDemo
//
//  Created by Jason Wang on 10/28/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ABProduct;

@interface AppBand : NSObject {
    
}

@property(nonatomic,readonly,copy) NSString *server;

@property(nonatomic,readonly,copy) NSString *appKey;

@property(nonatomic,readonly,copy) NSString *appSecret;

@property(nonatomic,readonly,copy) NSString *deviceToken;

@property(nonatomic,readonly,copy) NSString *udid;

@property(readonly) BOOL handlePushAuto;

@property(readonly) BOOL handleRichAuto;

#pragma mark - AppBand Mehods

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
 * Get SDK Version
 * 
 */
- (NSString *)getVersion;

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
- (void)setTags:(NSDictionary *)tags;

/*
 * Set Tag
 * 
 * Paramters:
 *           key: The key of the tag.
 *         value: The value of the tag.
 */
- (void)setTag:(NSString *)key value:(NSString *)value;

/*
 * Get Tags
 * 
 */
- (NSDictionary *)getTags;

/*
 * Register Device Token
 * 
 * Paramters:
 *          token: The token receive from APNs.
 *         target: the object takes charge of perform finish selector.
 *  finishSeletor: callback when registration finished. Notice that : The selector must only has one paramter, which is ABRegisterTokenResponse object. e.g. - (void)registerDeviceTokenFinished:(ABRegisterTokenResponse *)response
 */
- (void)registerDeviceToken:(NSData *)token
                     target:(id)target
             finishSelector:(SEL)finishSeletor;

@end
