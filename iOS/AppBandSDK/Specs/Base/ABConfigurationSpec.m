//
//  ABConfigurationSpec.m
//  AppBandSDK
//
//  Created by Yan Liu on 1/10/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABSpecEnvironment.h"

#import "ABConfiguration+Private.h"
#import "ABHttpRequest+Private.h"

@interface ABConfigurationSpec : ABSpec {
    ABConfiguration *conf;
    id provisionMock;
    id httpRequestMock;
}

@end

@implementation ABConfigurationSpec

- (void)setUp {
    conf = [[ABConfiguration alloc] init];
    provisionMock = [OCMockObject partialMockForObject:conf];
    ABHttpRequest *request = [ABHttpRequest requestWithKey:nil url:@"" parameter:nil timeout:5. delegate:conf];
    httpRequestMock = [OCMockObject partialMockForObject:request];
    [[[provisionMock stub] andReturn:httpRequestMock] initializeRequest];
    [super setUp];
}

- (void)tearDown {
    [conf release];
    conf = nil;
    httpRequestMock = nil;
    provisionMock = nil;
    [super tearDown];
}

- (void)testShouldSupportProvisioningFromServer {
    [conf setServer:@"https://us.appmocha.com"];
    [[[provisionMock stub] andCall:@selector(callProvisiongServiceSuccess) onObject:self] addToBaseNetworkQueue:[OCMArg any]];
    [conf provisioning];
    STAssertTrue([@"http://api.appmocha.com" isEqualToString:conf.server],
                 @"Should set the server endpoint properly when provisioning call was successful");
}

- (void)testShouldNotChangeLocalSettingWhenProvisionWasFailed {
    [conf setServer:@"http://us.appmocha.com"];
    [[[provisionMock stub] andCall:@selector(callProvisiongServiceFail) onObject:self] addToBaseNetworkQueue:[OCMArg any]];
    [conf provisioning];
    STAssertTrue([@"http://us.appmocha.com" isEqualToString:conf.server],
                 @"Should not change server endpoint when provisioning call was failed");
}

- (void)callProvisiongServiceSuccess {
    NSData *data = [@"http://api.appmocha.com" dataUsingEncoding:NSUTF8StringEncoding];
    [httpRequestMock setResponseData:[NSMutableData dataWithData:data]];
    [httpRequestMock finishLoadingWithError:nil];
}

- (void)callProvisiongServiceFail {
    [httpRequestMock finishLoadingWithError:[NSError errorWithDomain:@"" code:404 userInfo:nil]];
}

@end
