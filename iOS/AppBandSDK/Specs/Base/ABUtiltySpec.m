//
//  ABUtiltySpec.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/9/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "ABUtilty.h"

@interface ABUtiltySpec : SenTestCase

@end

@implementation ABUtiltySpec

// All code under test must be linked into the Unit Test bundle
- (void)testGetParameterData {
    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:@"Hello", @"key", nil];
    NSData *parameterData = getParameterData(parameter);
    
    NSString *parameterStr = [[NSString alloc] initWithData:parameterData encoding:NSUTF8StringEncoding];
    
    AB_SBJSON *json = [[AB_SBJSON alloc] init];
    NSDictionary *newParamter = [json objectWithString:parameterStr error:nil];
    [json release];
    
    NSString *shouldBeHello = [newParamter objectForKey:@"key"];
    STAssertTrue([shouldBeHello isEqualToString:@"Hello"], @"The two string should be same");
}

@end
