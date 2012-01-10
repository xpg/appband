//
//  ABHttpRequestSpec.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/6/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "ABSpecEnvironment.h"
#import "ABHttpRequest.h"
#import "ABHttpRequest+Private.h"


@interface ABHttpRequestSpec : SenTestCase {
    NSString *validURL;
    NSString *invalidURL;
    NSString *returnedContent;
}

@end

@implementation ABHttpRequestSpec

- (void)setUp {
    validURL = @"http://localhost:4567/ok";
    invalidURL = @"InvalidURLHere";
    returnedContent = @"A,B,C,D";
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMainProccessNoConnection {
    ABHttpRequest *request = [ABHttpRequest requestWithBaseURL:validURL delegate:nil];
    id mock = [OCMockObject partialMockForObject:request];
    BOOL value = NO;
    [[[mock stub] andReturnValue:OCMOCK_VALUE(value)] hasAvailableNetwork];
    [request main];
    STAssertTrue((request.status == ABHttpRequestStatusNoConnection), @"Should be a fail request");
}

- (void)testMainProccessInvalidURL {
    ABHttpRequest *request = [ABHttpRequest requestWithBaseURL:invalidURL delegate:nil];
    id mock = [OCMockObject partialMockForObject:request];
    BOOL value = YES;
    [[[mock stub] andReturnValue:OCMOCK_VALUE(value)] hasAvailableNetwork];
    [request main];
    STAssertTrue((request.status == ABHttpRequestStatusInvalidURL), @"Should be a fail request");
}

- (void)testMainProccessTimeout {
    ABHttpRequest *request = [ABHttpRequest requestWithKey:nil url:validURL parameter:[NSData data] timeout:.2 delegate:nil];
    id mock = [OCMockObject partialMockForObject:request];
    BOOL value = YES;
    [[[mock stub] andReturnValue:OCMOCK_VALUE(value)] hasAvailableNetwork];
    [[[mock stub] andCall:nil onObject:nil] beginConnection:[OCMArg any]];
    [request main];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
    
    STAssertTrue((request.status == ABHttpRequestStatusTimeout), @"Should be a fail request");
}

- (void)testMainProccessCancel {
    ABHttpRequest *request = [ABHttpRequest requestWithBaseURL:validURL delegate:nil];
    id mock = [OCMockObject partialMockForObject:request];
    BOOL value = YES;
    [[[mock stub] andReturnValue:OCMOCK_VALUE(value)] hasAvailableNetwork];
    [request cancel];
    [request main];
    
    STAssertTrue((request.status == ABHttpRequestStatusCancel), @"Should be a fail request");
}

- (void)testHTTPRequestSuccessful {
    ABHttpRequest *request = [ABHttpRequest requestWithBaseURL:validURL delegate:nil];
    id mock = [OCMockObject partialMockForObject:request];
    [[[mock stub] andCall:@selector(httpRequestServiceSuccess:) onObject:self] initializeConnection:[OCMArg any]];

    [request setIsCompleted:NO];
    [request main];
    
    NSString *response = [[[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding] autorelease];
    
    STAssertTrue([response isEqualToString:returnedContent], @"response string should be A,B,C,D");
    STAssertTrue((request.status == ABHttpRequestStatusSuccess), @"Should be a successful request");
}

- (void)testHTTPRequestSuccessfulWithDelegate {
    id urlConnectionDelegate = [OCMockObject mockForProtocol:@protocol(ABHttpRequestDelegate)];
    ABHttpRequest *request = [ABHttpRequest requestWithBaseURL:validURL delegate:urlConnectionDelegate];
    
    [[urlConnectionDelegate expect] httpRequest:request didFinishLoadingWithError:nil];
    
    id mock = [OCMockObject partialMockForObject:request];
    [[[mock stub] andCall:@selector(httpRequestServiceSuccess:) onObject:self] initializeConnection:[OCMArg any]];
    
    [request setIsCompleted:NO];
    [request main];
    
    [urlConnectionDelegate verify];
    STAssertTrue((request.status == ABHttpRequestStatusSuccess), @"Should be a successful request");
}

- (void)testHTTPRequestFail {
    id urlConnectionDelegate = [OCMockObject mockForProtocol:@protocol(ABHttpRequestDelegate)];
    ABHttpRequest *request = [ABHttpRequest requestWithBaseURL:validURL delegate:urlConnectionDelegate];
    
    [[urlConnectionDelegate expect] httpRequest:request didFinishLoadingWithError:[OCMArg isNotNil]];
    
    id mock = [OCMockObject partialMockForObject:request];
    [[[mock stub] andCall:@selector(httpRequestServiceFail:) onObject:self] initializeConnection:[OCMArg any]];
    
    [request main];
    
    [urlConnectionDelegate verify];
    STAssertTrue((request.status == ABHttpRequestStatusError), @"Should be a fail request");
}

- (void)httpRequestServiceSuccess:(ABHttpRequest *)request {
    NSData *data = [returnedContent dataUsingEncoding:NSUTF8StringEncoding];
    NSData *dataPart1 = [data subdataWithRange:(NSRange){0,[data length] / 2}];
    NSData *dataPart2 = [data subdataWithRange:(NSRange){[data length] / 2,[data length] - [dataPart1 length]}];
    [request performSelector:@selector(connection:didReceiveData:) withObject:request.connection withObject:dataPart1];
    [request performSelector:@selector(connection:didReceiveData:) withObject:request.connection withObject:dataPart2];
    [request performSelector:@selector(connectionDidFinishLoading:) withObject:request.connection];
}

- (void)httpRequestServiceFail:(ABHttpRequest *)request {
    [request performSelector:@selector(connection:didFailWithError:) withObject:request.connection withObject:[NSError errorWithDomain:@"" code:404 userInfo:nil]];
}

@end
