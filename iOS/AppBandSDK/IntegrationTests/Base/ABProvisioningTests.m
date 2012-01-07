//
//  ABProvisioningTests.m
//  AppBandSDK
//
//  Created by Yan Liu on 1/5/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ABProvisioning.h"

@interface ABProvisioningTests : SenTestCase

@end

@implementation ABProvisioningTests

- (void)testShouldSetServerEndPointWhenProvisionIsSuccess {
    ABProvisioning *provisionService = [[ABProvisioning alloc] init];
    [provisionService start];
    STAssertTrue([@"http://www.appmocha.com" isEqualToString:provisionService.serverEndpoint],
                 @"Should set the server endpoint properly when provisioning call was successful");
}

@end
