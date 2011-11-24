//
//  ABDonwloadManager.m
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABDonwloadManager.h"

@implementation ABDonwloadManager

SINGLETON_IMPLEMENTATION(ABDonwloadManager)

#pragma mark - Public

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        _downloaderQueue = [[NSOperationQueue alloc] init];
        [_downloaderQueue setMaxConcurrentOperationCount:1];
    }
    
    return self;
}

- (void)dealloc {
    [_downloaderQueue release];
    [super dealloc];
}

@end
