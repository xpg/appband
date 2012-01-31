//
//  ABPush.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/12/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABConstants.h"

#import "ABNotification.h"
#import "ABRichResponse.h"

@protocol ABPushDelegate;
@protocol ABRichDelegate;

@interface ABPush : NSObject {
    id<ABPushDelegate> pushDelegate;
}

@property(nonatomic,assign) id<ABPushDelegate> pushDelegate;

SINGLETON_INTERFACE(ABPush)

/*
 * Handle Push/Rich Notification
 * 
 * Paramters:
 *  notification: The Dictionary comes from APNs.
 *         state: Application State.
 */
- (void)handleNotification:(NSDictionary *)notification
          applicationState:(UIApplicationState)state;

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
                finishSelector:(SEL)finishSelector;

/*
 * Get Rich Message Content
 * 
 * Paramters:
 *           rid: Rich notification ID.
 *  richDelegate: ABRichDelegate
 */
- (void)getRichContent:(ABNotification *)notification delegate:(id<ABRichDelegate>)richDelegate;

/*
 * Cancel Get Rich Message Content
 * 
 * Paramters:
 *           rid: Rich notification ID.
 */
- (void)cancelGetRichContent:(NSString *)rid;

/*
 * Get Push Enable
 *
 *
 */
- (BOOL)getPushEnabled;

/*
 * Get Push DND Intervals
 *
 */
- (NSArray *)getPushDNDIntervals;

/*
 * Set Push Enable
 * 
 * Paramters:
 *        enabled: YES/NO. YES - Enable Recieve Push. NO - Disable Recieve Push.
 */
- (void)setPushEnabled:(BOOL)enabled;

/*
 * Set Push DND Intervals
 * 
 * Paramters:
 *      intervals: Push will no be send to in those times interval.
 */
- (void)setPushDNDIntervals:(NSArray *)intervals;

/*
 * Register Remote Notification
 *
 * Paramters:
 *        types:
 *
 */
- (void)registerRemoteNotificationWithTypes:(UIRemoteNotificationType)types;

/*
 * Set Application Badge Number
 *
 * Paramters:
 *  badgeNumber: the number you want to show on icon.
 *
 */
- (void)setBadgeNumber:(NSInteger)badgeNumber;

/*
 * set Application Badge Number to 0
 * 
 */
- (void)resetBadge;

@end


@protocol ABPushDelegate <NSObject>

@optional

- (void)didRecieveNotification:(ABNotification *)notification;

@end

@protocol ABRichDelegate <NSObject>

- (void)didRecieveRichContent:(ABRichResponse *)response;

@end