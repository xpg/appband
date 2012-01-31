//
//  ABInboxResponse.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/31/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABInboxResponse.h"

@implementation ABInboxResponse

@synthesize sum;
@synthesize notificationsArray;

- (void)dealloc {
    [self setNotificationsArray:nil];
}

@end
