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

- (NSDate *)getDateFromString:(NSString *)dateStr {
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:AB_APP_NOTIFICATION_SEND_TIME_FORMAT];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    [dateFormatter release];
    
    return date;
}

- (void)getNotificationsEnd:(NSDictionary *)response {
    ABHTTPRequest *requester = [response objectForKey:ABHTTPRequesterObject];
    
    ABResponseCode code = [[response objectForKey:ABHTTPResponseKeyCode] intValue];
    
    ABNotificationsResponse *r = [[[ABNotificationsResponse alloc] init] autorelease];
    [r setCode:code];
    [r setError:[response objectForKey:ABHTTPResponseKeyError]];
    
    if (code == ABResponseCodeHTTPSuccess) {
        if (code == ABHTTPResponseSuccess) {
            NSString *resp = [response objectForKey:ABHTTPResponseKeyContent];
            
            //parser response json
            NSError *error = nil;
            AB_SBJSON *json = [[AB_SBJSON alloc] init];
            NSDictionary *dic = [json objectWithString:resp error:&error];
            [json release];
            
            if (dic && !error) {
                [r setSum:[[dic objectForKey:AB_APP_NOTIFICATION_SUM] intValue]];
                NSArray *tmp = [dic objectForKey:AB_APP_NOTIFICATION_NOTIFICATIONS];
                if ([tmp count] > 0) {
                    NSMutableArray *notifications = [NSMutableArray array];
                    for (NSDictionary *noti in tmp) {
                        NSString *notiId = [noti objectForKey:AB_APP_NOTIFICATION_ID];
                        if (notiId && ![notiId isEqualToString:@""]) {
                            ABNotification *notification = [[[ABNotification alloc] init] autorelease];
                            [notification setNotificationId:notiId];
                            [notification setType:[[noti objectForKey:AB_APP_NOTIFICATION_TYPE] intValue]];
                            [notification setAlert:[noti objectForKey:AB_APP_NOTIFICATION_ALERT]];
                            [notification setSendTime:[self getDateFromString:[noti objectForKey:AB_APP_NOTIFICATION_SEND_TIME]]];
                            [notifications addObject:notification];
                        }
                    }
                    [r setNotificationArray:[NSArray arrayWithArray:notifications]];
                }
            } else {
                [r setCode:ABResponseCodeHTTPError];
                [r setError:[NSError errorWithDomain:@"AppBand Parser Error" code:ABResponseCodeHTTPError userInfo:nil]];
            }
        } 
        [requester.delegate performSelector:requester.finishSelector withObject:r];
    } else {
        [requester.delegate performSelector:requester.failSelector withObject:r];
    }
}

- (void)getPushConfigurationEnd:(NSDictionary *)response {
    ABHTTPRequest *requester = [response objectForKey:ABHTTPRequesterObject];
    
    ABResponseCode code = [[response objectForKey:ABHTTPResponseKeyCode] intValue];
    
    ABPushConfiguration *r = [[[ABPushConfiguration alloc] init] autorelease];
    [r setCode:code];
    [r setError:[response objectForKey:ABHTTPResponseKeyError]];
    
    if (code == ABResponseCodeHTTPSuccess) {
        if (code == ABHTTPResponseSuccess) {
            NSString *resp = [response objectForKey:ABHTTPResponseKeyContent];
            
            //parser response json
            NSError *error = nil;
            AB_SBJSON *json = [[AB_SBJSON alloc] init];
            NSDictionary *dic = [json objectWithString:resp error:&error];
            [json release];
            
            if (dic && !error) {
                [r setEnabled:[[dic objectForKey:AB_APP_PUSH_CONFIGURATION_ENABLED] boolValue]];
                [r setUnavailableIntervals:[dic objectForKey:AB_APP_PUSH_CONFIGURATION_UNAVAILABLE_INTERVALS]];
            } else {
                [r setCode:ABResponseCodeHTTPError];
                [r setError:[NSError errorWithDomain:@"AppBand Parser Error" code:ABResponseCodeHTTPError userInfo:nil]];
            }
        } 
        [requester.delegate performSelector:requester.finishSelector withObject:r];
    } else {
        [requester.delegate performSelector:requester.failSelector withObject:r];
    }
}

