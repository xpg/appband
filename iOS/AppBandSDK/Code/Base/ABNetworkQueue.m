//
//  ABNetworkQueue.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/10/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABNetworkQueue.h"

@implementation ABNetworkQueue

#pragma mark - lifecycle

//Convenience constructor
+ (id)networkQueue {
    return [[[self alloc] init] autorelease];
}

- (id)init {
	self = [super init];
    if (self) {
        [self setMaxConcurrentOperationCount:4];
    }
	
	return self;
}

-(void)dealloc {
    [super dealloc];
}

@end
