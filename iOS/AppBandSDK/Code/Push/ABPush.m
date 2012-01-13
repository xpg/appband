//
//  ABPush.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/12/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABPush+Private.h"

@implementation ABPush

@synthesize richHandleDictionay = _richHandleDictionay;
@synthesize richView = _richView;

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
        
        if ([[ABPush shared] handlePushAuto]) {
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
        
        
        if ([[ABPush shared] handleRichAuto]) {
            //call showRich: afterDelay 0.2 seconds,because calling it immediatly will crash when launching.
            [[ABPush shared] performSelector:@selector(showRich:) withObject:abNotification afterDelay:.2];
        }
    }
}

- (BOOL)handlePushAuto {
    return [[[AppBand shared] configuration] handlePushAuto];
}

- (BOOL)handleRichAuto {
    return [[[AppBand shared] configuration] handleRichAuto];
}

- (void)showRich:(ABNotification *)notification {
    if (!self.richView) {
        ABRichView *richView = nil;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            richView = [[[ABIPhoneRichView alloc] initWithFrame:CGRectMake(0, 0, 281, 380)] autorelease];
        } else {
            richView = [[[ABIPadRichView alloc] initWithFrame:CGRectMake(0, 0, 641, 865)] autorelease];
        }
        
        [richView setDelegate:self];
        [richView setCenter:[UIApplication sharedApplication].keyWindow.center];
        [richView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, .000001, .000001)];
        
        [[UIApplication sharedApplication].keyWindow addSubview:richView];
        
        [UIView animateWithDuration:.2 animations:^{
            [richView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.15 animations:^{
                [richView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, .9, .9)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.15 animations:^{
                    [richView setTransform:CGAffineTransformIdentity];
                }];
            }];
        }];
        
        self.richView = richView;
    }
    
    [self.richView setRid:notification.notificationId];
    [[ABPush shared] getRichContent:notification delegate:self.richView];
}

#pragma mark - ABRichHandlerDelegate

- (void)getRichEnd:(ABRichHandler *)richHandler {
    [self.richHandleDictionay removeObjectForKey:richHandler.impressionKey];
}

#pragma mark - ABRichViewDelegate

- (void)cancelRichView:(ABRichView *)richView {

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

/*
 * Get Rich Message Content
 * 
 * Paramters:
 *           rid: Rich notification ID.
 *  richDelegate:
 */
- (void)getRichContent:(ABNotification *)notification delegate:(id<ABRichDelegate>)richDelegate {
    if (!notification.notificationId) 
        return;
    
    ABRichHandler *handler = [self.richHandleDictionay objectForKey:[NSString stringWithFormat:@"%@%@",Impression_Rich_ID_Prefix,notification.notificationId]];
    
    if (handler) {
        [handler setRichDelegate:richDelegate];
    } else {
        handler = [ABRichHandler handlerWithRichID:notification.notificationId richDelegate:richDelegate handlerDelegate:self];
        [self.richHandleDictionay setObject:handler forKey:handler.impressionKey];
        
        [handler begin];
    }
}

/*
 * Cancel Get Rich Message Content
 * 
 * Paramters:
 *           rid: Rich notification ID.
 */
- (void)cancelGetRichContent:(NSString *)rid {

}

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        _richHandleDictionay = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [self setRichHandleDictionay:nil];
    [self setRichView:nil];
    [super dealloc];
}

@end
