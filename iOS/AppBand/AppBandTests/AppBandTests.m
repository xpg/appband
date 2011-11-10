//
//  AppBandTests.m
//  AppBandTests
//
//  Created by Jason Wang on 11/1/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import "AppBandTests.h"

#import "AppBand.h"
#import "AppBand+Private.h"

#import "ABPush.h"
#import "ABPush+Private.h"

#import "ABConstant.h"
#import "ABGlobal.h"
#import "ABRestCenter.h"
#import "ABHTTPRequest.h"

@implementation AppBandTests

- (void)setUp {
    
    [super setUp];
    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    [AppBand end];
    [super tearDown];
}

- (void)testKickOffWithKeyAndSecret {
    NSMutableDictionary *configOptions = [NSMutableDictionary dictionary];
    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigRunEnvironment];
    [configOptions setValue:@"42dfsa9fs0923" forKey:AppBandKickOfOptionsAppBandConfigSandboxKey];
    [configOptions setValue:@"klksdfn3ugymazkid3isd" forKey:AppBandKickOfOptionsAppBandConfigSandboxSecret];
    
    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigHandlePushAuto];
    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigHandleRichAuto];
    
    NSMutableDictionary *kickOffOptions = [NSMutableDictionary dictionary];
    [kickOffOptions setValue:configOptions forKey:AppBandKickOfOptionsAppBandConfigKey];
    
    [AppBand kickoff:kickOffOptions];
    
    STAssertTrue(![[AppBand shared] handleRichAuto],@"should initialize AppBand successful!");
}

- (void)testKickOffWithoutKeyAndSecret {
    [AppBand kickoff:nil];
    
    STAssertNil([AppBand shared],@"should initialize AppBand unsuccessful!");
}

- (void)testEnd {
    NSMutableDictionary *configOptions = [NSMutableDictionary dictionary];
    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigRunEnvironment];
    [configOptions setValue:@"42dfsa9fs0923" forKey:AppBandKickOfOptionsAppBandConfigSandboxKey];
    [configOptions setValue:@"klksdfn3ugymazkid3isd" forKey:AppBandKickOfOptionsAppBandConfigSandboxSecret];
    
    NSMutableDictionary *kickOffOptions = [NSMutableDictionary dictionary];
    [kickOffOptions setValue:configOptions forKey:AppBandKickOfOptionsAppBandConfigKey];
    
    [AppBand kickoff:kickOffOptions];
    [AppBand end];
    
    STAssertNil([AppBand shared], @"should dealloc AppBand successful!");
}

- (void)testRegisterUserToken {
//    NSMutableDictionary *configOptions = [NSMutableDictionary dictionary];
//    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigRunEnvironment];
//    [configOptions setValue:@"42dfsa9fs0923" forKey:AppBandKickOfOptionsAppBandConfigSandboxKey];
//    [configOptions setValue:@"klksdfn3ugymazkid3isd" forKey:AppBandKickOfOptionsAppBandConfigSandboxSecret];
//    
//    NSMutableDictionary *kickOffOptions = [NSMutableDictionary dictionary];
//    [kickOffOptions setValue:configOptions forKey:AppBandKickOfOptionsAppBandConfigKey];
//    
//    [AppBand kickoff:kickOffOptions];
//    
//    NSData *token = [@"< 6288a74a 338309a3 3b34e604 a3468db3 537b4006 b5820083 e7a87df6 8aa64623 >" dataUsingEncoding:NSUTF8StringEncoding];
//    
//    [[AppBand shared] registerDeviceToken:token target:nil finishSelector:nil];
//    NSArray *operations = [[[ABRestCenter shared] queue] operations];
//    ABHTTPRequest *request = [operations objectAtIndex:0];
//    STAssertNotNil(request, @"should creat ABHTTPRequest successful!");
}

- (void)testHandlePushWhenActive {
    NSDictionary *notification = [NSDictionary dictionary];
    id abPushMock = [OCMockObject partialMockForObject:[ABPush shared]];
    [[abPushMock expect] callbackPushSelector:notification applicationState:UIApplicationStateActive target:nil pushSelector:nil];
    [abPushMock handleNotification:notification applicationState:UIApplicationStateActive target:nil pushSelector:nil richSelector:nil];
    [abPushMock verify];
}

- (void)testHandlePushWhenInactive {
    NSDictionary *notification = [NSDictionary dictionary];
    id abPushMock = [OCMockObject partialMockForObject:[ABPush shared]];
    [[abPushMock expect] callbackPushSelector:notification applicationState:UIApplicationStateInactive target:nil pushSelector:nil];
    [abPushMock handleNotification:notification applicationState:UIApplicationStateInactive target:nil pushSelector:nil richSelector:nil];
    [abPushMock verify];
}

- (void)testHandleRichWhenActive {
    NSString *rid = @"testRich1";
    NSDictionary *notification = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], AppBandPushNotificationType, rid, AppBandRichNotificationId, nil];
    
    id abPushMock = [OCMockObject partialMockForObject:[ABPush shared]];
    [[abPushMock expect] callbackRichSelector:notification applicationState:UIApplicationStateActive target:nil richSelector:nil richId:rid];
    [abPushMock handleNotification:notification applicationState:UIApplicationStateActive target:nil pushSelector:nil richSelector:nil];
    [abPushMock verify];
}

- (void)testHandleRichWhenInactive {
    NSString *rid = @"testRich1";
    NSDictionary *notification = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], AppBandPushNotificationType, rid, AppBandRichNotificationId, nil];
    
    id abPushMock = [OCMockObject partialMockForObject:[ABPush shared]];
    [[abPushMock expect] callbackRichSelector:notification applicationState:UIApplicationStateInactive target:nil richSelector:nil richId:rid];
    [abPushMock handleNotification:notification applicationState:UIApplicationStateInactive target:nil pushSelector:nil richSelector:nil];
    [abPushMock verify];
}

@end
