//
//  ABAppUserSpec.m
//  AppBandSDK
//
//  Created by Yan Liu on 1/10/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABSpecEnvironment.h"

#import "ABAppUser+Private.h"

@interface ABAppUserSpec :ABSpec {
}
@end

@implementation ABAppUserSpec

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testShouldSetDirtyFlagWhenBeingUpdated {
    id settingsMock = [OCMockObject niceMockForClass:[ABAppUserSettings class]];
    id value = nil;
    [[[settingsMock stub] andReturnValue:OCMOCK_VALUE(value)] getValueOfKey:[OCMArg any]];
    ABAppUser *appUser = [[[ABAppUser alloc] initWithSettings:settingsMock] autorelease];
    id mock = [OCMockObject partialMockForObject:appUser];
    [[mock expect] addToBaseNetworkQueue:[OCMArg isNotNil]];
    [appUser syncDataToServer];
    
    [mock verify];
}

- (void)testSyncLocalDataToServerSuccessfully {
    // Set a property so dirty flag is true
//    appUser.setDeviceToken(@"device-token-here");
//    appUser.syncDataToServer();
//    assertThat(appUser.dirty, is(equalToBool(FALSE)));
}

- (void)testShouldNotSyncWhenDirtyFlagIsNotSet {
//    id settingsMock = [OCMockObject niceMockForClass:[ABAppUserSettings class]];
//    [[[settingsMock stub] andCall:@selector(returnNoWhenItsDutyKey:) onObject:self] getValueOfKey:[OCMArg any]];
    
    ABAppUserSettings *settings = [[[ABAppUserSettings alloc] init] autorelease];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:kAppBandDeviceDirty];
    
    ABAppUser *appUser = [[[ABAppUser alloc] initWithSettings:settings] autorelease];
    
    
    STAssertTrue(appUser.isDirty == NO, @"ABAppUser isDirty should be NO");
    [settings setValue:nil forKey:kAppBandDeviceDirty];
    [settings synchronized];
}

@end