- (void)setPushConfigurationEnd:(NSDictionary *)response {
    ABHTTPRequest *requester = [response objectForKey:ABHTTPRequesterObject];
    
    ABResponseCode code = [[response objectForKey:ABHTTPResponseKeyCode] intValue];
    
    ABResponse *r = [[[ABResponse alloc] init] autorelease];
    [r setCode:code];
    [r setError:[response objectForKey:ABHTTPResponseKeyError]];
    
    if (code == ABResponseCodeHTTPSuccess) {
        [requester.delegate performSelector:requester.finishSelector withObject:r];
    } else {
        [requester.delegate performSelector:requester.failSelector withObject:r];
    }
}

- (NSString *)getJsonFromArray:(NSArray *)array {
    if ([array count] < 1) return @"";
    //parser response json
    NSError *error = nil;
    AB_SBJSON *json = [[AB_SBJSON alloc] init];
    NSString *arrayString = [json stringWithObject:array error:&error];
    [json release];
    
    if (error) {
        return @"";
    }
    
    return arrayString;
}

#pragma mark - Public

/*
 * Handle Push/Rich Notification
 * 
 * Paramters:
 *  notification: The Dictionary comes from APNs.
 *         state: Application State.
 *        target: callback invocator.
 *  pushSelector: the SEL will call when the notification is Push Type. Notice That: The selector must only has one paramter, which is ABNotification object
 *  richSelector: the SEL will call when the notification is Rich Type. Notice That: The selector must only has one paramter, which is ABNotification object
 */
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

/*
 * Inbox Method
 * 
 * Paramters:
 *           type: Notification Type.
 *          index: begin index.
 *   pageCapacity: the capacity of per page.
 *         target: callback invocator.
 * finishSelector: the SEL will call when the notification is Push Type. Notice That: The selector must only has one paramter, which is ABNotificationsResponse object
 *  
 */
- (void)getNotificationsByType:(ABNotificationType)type 
                         index:(NSUInteger)index 
                  pageCapacity:(NSNumber *)pages 
                        target:(id)target 
                finishSelector:(SEL)finishSelector {
//    NSUInteger pageCa = 0;
//    if (pages) {
//        pageCa = [pages unsignedIntValue];
//    }
//    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
//    NSString *token = [[AppBand shared] deviceToken] ? [[AppBand shared] deviceToken] : @"";
//    NSString *urlString = [NSString stringWithFormat:@"%@%@?bundleid=%@&token=%@&k=%@&s=%@&index=%i&pages=%imode=%i",
//                           [[AppBand shared] server], @"/notifications.json", bundleId, token, [[AppBand shared] appKey], [[AppBand shared] appSecret], index,pageCa,type];
//    
//    ABHTTPRequest *request = [ABHTTPRequest requestWithKey:urlString
//                                                       url:urlString 
//                                                 parameter:nil
//                                                   timeout:kAppBandRequestTimeout
//                                                  delegate:target
//                                                    finish:finishSelector
//                                                      fail:finishSelector 
//                                                     agent:self 
//                                             agentSelector:@selector(getNotificationsEnd:)];
//    [[ABRestCenter shared] addRequest:request];
}

/*
 * Get Rich Message Content
 * 
 * Paramters:
 *           rid: Rich notification ID.
 *        target: callback invocator.
 *  finishSelector: the SEL will call when done.
 */
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

/*
 * Cancel Get Rich Message Content
 * 
 * Paramters:
 *           rid: Rich notification ID.
 */
- (void)cancelGetRichContent:(NSString *)rid {
    ABRichHandler *handler = [self.richHandleDictionay objectForKey:[NSString stringWithFormat:@"%@%@",Impression_Rich_ID_Prefix,rid]];
    if (handler) {
        [handler cancel];
    }
}

/*
 * Get Push Configuration
 * 
 * Paramters:
 *         target: callback invocator.
 * finishSelector: the SEL will call when done..The selector must only has one paramter, which is ABPushConfiguration object
 */
