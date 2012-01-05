//
//  ABProvisioning.m
//  AppBandSDK
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABProvisioning.h"
#import "ABLog.h"

@implementation ABProvisioning

- (id)init {
    self = [super init];
    if (self) {
        ABLogInitialize();
    }
    return self;
}

- (void)start {
    ABLogInfo(@"Starting provisioning service");
    if ([self firstTime]) {
        [self call];
    }
}

- (BOOL)firstTime {
    return FALSE;
}

- (void)call {
    
}

@end
