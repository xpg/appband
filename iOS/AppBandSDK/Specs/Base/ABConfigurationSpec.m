//
//  ABConfigurationSpec.m
//  AppBandSDK
//
//  Created by Yan Liu on 1/10/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABSpecEnvironment.h"

@interface ABConfigurationSpec : ABSpec {
    ABConfiguration *conf;
}

@end

@implementation ABConfigurationSpec

- (void)setUp {
    [super setUp];
    conf = [[ABConfiguration alloc] init];
}

- (void)tearDown {
    [conf release];
    conf = nil;
    [super tearDown];
}

- (void)testShouldSetDirtyFlagWhenBeingUpdated {
    assertThat(conf.dirty, is(equalToBool(FALSE)));
    conf.setDeviceToken(@"device-token-here");
    assertThat(conf.dirty, is(equalToBool(TRUE)));
}

- (void)testShouldSupportProvisioningFromServer {
    conf.setServerAddress(@"https://us.appmocha.com");
    conf.provision();
    assertThat(conf.getServerAddress, is(equalTo(@"https://api.appmocha.com");
}

- (void)testShouldNotChangeLocalSettingWhenProvisionWasFailed {
    conf.setServerAddress(@"https://us.appmocha.com");
    conf.provision();
    assertThat(conf.getServerAddress, is(equalTo(@"https://us.appmocha.com");
}

- (void)testSyncLocalDataToServerSuccessfully {
    // Set a property so dirty flag is true
    conf.setDeviceToken(@"device-token-here");
    conf.syncDataToServer();
    assertThat(conf.dirty, is(equalToBool(FALSE)));
}

- (void)testShouldNotSyncWhenDirtyFlagIsNotSet {
    conf.syncDataToServer();
    // Assert that no network call happened here
}

@end
