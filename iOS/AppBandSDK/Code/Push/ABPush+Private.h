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

@interface ABPush()

- (void)callbackPushSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
              notificationId:(NSString *)notificationId;

- (void)callbackRichSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state
              notificationId:(NSString *)notificationId;

@end
