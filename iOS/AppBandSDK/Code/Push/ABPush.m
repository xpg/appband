//
//  ABPush.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/12/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABPush+Private.h"

@implementation ABPush

@synthesize pushDelegate = _pushDelegate;

SINGLETON_IMPLEMENTATION(ABPush)

#pragma mark - Private

- (void)callbackPushSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
              notificationId:(NSString *)notificationId {
    NSDictionary *aps = [notification objectForKey:AppBandNotificationAPS];
    if (aps) {
        if ([self.pushDelegate respondsToSelector:@selector(didRecieveNotification:)]) {
            ABNotification *abNotification = [[[ABNotification alloc] init] autorelease];
            [abNotification setState:state];
            [abNotification setType:ABNotificationTypePush];
            [abNotification setAlert:[aps objectForKey:AppBandNotificationAlert]];
            [abNotification setBadge:[aps objectForKey:AppBandNotificationBadge]];
            [abNotification setSound:[aps objectForKey:AppBandNotificationSound]];
            [abNotification setNotificationId:notificationId];
            [abNotification setIsRead:YES];
            [self.pushDelegate didRecieveNotification:abNotification];
        }
        
        if ([[[AppBand shared] configuration] handlePushAuto]) {
            if (state == UIApplicationStateActive) {
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] message:[aps objectForKey:AppBandNotificationAlert] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
                [alertView show];
            }
        }
    }
}

- (void)callbackRichSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
              notificationId:(NSString *)notificationId {
    NSDictionary *aps = [notification objectForKey:AppBandNotificationAPS];
    NSString *nid = [notification objectForKey:AppBandNotificationId];
    if (aps && nid) {
        ABNotification *abNotification = [[[ABNotification alloc] init] autorelease];
        [abNotification setState:state];
        [abNotification setType:ABNotificationTypeRich];
        [abNotification setAlert:[aps objectForKey:AppBandNotificationAlert]];
        [abNotification setBadge:[aps objectForKey:AppBandNotificationBadge]];
        [abNotification setSound:[aps objectForKey:AppBandNotificationSound]];
        [abNotification setNotificationId:nid];
        [abNotification setIsRead:NO];
        
        if ([self.pushDelegate respondsToSelector:@selector(didRecieveNotification:)]) {
            [self.pushDelegate didRecieveNotification:abNotification];
        }
        
        
        if ([[AppBand shared] handleRichAuto]) {
            //call showRich: afterDelay 0.2 seconds,because calling it immediatly will crash when launching.
            [[ABPush shared] performSelector:@selector(showRich:) withObject:abNotification afterDelay:.2];
        }
    }
}

#pragma mark - Public

/*
 * Handle Push/Rich Notification
 * 
 * Paramters:
 *  notification: The Dictionary comes from APNs.
 *         state: Application State.
 */
- (void)handleNotification:(NSDictionary *)notification
          applicationState:(UIApplicationState)state {
    if (!notification) 
        return;
    
    int type = [notification objectForKey:AppBandPushNotificationType] ? [[notification objectForKey:AppBandPushNotificationType] intValue] : 0;
    NSString *nid = [notification objectForKey:AppBandNotificationId];
    
    switch (type) {
        case 1: {
            if (!nid || [nid isEqualToString:@""]) return;
            
            [[ABPush shared] callbackRichSelector:notification applicationState:state notificationId:nid];
            break;
        }
        default: {
            [[ABPush shared] callbackPushSelector:notification applicationState:state notificationId:nid];
            break;
        }
    }
}

#pragma mark - lifecycle

- (void)dealloc {
    [super dealloc];
}

@end
