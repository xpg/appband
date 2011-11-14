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
@synthesize richId;

- (void)dealloc {
    [self setAlert:nil];
    [self setBadge:nil];
    [self setSound:nil];
    [self setRichId:nil];
    [super dealloc];
}

@end
