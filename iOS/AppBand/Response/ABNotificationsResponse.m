//
//  ABNotificationsResponse.m
//  AppBand
//
//  Created by Jason Wang on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABNotificationsResponse.h"

@implementation ABNotificationsResponse

@synthesize sum;
@synthesize notificationArray;

- (void)dealloc {
    [self setNotificationArray:nil];
    [super dealloc];
}

@end
