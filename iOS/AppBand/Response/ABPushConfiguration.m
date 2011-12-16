//
//  ABPushConfiguration.m
//  AppBand
//
//  Created by Jason Wang on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABPushConfiguration.h"

@implementation ABPushConfiguration

@synthesize enabled;
@synthesize unavailableIntervals;

- (void)dealloc {
    [self setUnavailableIntervals:nil];
    [super dealloc];
}

@end
