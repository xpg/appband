//
//  ABAppUser+Private.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/10/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#define kAppBandDeviceDirty @"kAppBandDeviceDirty"
#define kAppBandDeviceUDID @"AppBandDeviceUDID"

#define kAppBandDeviceToken @"AppBandDeviceToken"
#define kAppBandDeviceAlias @"AppBandDeviceAlias"
#define kAppBandDeviceTags @"AppBandDeviceTags"

#define kAppBandDevicePushEnableKey @"AppBandDevicePushEnable"
#define kAppBandDevicePushDNDIntervalsKey @"AppBandDevicePushDNDIntervals"

#import "ABAppUser.h"

#import "ABHttpRequest.h"
#import "AppBand+Private.h"
#import "ABUtilty.h"
#import "UIDevice+IdentifierAddition.h"

#import "ABPrivateConstants.h"

@interface ABAppUser() <ABHttpRequestDelegate>

@property(nonatomic,retain) ABAppUserSettings *settings;

@property(nonatomic,assign) id<ABUpdateSettingsProtocol> target;

@property(nonatomic,copy) NSString *requestKey;

//@property(assign) BOOL isDirty;

- (ABHttpRequest *)initializeRequest;

- (void)addToBaseNetworkQueue:(ABHttpRequest *)request;

@end


