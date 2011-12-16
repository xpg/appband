//
//  ABPush.m
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import "ABPush.h"
#import "ABPush+Private.h"

@implementation ABPush

@synthesize richHandleDictionay = _richHandleDictionay;
@synthesize richView = _richView;

SINGLETON_IMPLEMENTATION(ABPush)

#pragma mark - ABRichViewDelegate

- (void)cancelRichView:(ABRichView *)richView {
    [UIView animateWithDuration:.2 animations:^{
        [richView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.15 animations:^{
            [richView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.15 animations:^{
                [richView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, .000001, .000001)];
            } completion:^(BOOL finished) {
                [richView removeFromSuperview];
            }];
        }];
    }];
    
    self.richView = nil;
}

#pragma mark - Private

- (void)callbackPushSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                pushSelector:(SEL)pushSelector
              notificationId:(NSString *)notificationId {
    NSDictionary *aps = [notification objectForKey:AppBandNotificationAPS];
    if (aps) {
        if ([[AppBand shared] handlePushAuto]) {
            if (state == UIApplicationStateActive) {
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] message:[aps objectForKey:AppBandNotificationAlert] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
                [alertView show];
            }
        } else {
            if ([target respondsToSelector:pushSelector]) {
                ABNotification *abNotification = [[[ABNotification alloc] init] autorelease];
                [abNotification setState:state];
                [abNotification setType:ABNotificationTypePush];
                [abNotification setAlert:[aps objectForKey:AppBandNotificationAlert]];
                [abNotification setBadge:[aps objectForKey:AppBandNotificationBadge]];
                [abNotification setSound:[aps objectForKey:AppBandNotificationSound]];
                [abNotification setNotificationId:notificationId];
                [target performSelector:pushSelector withObject:abNotification];
            }
        }
    }
}

- (void)callbackRichSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                richSelector:(SEL)richSelector 
              notificationId:(NSString *)notificationId {
    NSDictionary *aps = [notification objectForKey:AppBandNotificationAPS];
    NSString *rid = [notification objectForKey:AppBandRichNotificationId];
    if (aps && rid) {
        if ([[AppBand shared] handleRichAuto]) {
            //call showRich: afterDelay 0.2 seconds,because calling it immediatly will crash when launching.
            [[ABPush shared] performSelector:@selector(showRich:) withObject:rid afterDelay:.2];
        } else {
            if ([target respondsToSelector:richSelector]) {
                ABNotification *abNotification = [[[ABNotification alloc] init] autorelease];
                [abNotification setState:state];
                [abNotification setType:ABNotificationTypeRich];
                [abNotification setAlert:[aps objectForKey:AppBandNotificationAlert]];
                [abNotification setBadge:[aps objectForKey:AppBandNotificationBadge]];
                [abNotification setSound:[aps objectForKey:AppBandNotificationSound]];
                [abNotification setNotificationId:rid];
                
                [target performSelector:richSelector withObject:abNotification];
            }
        }
    }
}

- (void)impressionRichEnd:(ABRichHandler *)handler {
    [self.richHandleDictionay removeObjectForKey:handler.impressionKey];
}

- (void)showRich:(NSString *)rid {
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
    
    [self.richView setRid:rid];
    [[ABPush shared] getRichContent:rid target:self.richView finishSelector:@selector(setRichContent:)];
}

#pragma mark - Public

- (void)handleNotification:(NSDictionary *)notification
          applicationState:(UIApplicationState)state 
                    target:(id)target
              pushSelector:(SEL)pushSelector
              richSelector:(SEL)richSelector {
    if (!notification) 
        return;
    
    int type = [notification objectForKey:AppBandPushNotificationType] ? [[notification objectForKey:AppBandPushNotificationType] intValue] : 0;
    NSString *notificationId = [notification objectForKey:AppBandRichNotificationId];
    
    switch (type) {
        case 1: {
            if (!notificationId || [notificationId isEqualToString:@""]) return;
            
            [[ABPush shared] callbackRichSelector:notification applicationState:state target:target richSelector:richSelector notificationId:notificationId];
            break;
        }
        default: {
            [[ABPush shared] callbackPushSelector:notification applicationState:state target:target pushSelector:pushSelector notificationId:notificationId];
            break;
        }
    }
}

- (void)getRichContent:(NSString *)rid target:(id)target finishSelector:(SEL)finishSelector {
    ABRichHandler *handler = [self.richHandleDictionay objectForKey:[NSString stringWithFormat:@"%@%@",Impression_Rich_ID_Prefix,rid]];
    if (handler) {
        [handler setFetchTarget:target];
        [handler setFetchSelector:finishSelector];
    } else {
        handler = [ABRichHandler handlerWithRichID:rid fetchTarget:target fetchSelector:finishSelector impressionTarget:self impressionSelector:@selector(impressionRichEnd:)];
        [self.richHandleDictionay setObject:handler forKey:handler.impressionKey];
        
        [handler begin];
    }
}

- (void)cancelGetRichContent:(NSString *)rid {
    ABRichHandler *handler = [self.richHandleDictionay objectForKey:[NSString stringWithFormat:@"%@%@",Impression_Rich_ID_Prefix,rid]];
    if (handler) {
        [handler cancel];
    }
}

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