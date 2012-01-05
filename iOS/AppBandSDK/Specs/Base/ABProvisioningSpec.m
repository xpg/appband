//
//  ABProvisioningTests.m
//  AppBandSDK
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABSpecEnvironment.h"
#import "AppBand.h"

@interface ABProvisioningSpec : ABSpec
@end

@implementation ABProvisioningSpec

- (void)testShouldCallProvisioningService {
    ABProvisioning *provisionService = [[[ABProvisioning alloc] init] autorelease];
    id mock = [OCMockObject partialMockForObject:provisionService];
    BOOL value = YES;
    [[[mock stub] andReturnValue:OCMOCK_VALUE(value)] firstTime];
    [[[mock stub] andCall:@selector(callMocked) onObject:self] call];
    [provisionService start];
}

- (void)testShouldWaitForProvisioningServiceForFirstTimeUse {
    
}

- (void)testShouldProceedEvenWithoutProvisioningServiceAfterTheFirstTimeUse {
    
}

- (void)callMocked {
    ABLogInfo(@"Mocked method called");
}

@end
