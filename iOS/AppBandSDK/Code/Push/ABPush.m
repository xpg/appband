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
@synthesize pushQueue = _pushQueue;
@synthesize inboxKey = _inboxKey;
@synthesize inboxTarget = _inboxTarget;
@synthesize inboxSEL = _inboxSEL;

@synthesize pushDelegate = _pushDelegate;

SINGLETON_IMPLEMENTATION(ABPush)

#pragma mark - Private

- (ABHttpRequest *)initImpressionHttpRequest:(NSString *)notificationId {
    NSString *token = [[[AppBand shared] appUser] token] ? [[[AppBand shared] appUser] token] : @"";
    NSString *appKey = [[AppBand shared] appKey];
    NSString *appSecret = [[AppBand shared] appSecret];
    NSString *udid = [[[AppBand shared] appUser] udid];
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@?udid=%@&bundleid=%@&token=%@&k=%@&s=%@",
                           [[[AppBand shared] configuration] server], @"/rich_contents/",notificationId,udid,bundleId,token,appKey,appSecret];
    
    return [ABHttpRequest requestWithKey:nil url:urlString parameter:nil timeout:AppBandSettingsTimeout delegate:nil];
}

- (ABHttpRequest *)initInboxHttpRequest:(NSUInteger)pageCa type:(ABNotificationType)type start:(NSString *)notificationId status:(ABNotificationStatusType)status {
    NSString *token = [[[AppBand shared] appUser] token] ? [[[AppBand shared] appUser] token] : @"";
    NSString *appKey = [[AppBand shared] appKey];
    NSString *appSecret = [[AppBand shared] appSecret];
    NSString *udid = [[[AppBand shared] appUser] udid];
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    
    notificationId = notificationId ? notificationId : @"";
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@?udid=%@&bundleid=%@&token=%@&k=%@&s=%@&abni=%@&pages=%i&mode=%i&status=%i",[[[AppBand shared] configuration] server], @"/notifications.json", udid, bundleId, token, appKey, appSecret, notificationId,pageCa,type, status];
    
    [ABPush shared].inboxKey = [[NSDate date] description];
    
    return [ABHttpRequest requestWithKey:self.inboxKey url:urlString parameter:nil timeout:AppBandSettingsTimeout target:self finishSelector:@selector(getNotificationsEnd:)];
}

- (void)addRequestToQueue:(ABHttpRequest *)request {
    [[ABPush shared].pushQueue addOperation:request];
}

- (void)sendImpression:(NSString *)notificationId {
    ABHttpRequest *request = [self initImpressionHttpRequest:notificationId];
    [[ABPush shared] addRequestToQueue:request];
}

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
        
        [[ABPush shared] sendImpression:notificationId];
        
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

- (NSDate *)getDateFromString:(NSString *)dateStr {
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    [dateFormatter release];
    
    return date;
}
            
- (void)getNotificationsEnd:(NSDictionary *)response {
    ABHttpRequest *httpRequest = [response objectForKey:ABHTTPRequestObject];
    
    if (![httpRequest.key isEqualToString:[ABPush shared].inboxKey])
        return;
    
    [ABPush shared].inboxKey = nil;
    
    ABResponseCode code = (int)httpRequest.status;
    
    ABInboxResponse *inboxResponse = [[[ABInboxResponse alloc] init] autorelease];
    [inboxResponse setCode:code];
    [inboxResponse setError:[response objectForKey:ABHTTPRequestError]];
    
    if (code == ABResponseCodeSuccess) {
        NSString *resp = [[NSString alloc] initWithData:httpRequest.responseData encoding:NSUTF8StringEncoding];
        
        //parser response json
        NSError *error = nil;
        AB_SBJSON *json = [[AB_SBJSON alloc] init];
        NSDictionary *dic = [json objectWithString:resp error:&error];
        [json release];
        
        if (dic && !error) {
            [inboxResponse setSum:[[dic objectForKey:AB_APP_NOTIFICATION_SUM] intValue]];
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
                        [notification setSendTime:[[ABPush shared] getDateFromString:[noti objectForKey:AB_APP_NOTIFICATION_SEND_TIME]]];
                        [notification setIsRead:[[noti objectForKey:AB_APP_NOTIFICATION_ISREAD] boolValue]];
                        [notifications addObject:notification];
                    }
                }
                [inboxResponse setNotificationsArray:[NSArray arrayWithArray:notifications]];
            }
        } else {
            [inboxResponse setCode:ABResponseCodeError];
            [inboxResponse setError:[NSError errorWithDomain:@"AppBand Parser Error" code:ABResponseCodeError userInfo:nil]];
        }
    }
    
    [[ABPush shared].inboxTarget performSelector:[ABPush shared].inboxSEL withObject:inboxResponse];
}

