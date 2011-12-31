//
//  AppBandLibTests.m
//  AppBandLibTests
//
//  Created by Jason Wang on 12/16/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "AppBand.h"
#import "AppBand+Private.h"

@interface AppBandTests : SenTestCase {
@private
    AppBand *_appBand;
}

@end

@implementation AppBandTests

- (void)setUp {
    
    _appBand = [[AppBand alloc] initWithKey:@"3" secret:@"50b8644c-1e7c-11e1-80e7-001ec9b6dcfc"];
    [_appBand setServer:kAppBandProductionServer];
    [super setUp];
}

- (void)tearDown {
    [_appBand release];
    [super tearDown];
}

- (void)testGetVersion {
    NSString *version = [_appBand getVersion];
    BOOL isEqual = [version isEqualToString:APPBAND_SDK_VERSION];
    STAssertTrue(isEqual, @"The Version should equal to defined in ABGlobal.h");
}

- (void)testSetAlias {
    [_appBand setAlias:@"Jason"];
    NSString *alias = [_appBand getAlias];
    STAssertTrue([alias isEqualToString:@"Jason"], @"Should save Alias successful");
    [_appBand setAlias:nil];
}

- (void)testSetTags {
    [_appBand setTags:[NSDictionary dictionaryWithObjectsAndKeys:@"zh", AppBandTagPreferKeyCountry, nil]];
    NSDictionary *tags = [_appBand getTags];
    NSString *country = [tags objectForKey:AppBandTagPreferKeyCountry];
    STAssertTrue([country isEqualToString:@"zh"], @"Should save tags successful");
    [_appBand setTags:nil];
}

@end
