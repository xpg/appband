//
//  AppBandSpec.m
//  AppBandSpec
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABSpecEnvironment.h"

#import "AppBand+Private.h"

static id appbandMock = nil;

@implementation AppBand (UnitTests)

+ (id)shared {
    if (!appbandMock) {
        appbandMock = [OCMockObject niceMockForClass:[AppBand class]];
    }
    
    return appbandMock;
}

@end

@interface AppBandSpec : SenTestCase

@end

@implementation AppBandSpec

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testKickOffShouldSendProvisioning {
    NSMutableDictionary *configOptions = [NSMutableDictionary dictionary];
    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigRunEnvironment];
    [configOptions setValue:@"yourAppKey" forKey:AppBandKickOfOptionsAppBandConfigSandboxKey];
    [configOptions setValue:@"yourAppSecret" forKey:AppBandKickOfOptionsAppBandConfigSandboxSecret];
    
    NSMutableDictionary *kickOffOptions = [NSMutableDictionary dictionary];
    [kickOffOptions setValue:configOptions forKey:AppBandKickOfOptionsAppBandConfigKey];
    
    [[appbandMock expect] doProvisioningWhenKickoff];
    
    [AppBand kickoff:kickOffOptions];
    [appbandMock verify];

}

@end
