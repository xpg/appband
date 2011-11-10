//
//  ABRest.m
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import "ABRestCenter.h"

#import "ABHTTPRequest.h"

@implementation ABRestCenter

@synthesize queue = _queue;

SINGLETON_IMPLEMENTATION(ABRestCenter)

#pragma mark - Public

- (void)addRequest:(ABHTTPRequest *)request {
    [self.queue addOperation:request];
}

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:5];
    }
    
    return self;
}

- (void)dealloc {
    [_queue release];
    [super dealloc];
}

@end