- (ABRichHandler *)createRichHandler:(NSString *)notificationId delegate:(id<ABRichDelegate>)richDelegate {
    return [ABRichHandler handlerWithRichID:notificationId richDelegate:richDelegate handlerDelegate:self];
    
}

- (ABRichHandler *)getRichHandlerFromDictionary:(NSString *)notificationId {
    return [self.richHandleDictionay objectForKey:[NSString stringWithFormat:@"%@%@",Impression_Rich_ID_Prefix,notificationId]];
}

#pragma mark - ABRichHandlerDelegate

- (void)getRichEnd:(ABRichHandler *)richHandler {
    [self.richHandleDictionay removeObjectForKey:richHandler.impressionKey];
}

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
 * Inbox Method
 * 
 * Paramters:
 *           type: Notification Type.
 *          index: begin index.
 *         status: 0: unread, 1:read, 2:all
 *   pageCapacity: the capacity of per page.
 *  
 */
- (void)getNotificationsByType:(ABNotificationType)type 
                       startAt:(NSString *)notificationId 
                        status:(ABNotificationStatusType)status 
                  pageCapacity:(NSNumber *)pages 
                        target:(id)target 
                finishSelector:(SEL)finishSelector {
    [ABPush shared].inboxTarget = target;
    [ABPush shared].inboxSEL = finishSelector;
    
    NSUInteger pageCa = 20;
    if (pages) {
        pageCa = [pages unsignedIntValue];
    }
                  
    ABHttpRequest *request = [[ABPush shared] initInboxHttpRequest:pageCa type:type start:notificationId status:status];
    [[ABPush shared] addRequestToQueue:request];
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
    
    ABRichHandler *handler = [[ABPush shared] getRichHandlerFromDictionary:notification.notificationId];
    
    if (handler) {
        [handler setRichDelegate:richDelegate];
    } else {
        handler = [[ABPush shared] createRichHandler:notification.notificationId delegate:richDelegate];
        [[ABPush shared].richHandleDictionay setObject:handler forKey:handler.impressionKey];
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
    ABRichHandler *handler = [[ABPush shared] getRichHandlerFromDictionary:rid];
    if (handler) {
        [handler cancel];
    }
}

/*
 * Get Push Enable
 *
 *
 */
- (BOOL)getPushEnabled {
    return [[AppBand shared] appUser].pushEnable;
}

/*
 * Get Push DND Intervals
 *
 */
- (NSArray *)getPushDNDIntervals {
//    NSArray *intervalsStr = [[AppBand shared] appUser].pushIntervals;
//    if (!intervalsStr) 
//        return nil;
//    
//    AB_SBJSON *json = [[[AB_SBJSON alloc] init] autorelease];
//    return [json objectWithString:intervalsStr error:nil];
    
    return [[AppBand shared] appUser].pushIntervals;
}

/*
 * Set Push Enable
 * 
 * Paramters:
 *        enabled: YES/NO. YES - Enable Recieve Push. NO - Disable Recieve Push.
 */
- (void)setPushEnabled:(BOOL)enabled {
    [[[AppBand shared] appUser] setPushEnable:enabled];
}

/*
 * Set Push DND Intervals
 * 
 * Paramters:
 *      intervals: Push will no be send to in those times interval.
 */
- (void)setPushDNDIntervals:(NSArray *)intervals {
//    AB_SBJSON *json = [[[AB_SBJSON alloc] init] autorelease];
//    NSString *intervalsStr = [json stringWithObject:intervals error:nil];
    [[[AppBand shared] appUser] setPushIntervals:intervals];
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
        self.pushQueue = [ABNetworkQueue networkQueue];
    }
    
    return self;
}

- (void)dealloc {
    [self.pushQueue cancelAllOperations];
    [self setInboxKey:nil];
    [self setPushQueue:nil];
    [self setRichHandleDictionay:nil];
    [self setRichView:nil];
    [super dealloc];
}

@end
