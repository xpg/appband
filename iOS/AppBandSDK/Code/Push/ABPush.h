//
//  ABPush.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/12/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABConstants.h"

#import "ABNotification.h"

@protocol ABPushDelegate;

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

@end


@protocol ABPushDelegate <NSObject>

@optional

- (void)didRecieveNotification:(ABNotification *)notification;

@end