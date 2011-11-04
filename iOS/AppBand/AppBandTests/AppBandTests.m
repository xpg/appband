//
//  AppBandTests.m
//  AppBandTests
//
//  Created by Jason Wang on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppBandTests.h"

#import "AppBand.h"
#import "ABPush.h"
#import "ABRest.h"
#import "ABConstant.h"
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
    
    NSMutableDictionary *kickOffOptions = [NSMutableDictionary dictionary];
    [kickOffOptions setValue:configOptions forKey:AppBandKickOfOptionsAppBandConfigKey];
    
    [AppBand kickoff:kickOffOptions];
    
    STAssertNotNil([AppBand shared],@"should initialize AppBand successful!");
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
    NSMutableDictionary *configOptions = [NSMutableDictionary dictionary];
    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigRunEnvironment];
    [configOptions setValue:@"42dfsa9fs0923" forKey:AppBandKickOfOptionsAppBandConfigSandboxKey];
    [configOptions setValue:@"klksdfn3ugymazkid3isd" forKey:AppBandKickOfOptionsAppBandConfigSandboxSecret];
    
    NSMutableDictionary *kickOffOptions = [NSMutableDictionary dictionary];
    [kickOffOptions setValue:configOptions forKey:AppBandKickOfOptionsAppBandConfigKey];
    
    [AppBand kickoff:kickOffOptions];
    
    NSData *token = [@"< 6288a74a 338309a3 3b34e604 a3468db3 537b4006 b5820083 e7a87df6 8aa64623 >" dataUsingEncoding:NSUTF8StringEncoding];
    
    [[AppBand shared] registerDeviceToken:token];
    NSArray *operations = [[[[AppBand shared] abRest] queue] operations];
    ABHTTPRequest *request = [operations objectAtIndex:0];
    STAssertNotNil(request, @"should creat ABHTTPRequest successful!");
//    id appBandMock = [OCMockObject partialMockForObject:[AppBand shared]];
//    [[appBandMock expect] updateDeviceToken:token];
//    [appBandMock registerDeviceToken:token];
//    [appBandMock verify];
}

- (void)testHandlePushWhenActive {
    NSDictionary *notification = [NSDictionary dictionary];
    id abPushMock = [OCMockObject partialMockForObject:[ABPush shared]];
    [[abPushMock expect] handlePushWhenActive:notification];
    [abPushMock handleNotification:notification applicationState:UIApplicationStateActive];
    [abPushMock verify];
}

- (void)testHandlePushWhenLaunch {
    id abPushMock = [OCMockObject partialMockForObject:[ABPush shared]];
    
    NSDictionary *notification = [NSDictionary dictionary];
    
    NSMutableDictionary *configOptions = [NSMutableDictionary dictionary];
    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigRunEnvironment];
    [configOptions setValue:@"42dfsa9fs0923" forKey:AppBandKickOfOptionsAppBandConfigSandboxKey];
    [configOptions setValue:@"klksdfn3ugymazkid3isd" forKey:AppBandKickOfOptionsAppBandConfigSandboxSecret];
    
    NSMutableDictionary *launchOptions = [NSMutableDictionary dictionary];
    [launchOptions setValue:notification forKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    NSMutableDictionary *kickOffOptions = [NSMutableDictionary dictionary];
    [kickOffOptions setValue:configOptions forKey:AppBandKickOfOptionsAppBandConfigKey];
    [kickOffOptions setValue:launchOptions forKey:AppBandKickOfOptionsLaunchOptionsKey];
    
    [[abPushMock expect] handlePushWhenNonActive:notification];
    [AppBand kickoff:kickOffOptions];
    [abPushMock verify];
}

- (void)testHandlePushWhenBackground {
    NSDictionary *notification = [NSDictionary dictionary];
    id abPushMock = [OCMockObject partialMockForObject:[ABPush shared]];
    [[abPushMock expect] handlePushWhenNonActive:notification];
    [abPushMock handleNotification:notification applicationState:UIApplicationStateInactive];
    [abPushMock verify];
}

@end
