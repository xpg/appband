//
//  ABPush.h
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABGlobal.h"

@interface ABPush : NSObject {

}

SINGLETON_INTERFACE(ABPush)

- (void)registerRemoteNotificationWithTypes:(UIRemoteNotificationType)types;

- (void)setBadgeNumber:(NSInteger)badgeNumber;

- (void)resetBadge;

//handle Push Notification
- (void)handleNotification:(NSDictionary *)notification applicationState:(UIApplicationState)state;

- (void)handlePushWhenActive:(NSDictionary *)notification;

- (void)handlePushWhenNonActive:(NSDictionary *)notification;

@end
