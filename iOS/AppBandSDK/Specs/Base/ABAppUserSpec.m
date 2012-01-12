//
//  ABAppUserSpec.m
//  AppBandSDK
//
//  Created by Yan Liu on 1/10/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABSpecEnvironment.h"

#import "ABAppUser+Private.h"
#import "ABHttpRequest+Private.h"

@interface ABAppUserSpec :ABSpec {
}
@end

@implementation ABAppUserSpec

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

//- (void)testShouldSetDirtyFlagWhenBeingUpdated {
//    id settingsMock = [OCMockObject niceMockForClass:[ABAppUserSettings class]];
//    id value = nil;
//    [[[settingsMock stub] andReturnValue:OCMOCK_VALUE(value)] getValueOfKey:[OCMArg any]];
//    ABAppUser *appUser = [[[ABAppUser alloc] initWithSettings:settingsMock] autorelease];
//    id mock = [OCMockObject partialMockForObject:appUser];
//    [[mock expect] addToBaseNetworkQueue:[OCMArg isNotNil]];
//    [appUser syncDataToServerWithTarget:nil finishSelector:nil];
//    
//    [mock verify];
//}

- (void)testSyncLocalDataToServerSuccessfully {
    ABAppUserSettings *settings = [[ABAppUserSettings alloc] init];
    
    ABAppUser *appUser = [[[ABAppUser alloc] initWithSettings:settings] autorelease];
    [appUser setAlias:@"Jason"];
    
    id mock = [OCMockObject partialMockForObject:appUser]; 
    ABHttpRequest *request = [ABHttpRequest requestWithKey:nil url:@"" parameter:nil timeout:5. delegate:appUser];
    id httpRequestMock = [OCMockObject partialMockForObject:request];
    [[[mock stub] andReturn:httpRequestMock] initializeRequest];
    
    [[[mock stub] andCall:@selector(callSyncDataServiceSuccess:) onObject:self] addToBaseNetworkQueue:[OCMArg any]];
    
    [appUser syncDataToServerWithTarget:nil];
    
    NSString *alias = [settings getValueOfKey:kAppBandDeviceAlias];
    STAssertTrue([alias isEqualToString:@"Jason"], @"Alias should be Jason");
    [settings setValue:nil forKey:kAppBandDeviceAlias];
    [settings synchronized];
    [settings release];
}

//- (void)testShouldNotSyncWhenDirtyFlagIsNotSet {
////    id settingsMock = [OCMockObject niceMockForClass:[ABAppUserSettings class]];
////    [[[settingsMock stub] andCall:@selector(returnNoWhenItsDutyKey:) onObject:self] getValueOfKey:[OCMArg any]];
//    
//    ABAppUserSettings *settings = [[[ABAppUserSettings alloc] init] autorelease];
//    [settings setValue:[NSNumber numberWithBool:NO] forKey:kAppBandDeviceDirty];
//    
//    ABAppUser *appUser = [[[ABAppUser alloc] initWithSettings:settings] autorelease];
//    
//    
//    STAssertTrue(appUser.isDirty == NO, @"ABAppUser isDirty should be NO");
//    [settings setValue:nil forKey:kAppBandDeviceDirty];
//    [settings synchronized];
//}

- (void)callSyncDataServiceSuccess:(ABHttpRequest *)request {
    [request finishLoadingWithError:nil];
}

@end
