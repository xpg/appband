//
//  ABPush.m
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#define Rich_ID_Prefix @"AppBand_Rich_"

#import "ABPush.h"
#import "ABPush+Private.h"

@implementation ABPush

@synthesize richHandleDictionay = _richHandleDictionay;

SINGLETON_IMPLEMENTATION(ABPush)

#pragma mark - Private

- (void)callbackPushSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                pushSelector:(SEL)pushSelector {
    NSDictionary *aps = [notification objectForKey:AppBandNotificationAPS];
    if (aps) {
        if ([[AppBand shared] handlePushAuto]) {
            if (state == UIApplicationStateActive) {
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil message:[aps objectForKey:AppBandNotificationAlert] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
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
                [target performSelector:pushSelector withObject:abNotification];
            }
        }
    }
}

- (void)callbackRichSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                richSelector:(SEL)richSelector 
                      richId:(NSString *)richId {
    NSDictionary *aps = [notification objectForKey:AppBandNotificationAPS];
    NSString *rid = [notification objectForKey:AppBandRichNotificationId];
    if (aps && rid) {
        if ([[AppBand shared] handleRichAuto]) {
            [[ABPush shared] showRich:rid];
        } else {
            if ([target respondsToSelector:richSelector]) {
                ABNotification *abNotification = [[[ABNotification alloc] init] autorelease];
                [abNotification setState:state];
                [abNotification setType:ABNotificationTypeRich];
                [abNotification setAlert:[aps objectForKey:AppBandNotificationAlert]];
                [abNotification setBadge:[aps objectForKey:AppBandNotificationBadge]];
                [abNotification setSound:[aps objectForKey:AppBandNotificationSound]];
                [abNotification setRichId:rid];
                
                [target performSelector:richSelector withObject:abNotification];
            }
        }
    }
}

- (void)impressionRichEnd:(ABRichHandler *)handler {
    NSString *key = [NSString stringWithFormat:@"%@%@",Rich_ID_Prefix,handler.rid];
    [self.richHandleDictionay removeObjectForKey:key];
}

- (void)showRich:(NSString *)rid {
    
}

#pragma mark - Public

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
            
            [[ABPush shared] callbackRichSelector:notification applicationState:state target:target richSelector:richSelector richId:rid];
            break;
        }
        default: {
            [[ABPush shared] callbackPushSelector:notification applicationState:state target:target pushSelector:pushSelector];
            break;
        }
    }
}

- (void)getRichContent:(NSString *)rid target:(id)target finishSelector:(SEL)finishSelector {
    NSString *key = [NSString stringWithFormat:@"%@%@",Rich_ID_Prefix,rid];
    ABRichHandler *handle = [self.richHandleDictionay objectForKey:key];
    if (handle) {
        [handle setFetchTarget:target];
        [handle setFetchSelector:finishSelector];
    } else {
        handle = [ABRichHandler handlerWithRichID:rid fetchTarget:target fetchSelector:finishSelector impressionTarget:self impressionSelector:@selector(impressionRichEnd:)];
        [self.richHandleDictionay setObject:handle forKey:key];
        
        [handle begin];
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
    [super dealloc];
}

@end
