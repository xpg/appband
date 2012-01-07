//
//  ABProvisioningTests.m
//  AppBandSDK
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABSpecEnvironment.h"
#import "ABProvisioning.h"
#import "ABProvisioning+Private.h"

@interface ABProvisioningSpec : ABSpec {
    ABProvisioning *provisionService;
    id provisionMock;
    id httpRequestMock;
}

@end

@implementation ABProvisioningSpec

- (void)setUp {
    provisionService = [[ABProvisioning alloc] init];
    provisionMock = [OCMockObject partialMockForObject:provisionService];
    ABHttpRequest *request = [ABHttpRequest requestWithTarget:provisionService];
    httpRequestMock = [OCMockObject partialMockForObject:request];
    [[[provisionMock stub] andReturn:httpRequestMock] initializeRequest];
    [super setUp];
}

- (void)tearDown {
    [provisionService release];
    provisionService = nil;
    provisionMock = nil;
    httpRequestMock = nil;
    [super tearDown];
}

- (void)testShouldSetServerEndPointWhenProvisionIsSuccess {
    [[[httpRequestMock stub] andCall:@selector(callProvisiongServiceSuccess) onObject:self] start];
    [provisionService start];
    STAssertTrue([@"http://api.appmocha.com" isEqualToString:provisionService.serverEndpoint],
                 @"Should set the server endpoint properly when provisioning call was successful");
}

- (void)testShouldNotChangeServerEndpointIfProvisioningFail {
    provisionService.serverEndpoint = @"http://us.appmocha.com";
    [[[httpRequestMock stub] andCall:@selector(callProvisiongServiceFail) onObject:self] start];
    [provisionService start];
    STAssertTrue([@"http://us.appmocha.com" isEqualToString:provisionService.serverEndpoint],
                 @"Should not change server endpoint when provisioning call was failed");
}

- (void)callProvisiongServiceSuccess {
    [httpRequestMock finishLoadingWithContent:@"http://api.appmocha.com" error:nil];
}

- (void)callProvisiongServiceFail {
    [httpRequestMock finishLoadingWithContent:@"http://api.appmocha.com" error:[NSError errorWithDomain:@"" code:404 userInfo:nil]];
}

@end
