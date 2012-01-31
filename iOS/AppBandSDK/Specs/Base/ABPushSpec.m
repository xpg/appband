//
//  ABPushSpec.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/12/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABSpecEnvironment.h"

#import "ABPush+Private.h"
#import "ABRichHandler+Private.h"

@interface ABPushSpec : ABSpec {
    id pushMock;
    
    id handlerMock;
}

@end

@implementation ABPushSpec

- (void)setUp {
    pushMock = [OCMockObject partialMockForObject:[ABPush shared]];
    [super setUp];
}

- (void)tearDown {
    pushMock = nil;
    handlerMock = nil;
    [super tearDown];
}

// All code under test must be linked into the Unit Test bundle
- (void)testHandleNotificationPush {
//    id protocolMock = [OCMockObject mockForProtocol:@protocol(ABPushDelegate)];
//    
//    [[protocolMock expect] didRecieveNotification:[OCMArg any]];
//    [pushMoch setPushDelegate:protocolMock];
    
    NSDictionary *noti = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"Hello", AppBandNotificationAlert, [NSNumber numberWithInt:1], AppBandNotificationBadge, nil], AppBandNotificationAPS, @"123", AppBandNotificationId, [NSNumber numberWithInt:0], AppBandPushNotificationType, nil];
    [[pushMock expect] callbackPushSelector:[OCMArg any] applicationState:UIApplicationStateActive notificationId:[OCMArg isNotNil]];
    
    [pushMock handleNotification:noti applicationState:UIApplicationStateActive];
    
    [pushMock verify];
//    [protocolMock verify];
    
}

// All code under test must be linked into the Unit Test bundle
- (void)testHandleNotificationRich {
    NSDictionary *noti = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"Hello", AppBandNotificationAlert, [NSNumber numberWithInt:1], AppBandNotificationBadge, nil], AppBandNotificationAPS, @"123", AppBandNotificationId, [NSNumber numberWithInt:1], AppBandPushNotificationType, nil];
    BOOL value = YES;
    [[[pushMock stub] andReturnValue:OCMOCK_VALUE(value)] handleRichAuto];
    [[pushMock expect] showRich:[OCMArg isNotNil]];
    
    [pushMock handleNotification:noti applicationState:UIApplicationStateActive];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
    
    [pushMock verify];
    
}

- (void)testSendImpression {
    NSDictionary *noti = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"Hello", AppBandNotificationAlert, [NSNumber numberWithInt:1], AppBandNotificationBadge, nil], AppBandNotificationAPS, @"123", AppBandNotificationId, [NSNumber numberWithInt:0], AppBandPushNotificationType, nil];
    [[pushMock expect] addRequestToQueue:[OCMArg isNotNil]];
    
    [pushMock handleNotification:noti applicationState:UIApplicationStateActive];
    
    [pushMock verify];
}

- (void)testGetRichContentSuccess {
    ABNotification *notification = [[[ABNotification alloc] init] autorelease];
    [notification setState:UIApplicationStateActive];
    [notification setType:ABNotificationTypeRich];
    [notification setNotificationId:@"123"];
    [notification setIsRead:NO];
    [notification setAlert:@"Hello"];
    [notification setBadge:[NSNumber numberWithInt:1]];
    
    
    id protocolMock = [OCMockObject mockForProtocol:@protocol(ABRichDelegate)];
    [[protocolMock expect] didRecieveRichContent:[OCMArg any]];
    
    ABRichHandler *handler = [ABRichHandler handlerWithRichID:notification.notificationId richDelegate:protocolMock handlerDelegate:pushMock];
    handlerMock = [OCMockObject partialMockForObject:handler];

    [[[pushMock stub] andReturnValue:OCMOCK_VALUE(handler)] createRichHandler:notification.notificationId delegate:protocolMock];
    
    [[[handlerMock stub] andCall:@selector(getRichContentEndSuccessful) onObject:self] begin];
    [pushMock getRichContent:notification delegate:protocolMock];
    
    [protocolMock verify];
}

- (void)testGetRichContentFailed {
    ABNotification *notification = [[[ABNotification alloc] init] autorelease];
    [notification setState:UIApplicationStateActive];
    [notification setType:ABNotificationTypeRich];
    [notification setNotificationId:@"123"];
    [notification setIsRead:NO];
    [notification setAlert:@"Hello"];
    [notification setBadge:[NSNumber numberWithInt:1]];
    
    
    id protocolMock = [OCMockObject mockForProtocol:@protocol(ABRichDelegate)];
    [[protocolMock expect] didRecieveRichContent:[OCMArg any]];
    
    ABRichHandler *handler = [ABRichHandler handlerWithRichID:notification.notificationId richDelegate:protocolMock handlerDelegate:pushMock];
    handlerMock = [OCMockObject partialMockForObject:handler];
    
    [[[pushMock stub] andReturnValue:OCMOCK_VALUE(handler)] createRichHandler:notification.notificationId delegate:protocolMock];
    
    [[[handlerMock stub] andCall:@selector(getRichContentEndFailed) onObject:self] begin];
    [pushMock getRichContent:notification delegate:protocolMock];
    
    [protocolMock verify];
}

- (void)getRichContentEndSuccessful {
    [handlerMock httpRequest:nil didFinishLoadingWithError:nil];
}

- (void)getRichContentEndFailed {
    [handlerMock httpRequest:nil didFinishLoadingWithError:[NSError errorWithDomain:@"AppBandTestDomain" code:1 userInfo:nil]];
}

@end
