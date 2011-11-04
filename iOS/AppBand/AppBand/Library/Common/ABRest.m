//
//  ABRest.m
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABRest.h"

#import "ABHTTPRequest.h"

@interface ABRest()

@end

@implementation ABRest

@synthesize queue = _queue;

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
