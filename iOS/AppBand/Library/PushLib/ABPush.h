//
//  ABPush.h
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABConstant.h"
#import "ABNotification.h"

@interface ABPush : NSObject {
}

SINGLETON_INTERFACE(ABPush)

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
              richSelector:(SEL)richSelector;

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
                finishSelector:(SEL)finishSelector;

/*
 * Get Rich Message Content
 * 
 * Paramters:
 *           rid: Rich notification ID.
 *        target: callback invocator.
 *  finishSelector: the SEL will call when done.
 */
- (void)getRichContent:(NSString *)rid target:(id)target finishSelector:(SEL)finishSelector;

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
        finishSelector:(SEL)finishSelector;

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
