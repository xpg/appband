//
//  ABNotification.m
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import "ABNotification.h"

@implementation ABNotification

@synthesize state;
@synthesize type;
@synthesize alert;
@synthesize badge;
@synthesize sound;
@synthesize notificationId;
@synthesize sendTime;
@synthesize isRead;

- (void)dealloc {
    [self setAlert:nil];
    [self setBadge:nil];
    [self setSound:nil];
    [self setNotificationId:nil];
    [self setSendTime:nil];
    [super dealloc];
}

@end
