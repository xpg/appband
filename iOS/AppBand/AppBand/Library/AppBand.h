//
//  AppBand.h
//  AppHubDemo
//
//  Created by Jason Wang on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ABConstant.h"

@interface AppBand : NSObject {
}

#pragma mark - AppBand Mehods

+ (void)kickoff:(NSDictionary *)options;

+ (id)shared;

+ (void)end;

- (void)registerDeviceToken:(NSData *)token
                     target:(id)target
             finishSelector:(SEL)finishSeletor
               failSelector:(SEL)failSelector;

#pragma mark - Push Mehods

- (void)handleNotification:(NSDictionary *)notification
          applicationState:(UIApplicationState)state 
                    target:(id)target 
              pushSelector:(SEL)pushSelector
              richSelector:(SEL)richSelector;

- (void)registerRemoteNotificationWithTypes:(UIRemoteNotificationType)types;

- (void)setBadgeNumber:(NSInteger)badgeNumber;

- (void)resetBadge;

@end
