//
//  ABNotification.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

typedef enum {
    ABNotificationTypePush,
    ABNotificationTypeRich,
    ABNotificationTypeAll,
} ABNotificationType;

typedef enum {
    ABNotificationStatusUnread,
    ABNotificationStatusRead,
    ABNotificationStatusAll,
} ABNotificationStatusType;

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ABNotification : NSObject {
    UIApplicationState state;
    ABNotificationType type;
    NSString *alert;
    NSNumber *badge;
    NSString *sound;
    NSString *notificationId;
    NSDate *sendTime;
    BOOL isRead;
}

@property(nonatomic,assign) UIApplicationState state;
@property(nonatomic,assign) ABNotificationType type;
@property(nonatomic,copy) NSString *alert;
@property(nonatomic,copy) NSNumber *badge;
@property(nonatomic,copy) NSString *sound;
@property(nonatomic,copy) NSString *notificationId;
@property(nonatomic,copy) NSDate *sendTime;
@property(nonatomic,assign) BOOL isRead;

@end

