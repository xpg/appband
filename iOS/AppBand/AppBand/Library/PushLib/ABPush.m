//
//  ABPush.m
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABPush.h"
#import "AppBand.h"

@interface ABPush()

@end

@implementation ABPush

SINGLETON_IMPLEMENTATION(ABPush)

#pragma mark - Private



#pragma mark - Public

- (void)registerRemoteNotificationWithTypes:(UIRemoteNotificationType)types {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
}

- (void)setBadgeNumber:(NSInteger)badgeNumber {
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] == badgeNumber) 
        return;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
}

- (void)resetBadge {
    [self setBadgeNumber:0];
}

//handle Push Notification
- (void)handleNotification:(NSDictionary *)notification applicationState:(UIApplicationState)state {
    if (!notification) 
        return;
    
    if (state == UIApplicationStateActive) {
        [[ABPush shared] handlePushWhenActive:notification];
    } else {
        [[ABPush shared] handlePushWhenNonActive:notification];
    }
}

- (void)handlePushWhenActive:(NSDictionary *)notification {
    
}

- (void)handlePushWhenNonActive:(NSDictionary *)notification {
    
}

@end
