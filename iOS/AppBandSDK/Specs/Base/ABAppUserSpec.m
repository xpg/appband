//
//  ABAppUserSpec.m
//  AppBandSDK
//
//  Created by Yan Liu on 1/10/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABSpecEnvironment.h"

@interface ABAppUserSpec :ABSpec {
    ABAppUser *appUser;
}
@end

@implementation ABAppUserSpec

- (void)setUp {
    [super setUp];
    appUser = [[ABAppUser alloc] init];
}

- (void)tearDown {
    [appUser release];
    appUser = nil;
    [super tearDown];
}

- (void)testShouldSetDirtyFlagWhenBeingUpdated {
    assertThat(appUser.dirty, is(equalToBool(FALSE)));
    appUser.setDeviceToken(@"device-token-here");
    assertThat(appUser.dirty, is(equalToBool(TRUE)));
}

- (void)testSyncLocalDataToServerSuccessfully {
    // Set a property so dirty flag is true
    appUser.setDeviceToken(@"device-token-here");
    appUser.syncDataToServer();
    assertThat(appUser.dirty, is(equalToBool(FALSE)));
}

- (void)testShouldNotSyncWhenDirtyFlagIsNotSet {
    appUser.syncDataToServer();
    // Assert that no network call happened here
}

@end
