//
//  ABAppUser.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/10/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABAppUser+Private.h"

@implementation ABAppUser

@synthesize token = _token;
@synthesize udid = _udid;
@synthesize alias = _alias;
@synthesize tags = _tags;
@synthesize pushEnable = _pushEnable;
@synthesize pushIntervals = _pushIntervals;

@synthesize isDirty = _isDirty;

@synthesize settings = _settings;

- (void)setToken:(NSString *)token {
    if (![token isEqualToString:self.token]) {
        [_token release];
        _token = [token copy];
        _isDirty = YES;
    }
}

- (void)setAlias:(NSString *)alias {
    if (![alias isEqualToString:self.alias]) {
        [_alias release];
        _alias = [alias copy];
        _isDirty = YES;
    }
}

- (void)setTags:(NSString *)tags {
    if ([tags length] > 500) {
        tags = [tags substringToIndex:499];
    }
    
    if (![tags isEqualToString:self.tags]) {
        [_tags release];
        _tags = [tags copy];
        _isDirty = YES;
    }
}

- (void)setPushEnable:(BOOL)pushEnable {
    if (self.pushEnable != pushEnable) {
        _pushEnable = pushEnable;
        _isDirty = YES;
    }
}

- (void)setPushIntervals:(NSString *)pushIntervals {
    if (![pushIntervals isEqualToString:self.pushIntervals]) {
        [_pushIntervals release];
        _pushIntervals = [pushIntervals copy];
        _isDirty = YES;
    }
}

#pragma mark - Private

- (ABHttpRequest *)initializeRequest {
    NSString *url = [NSString stringWithFormat:@"%@/app_registrations", [[AppBand shared] server]];
    
    NSString *token = self.token ? self.token : @"";
    NSString *appKey = [[AppBand shared] appKey];
    NSString *appSecret = [[AppBand shared] appSecret];
    NSString *udid = self.udid;
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    NSString *alias = self.alias ? self.alias : @"";
    NSString *tagsStr = self.tags ? self.tags : @"";
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:udid, AB_DEVICE_UDID, bundleId, AB_APP_BUNDLE_IDENTIFIER, appKey, AB_APP_KEY, appSecret, AB_APP_SECRET, token, AB_DEVICE_TOKEN, alias, AB_APP_ALIAS, tagsStr, AB_APP_TAGS, [[NSLocale preferredLanguages] objectAtIndex:0], AB_APP_LANGUAGE, [[NSTimeZone systemTimeZone] name], AB_APP_TIMEZONE, [UIDevice currentDevice].model, AB_APP_DEVICE_TYPE, [UIDevice currentDevice].systemVersion, AB_APP_OS_VERSION, nil];
    
    ABHttpRequest *request = [ABHttpRequest requestWithKey:nil url:url parameter:getParameterData(parameters) timeout:AppBandSettingsTimeout delegate:self];
    [request setContentType:@"application/json"];
    
    return request;
}

- (void)addToBaseNetworkQueue:(ABHttpRequest *)request {
    [[[AppBand shared] networkQueue] addOperation:request];
}

#pragma mark - Public

/*
 * Synchronize Device Data to Server. 
 * 
 */
- (void)syncDataToServer {
    if (self.isDirty) {
        ABLogInfo(@"Starting registration service");
        ABHttpRequest *request = [self initializeRequest];
        [self addToBaseNetworkQueue:request];
    }
}

#pragma mark - lifecycle

- (id)initWithSettings:(ABAppUserSettings *)settings {
    self = [self init];
    if (self) {
        self.settings = settings;
        
        _isDirty = [settings getValueOfKey:kAppBandDeviceDirty] ? [[settings getValueOfKey:kAppBandDeviceDirty] boolValue] : YES;
        _token = [settings getValueOfKey:kAppBandDeviceToken];
        _udid = [settings getValueOfKey:kAppBandDeviceUDID] ? [settings getValueOfKey:kAppBandDeviceUDID] : @"";
        _alias = [settings getValueOfKey:kAppBandDeviceAlias];
        _tags = [settings getValueOfKey:kAppBandDeviceTags];
        _pushEnable = [settings getValueOfKey:kAppBandDevicePushEnableKey] ? [[settings getValueOfKey:kAppBandDevicePushEnableKey] boolValue] : YES;
        _pushIntervals = [settings getValueOfKey:kAppBandDevicePushDNDIntervalsKey];
    }
    
    return self;
}

- (void)dealloc {
    [_token release];
    [_udid release];
    [_alias release];
    [_tags release];
    [_pushIntervals release];
    [self setSettings:nil];
    [super dealloc];
}

@end

@implementation ABAppUserSettings

- (id)getValueOfKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if (!key) 
        return;
    
    if (!value) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    } else  {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    }
}

- (void)synchronized {
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
