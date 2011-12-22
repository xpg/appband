//
//  ABPush_Private.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import "AppBand.h"

#import "ABConstant.h"
#import "ABRestCenter.h"

#import "ABNotificationsResponse.h"
#import "ABRichHandler.h"
#import "ABRichView.h"
#import "ABIPhoneRichView.h"
#import "ABIPadRichView.h"

#import "ABHTTPRequest.h"
#import "ABResponse.h"
#import "ABPushConfiguration.h"

#import "AB_SBJSON.h"

#define kLastDevicePushEnableKey @"kLastDevicePushEnableKey"
#define kLastDevicePushDNDIntervalsKey @"kLastDevicePushDNDIntervalsKey"

@interface ABPush() <ABRichViewDelegate>

@property(nonatomic,retain) NSMutableDictionary *richHandleDictionay;
@property(nonatomic,retain) ABRichView *richView;

- (void)callbackPushSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                pushSelector:(SEL)pushSelector 
              notificationId:(NSString *)notificationId;
                         
- (void)callbackRichSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                richSelector:(SEL)richSelector 
              notificationId:(NSString *)notificationId;

- (void)impressionRichEnd:(ABRichHandler *)handler;

- (void)showRich:(NSString *)rid;

- (NSDate *)getDateFromString:(NSString *)dateStr;

- (void)getNotificationsEnd:(NSDictionary *)response;

- (void)getPushConfigurationEnd:(NSDictionary *)response;

- (void)setPushConfigurationEnd:(NSDictionary *)response;

- (NSString *)getJsonFromArray:(NSArray *)array;

/*
 * Get UTC Time String From NSDate
 * 
 * Paramters:
 *         date: target Date.
 * 
 */
- (NSString *)getUTCFromeDate:(NSDate *)date;

/*
 * Set Push Enable
 *
 * Paramters:
 *     enabled: ON/OFF.
 *   intervals: array of intervals.
 *
 */
- (void)setPushEnabled:(BOOL)enabled intervals:(NSArray *)intervals;

@end
