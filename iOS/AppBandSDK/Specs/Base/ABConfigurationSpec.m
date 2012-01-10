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

@end