- (void)getPushConfigurationWithTarget:(id)target finishSelector:(SEL)finishSelector {
//    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
//    NSString *token = [[AppBand shared] deviceToken] ? [[AppBand shared] deviceToken] : @"";
//    NSString *urlString = [NSString stringWithFormat:@"%@%@?bundleid=%@&token=%@&k=%@&s=%@",
//                           [[AppBand shared] server], @"/push_configuration.json", bundleId, token, [[AppBand shared] appKey], [[AppBand shared] appSecret]];
//    
//    ABHTTPRequest *request = [ABHTTPRequest requestWithKey:urlString
//                                                       url:urlString 
//                                                 parameter:nil
//                                                   timeout:kAppBandRequestTimeout
//                                                  delegate:target
//                                                    finish:finishSelector
//                                                      fail:finishSelector 
//                                                     agent:self 
//                                             agentSelector:@selector(getPushConfigurationEnd:)];
//    [[ABRestCenter shared] addRequest:request];
}

/*
 * Get UTC Time String From NSDate
 * 
 * Paramters:
 *         date: target Date.
 * 
 */
- (NSString *)getUTCFromeDate:(NSDate *)date {
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone1 = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone1];
    [dateFormatter setDateFormat:@"HH:mm ZZZ"];
    NSString *utcTime = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    
    return utcTime;
}

/*
 * Get UTC Time String From NSString
 * 
 * Paramters:
 *         timeStr: target string. Note that: the timeStr should be in "HH:mm" format.
 * 
 */
- (NSString *)getUTCFromeString:(NSString *)timeStr {
    if ([timeStr length] != 5) return nil;
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^([0-2][0-3]:[0-5][0-9])|(0?[0-9]:[0-5][0-9])$" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSUInteger numberofMatch = [expression numberOfMatchesInString:timeStr 
                                                           options:NSMatchingReportProgress
                                                             range:NSMakeRange(0, timeStr.length)];
    if (numberofMatch < 1) return nil;
    
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [dateFormatter dateFromString:timeStr];
    [dateFormatter release];
    
    return [self getUTCFromeDate:date];
}

/*
 * Set Push Configuration
 * 
 * Paramters:
 *        enabled: YES/NO. YES - Enable Recieve Push. NO - Disable Recieve Push.
 *      intervals: Push will no be send to in those times interval.
 *         target: callback invocator.
 * finishSelector: the SEL will call when done.The selector must only has one paramter, which is ABResponse object
 */
- (void)setPushEnabled:(BOOL)enabled 
  unavailableIntervals:(NSArray *)intervals 
                target:(id)target 
        finishSelector:(SEL)finishSelector {
//    NSString *urlString = [NSString stringWithFormat:@"%@%@",
//                           [[AppBand shared] server], @"/push_configuration"];
//    
//    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
//    
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    [parameters setObject:[[AppBand shared] appKey] forKey:AB_APP_KEY];
//    [parameters setObject:[[AppBand shared] appSecret] forKey:AB_APP_SECRET];
//    [parameters setObject:[[AppBand shared] deviceToken] forKey:AB_DEVICE_TOKEN];
//    [parameters setObject:bundleId forKey:AB_APP_BUNDLE_IDENTIFIER];
//    [parameters setObject:[NSNumber numberWithBool:enabled] forKey:AB_APP_PUSH_CONFIGURATION_ENABLED];
//    [parameters setObject:[self getJsonFromArray:intervals] forKey:AB_APP_PUSH_CONFIGURATION_UNAVAILABLE_INTERVALS];
//    
//    ABHTTPRequest *request = [ABHTTPRequest requestWithKey:urlString
//                                                       url:urlString 
//                                                 parameter:parameters
//                                                   timeout:kAppBandRequestTimeout
//                                                  delegate:target
//                                                    finish:finishSelector
//                                                      fail:finishSelector 
//                                                     agent:self 
//                                             agentSelector:@selector(setPushConfigurationEnd:)];
//    [[ABRestCenter shared] addRequest:request];
}

/*
 * Register Remote Notification
 *
 * Paramters:
 *        types:
 *
 */
- (void)registerRemoteNotificationWithTypes:(UIRemoteNotificationType)types {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
}

/*
 * Set Application Badge Number
 *
 * Paramters:
 *  badgeNumber: the number you want to show on icon.
 *
 */
- (void)setBadgeNumber:(NSInteger)badgeNumber {
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] == badgeNumber) 
        return;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
}

/*
 * set Application Badge Number to 0
 * 
 */
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
