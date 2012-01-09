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
#import "ABHttpRequest+Private.h"

@interface ABProvisioningSpec : ABSpec {
    ABProvisioning *provisionService;
    id httpRequestMock;
}

@end

@implementation ABProvisioningSpec

- (void)setUp {
    provisionService = [[ABProvisioning alloc] init];
    id provisionMock = [OCMockObject partialMockForObject:provisionService];
    ABHttpRequest *request = [ABHttpRequest requestWithKey:nil url:@"" parameter:nil timeout:5. delegate:provisionService];
    httpRequestMock = [OCMockObject partialMockForObject:request];
    [[[provisionMock stub] andReturn:httpRequestMock] initializeRequest];
    [super setUp];
}

- (void)tearDown {
    [provisionService release];
    provisionService = nil;
    httpRequestMock = nil;
    [super tearDown];
}

- (void)testShouldSetServerEndPointWhenProvisionIsSuccess {
    [[[httpRequestMock stub] andCall:@selector(callProvisiongServiceSuccess) onObject:self] main];
    [provisionService start];
    STAssertTrue([@"http://api.appmocha.com" isEqualToString:provisionService.serverEndpoint],
                 @"Should set the server endpoint properly when provisioning call was successful");
}

- (void)testShouldNotChangeServerEndpointIfProvisioningFail {
    provisionService.serverEndpoint = @"http://us.appmocha.com";
    [[[httpRequestMock stub] andCall:@selector(callProvisiongServiceFail) onObject:self] main];
    [provisionService start];
    STAssertTrue([@"http://us.appmocha.com" isEqualToString:provisionService.serverEndpoint],
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
