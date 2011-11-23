//
//  AppBand.h
//  AppHubDemo
//
//  Created by Jason Wang on 10/28/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

#pragma mark - Push Mehods

/*
 * Handle Push/Rich Notification
 * 
 * Paramters:
 *  notification: The Dictionary comes from APNs.
 *         state: Application State.
 *        target: callback invocator.
 *  pushSelector: the SEL will be called when the notification is Push Type. Notice That: The selector must only has one paramter, which is ABNotification object
 *  richSelector: the SEL will be called when the notification is Rich Type. Notice That: The selector must only has one paramter, which is ABNotification object
 */
- (void)handleNotification:(NSDictionary *)notification
          applicationState:(UIApplicationState)state 
                    target:(id)target 
              pushSelector:(SEL)pushSelector
              richSelector:(SEL)richSelector;

/*
 * Get Rich Message Content
 * 
 * Paramters:
 *           rid: Rich notification ID.
 *        target: callback invocator.
 *finishSelector: the SEL will call when done. Notice That: The selector must only has one paramter, which is ABRichResponse object
 */
- (void)getRichContent:(NSString *)rid target:(id)target finishSelector:(SEL)finishSelector;

/*
 * Cancel Get Rich Message Content
 * 
 * Paramters:
 *           rid: Rich notification ID.
 */
- (void)cancelGetRichContent:(NSString *)rid;

/*
 * Register Remote Notification
 *
 * Paramters:
 *        types:
 *
 */
- (void)registerRemoteNotificationWithTypes:(UIRemoteNotificationType)types;

/*
 * Set Application Badge Number
 *
 * Paramters:
 *  badgeNumber: the number you want to show on icon.
 *
 */
- (void)setBadgeNumber:(NSInteger)badgeNumber;

/*
 * set Application Badge Number to 0
 * 
 */
- (void)resetBadge;

@end
