//
//  ABPushSpec.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/12/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABSpecEnvironment.h"

#import "ABPush+Private.h"

@interface ABPushSpec : ABSpec {
    id pushMoch;
}

@end

@implementation ABPushSpec

- (void)setUp {
    pushMoch = [OCMockObject partialMockForObject:[ABPush shared]];
    [super setUp];
}

- (void)tearDown {
    pushMoch = nil;
    [super tearDown];
}

// All code under test must be linked into the Unit Test bundle
- (void)testHandleNotificationPush {
//    id protocolMock = [OCMockObject mockForProtocol:@protocol(ABPushDelegate)];
//    
//    [[protocolMock expect] didRecieveNotification:[OCMArg any]];
//    [pushMoch setPushDelegate:protocolMock];
    
    NSDictionary *noti = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"Hello", AppBandNotificationAlert, [NSNumber numberWithInt:1], AppBandNotificationBadge, nil], AppBandNotificationAPS, @"123", AppBandNotificationId, [NSNumber numberWithInt:0], AppBandPushNotificationType, nil];
    [[pushMoch expect] callbackPushSelector:[OCMArg any] applicationState:UIApplicationStateActive notificationId:[OCMArg isNotNil]];
    
    [pushMoch handleNotification:noti applicationState:UIApplicationStateActive];
    
    [pushMoch verify];
//    [protocolMock verify];
    
}

// All code under test must be linked into the Unit Test bundle
- (void)testHandleNotificationRich {
    NSDictionary *noti = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"Hello", AppBandNotificationAlert, [NSNumber numberWithInt:1], AppBandNotificationBadge, nil], AppBandNotificationAPS, @"123", AppBandNotificationId, [NSNumber numberWithInt:1], AppBandPushNotificationType, nil];
    BOOL value = YES;
    [[[pushMoch stub] andReturnValue:OCMOCK_VALUE(value)] handleRichAuto];
    [[pushMoch expect] showRich:[OCMArg isNotNil]];
    
    [pushMoch handleNotification:noti applicationState:UIApplicationStateActive];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.5]];
    
    [pushMoch verify];
    
}

@end
