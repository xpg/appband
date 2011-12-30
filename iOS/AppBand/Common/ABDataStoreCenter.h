//
//  ABDataStoreCenter.h
//  AppBandLib
//
//  Created by Jason Wang on 12/26/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#define kAppBandDeviceDuty @"AppBandDeviceDuty"
#define kAppBandDeviceUDID @"AppBandDeviceUDID"

#define kAppBandDeviceToken @"AppBandDeviceToken"
#define kAppBandDeviceAlias @"AppBandDeviceAlias"
#define kAppBandDeviceTags @"AppBandDeviceTags"

#define kAppBandDevicePushEnableKey @"AppBandDevicePushEnable"
#define kAppBandDevicePushDNDIntervalsKey @"AppBandDevicePushDNDIntervals"

#import <Foundation/Foundation.h>

#import "ABConstant.h"

@interface ABDataStoreCenter : NSObject

SINGLETON_INTERFACE(ABDataStoreCenter)

- (BOOL)isDuty;

- (id)getValueOfKey:(NSString *)key;

- (void)setValue:(id)value forKey:(NSString *)key;

- (void)setValuesAndKeys:(NSDictionary *)valuesAndKeys;

- (void)synchronizedWithServer;

@end
