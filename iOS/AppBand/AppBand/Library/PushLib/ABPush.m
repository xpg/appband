//
//  ABPush.m
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABPush.h"
#import "ABPush+Private.h"

#import "AppBand.h"

@implementation ABPush

SINGLETON_IMPLEMENTATION(ABPush)

#pragma mark - Private

- (void)handlePushWhenActive:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                pushSelector:(SEL)pushSelector {

}

- (void)handlePushWhenNonActive:(NSDictionary *)notification 
               applicationState:(UIApplicationState)state
                         target:(id)target 
                   pushSelector:(SEL)pushSelector {

}

- (void)handleRichWhenActive:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                richSelector:(SEL)richSelector 
                      richId:(NSString *)richId {

}

- (void)handleRichWhenNonActive:(NSDictionary *)notification 
               applicationState:(UIApplicationState)state
                         target:(id)target 
                   richSelector:(SEL)richSelector 
                         richId:(NSString *)richId {

}

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
- (void)handleNotification:(NSDictionary *)notification
          applicationState:(UIApplicationState)state 
                    target:(id)target
              pushSelector:(SEL)pushSelector
              richSelector:(SEL)richSelector {
    if (!notification) 
        return;
    
    int type = [[notification objectForKey:AppBandPushNotificationType] intValue];
    switch (type) {
        case 1: {
            NSString *rid = [notification objectForKey:AppBandRichNotificationId];
            if (!rid || [rid isEqualToString:@""]) return;
            
            if (state == UIApplicationStateActive) {
                [[ABPush shared] handleRichWhenActive:notification applicationState:state target:target richSelector:richSelector richId:rid];
            } else {
                [[ABPush shared] handleRichWhenNonActive:notification applicationState:state target:target richSelector:richSelector richId:rid];
            }
            break;
        }
        default: {
            if (state == UIApplicationStateActive) {
                [[ABPush shared] handlePushWhenActive:notification applicationState:state target:target pushSelector:pushSelector];
            } else {
                [[ABPush shared] handlePushWhenNonActive:notification applicationState:state target:target pushSelector:pushSelector];
            }
            break;
        }
    }
}

@end
