//
//  ABRichHandlerSpec.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/16/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABSpecEnvironment.h"

#import "ABRichHandler+Private.h"
#import "ABHttpRequest+Private.h"

@interface ABRichHandlerSpec : ABSpec {
    id handlerMock;
    id richDelegateMock;
    id handlerDelegateMock;
    
    NSString *urlStr;
}

@end

@implementation ABRichHandlerSpec

- (void)setUp {
    richDelegateMock = [OCMockObject mockForProtocol:@protocol(ABRichDelegate)];
    handlerDelegateMock = [OCMockObject mockForProtocol:@protocol(ABRichHandlerDelegate)];
    
    ABRichHandler *handler = [ABRichHandler handlerWithRichID:@"123" richDelegate:richDelegateMock handlerDelegate:handlerDelegateMock];
    handlerMock = [OCMockObject partialMockForObject:handler];
    
    urlStr = [[NSString alloc] initWithFormat:@"https://us.appmocha.com/"];
    
    [super setUp];
}

- (void)tearDown {
    handlerMock = nil;
    
    richDelegateMock = nil;
    handlerDelegateMock = nil;
    
    [urlStr release];
    [super tearDown];
}

// All code under test must be linked into the Unit Test bundle
- (void)testGetRichSuccess {
    ABHttpRequest *request = [ABHttpRequest requestWithKey:@"123" url:urlStr parameter:nil timeout:AppBandSettingsTimeout delegate:handlerMock];
    
    [[[handlerMock stub] andReturnValue:OCMOCK_VALUE(request)] initializeHttpRequest];
    [[[handlerMock stub] andCall:@selector(callGetRichEnd:) onObject:self] addRequestToQueue:[OCMArg any]];
    [[handlerMock expect] sendImpression];
    
    [[richDelegateMock expect] didRecieveRichContent:[OCMArg any]];

    [handlerMock begin];
    
    [handlerMock verify];
    [richDelegateMock verify];
}

- (void)testSendImpression {
    ABHttpRequest *request = [ABHttpRequest requestWithKey:@"123" url:urlStr parameter:nil timeout:AppBandSettingsTimeout delegate:handlerMock];
    
    [[[handlerMock stub] andReturnValue:OCMOCK_VALUE(request)] initializeHttpRequest];
    [[[handlerMock stub] andCall:@selector(callSendImpression:) onObject:self] addRequestToQueue:[OCMArg any]];
    
    [[handlerDelegateMock expect] getRichEnd:[OCMArg any]];
    
    [handlerMock sendImpression];
    [handlerDelegateMock verify];
}

- (void)callGetRichEnd:(ABHttpRequest *)request {
    NSString *responsStr = @"{}";
    request.status = ABHttpRequestStatusSuccess;
    request.responseData = [NSMutableData dataWithData:[responsStr dataUsingEncoding:NSUTF8StringEncoding]];
    [request finishLoadingWithError:nil];
}

- (void)callSendImpression:(ABHttpRequest *)request {
    [request finishLoadingWithError:nil];
}

@end
