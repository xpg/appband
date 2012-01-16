//
//  ABPush+Private.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/12/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

//Push Notification Payload Key
#define AppBandNotificationAPS @"aps"
#define AppBandNotificationAlert @"alert"
#define AppBandNotificationBadge @"badge"
#define AppBandNotificationSound @"sound"
#define AppBandNotificationId @"abni"
#define AppBandPushNotificationType @"abpt"

#import "ABPush.h"
#import "AppBand+Private.h"
#import "ABRichHandler.h"

#import "ABHttpRequest.h"
#import "ABPrivateConstants.h"

#import "ABRichView.h"
#import "ABIPhoneRichView.h"
#import "ABIPadRichView.h"

#import "AB_SBJSON.h"

@interface ABPush() <ABRichViewDelegate,ABRichHandlerDelegate>

@property(nonatomic,retain) NSMutableDictionary *richHandleDictionay;
@property(nonatomic,retain) ABRichView *richView;

@property(nonatomic,retain) ABNetworkQueue *pushQueue;

- (ABHttpRequest *)initImpressionHttpRequest:(NSString *)notificationId;

- (void)addImpressionRequestToQueue:(ABHttpRequest *)request;

- (void)sendImpression:(NSString *)notificationId;

- (void)callbackPushSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
              notificationId:(NSString *)notificationId;

- (void)callbackRichSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state
              notificationId:(NSString *)notificationId;

- (BOOL)handlePushAuto;

- (BOOL)handleRichAuto;

- (void)showRich:(ABNotification *)notification;

- (ABRichHandler *)createRichHandler:(NSString *)notificationId delegate:(id<ABRichDelegate>)richDelegate;

- (ABRichHandler *)getRichHandlerFromDictionary:(NSString *)notificationId;

@end
