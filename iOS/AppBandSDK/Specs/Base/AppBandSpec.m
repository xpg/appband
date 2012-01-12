//
//  AppBandSpec.m
//  AppBandSpec
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABSpecEnvironment.h"

#import "AppBand+Private.h"
#import "ABAppUser+Private.h"

static id appbandMock = nil;

@implementation AppBand (UnitTests)

- (id)initWithKey:(NSString *)appKey secret:(NSString *)secret {
//    if (!appbandMock) {
//        appbandMock = [OCMockObject niceMockForClass:[AppBand class]];
//    }
//    
//    return appbandMock;
    
    self = [super init];
    if (self) {
        [self setAppKey:appKey];
        [self setAppSecret:secret];
        
    }
    
    appbandMock = [OCMockObject partialMockForObject:self];
    
    return self;
}

@end

@interface AppBandSpec : ABSpec {
    NSMutableDictionary *kickOffOptions;
    
    ABAppUser *appUser;
    id appUserMock;
}

@end

@implementation AppBandSpec

- (void)setUp {
    NSMutableDictionary *configOptions = [NSMutableDictionary dictionary];
    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigRunEnvironment];
    [configOptions setValue:@"yourAppKey" forKey:AppBandKickOfOptionsAppBandConfigSandboxKey];
    [configOptions setValue:@"yourAppSecret" forKey:AppBandKickOfOptionsAppBandConfigSandboxSecret];
    
    kickOffOptions = [[NSMutableDictionary alloc] init];
    [kickOffOptions setValue:configOptions forKey:AppBandKickOfOptionsAppBandConfigKey];
    
    appUser = [[ABAppUser alloc] initWithSettings:[[[ABAppUserSettings alloc] init] autorelease]];
    appUserMock = [OCMockObject partialMockForObject:appUser];
    [super setUp];
}

- (void)tearDown {
    [kickOffOptions release];
    kickOffOptions = nil;
    [appUser release];
    appUser = nil;
    appUserMock = nil;
    [super tearDown];
}

- (void)testKickOffShouldSendProvisioning {
    [[appbandMock expect] doProvisioningWhenKickoff];
    [[appbandMock expect] updateSettingsWithTarget:nil];
    [AppBand kickoff:kickOffOptions];
    [appbandMock verify];

}

- (void)testUpdateSettingsWithTarget {
    id protocolMock = [OCMockObject mockForProtocol:@protocol(ABUpdateSettingsProtocol)];
    [[protocolMock expect] finishUpdateSettings:[OCMArg isNotNil]];
    [[[appUserMock stub] andCall:@selector(updateSettingFinish:) onObject:self] addToBaseNetworkQueue:[OCMArg any]];
    [[AppBand alloc] initWithKey:@"yourAppKey" secret:@"yourAppSecret"];
    [[AppBand shared] setAppUser:appUserMock];
    [[AppBand shared] updateSettingsWithTarget:protocolMock];
    [protocolMock verify];
}

- (void)updateSettingFinish:(ABHttpRequest *)request {
    [appUserMock httpRequest:request didFinishLoadingWithError:nil];
}

@end
