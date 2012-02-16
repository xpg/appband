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

@synthesize geo = _geo;

//@synthesize isDirty = _isDirty;

@synthesize settings = _settings;
@synthesize target = _target;

@synthesize requestKey = _requestKey;

- (void)setToken:(NSString *)token {
    if (![token isEqualToString:self.token]) {
        [_token release];
        _token = [token copy];
        
        [self.settings setValue:_token forKey:kAppBandDeviceToken];
        [self.settings synchronized];
//        _isDirty = YES;
    }
}

- (void)setAlias:(NSString *)alias {
    if (![alias isEqualToString:self.alias]) {
        [_alias release];
        _alias = [alias copy];
        
        [self.settings setValue:_alias forKey:kAppBandDeviceAlias];
        [self.settings synchronized];
//        _isDirty = YES;
    }
}

- (void)setTags:(NSString *)tags {
    if ([tags length] > 500) {
        tags = [tags substringToIndex:499];
    }
    
    if (![tags isEqualToString:self.tags]) {
        [_tags release];
        _tags = [tags copy];
        
        [self.settings setValue:_tags forKey:kAppBandDeviceTags];
        [self.settings synchronized];
//        _isDirty = YES;
    }
}

- (void)setPushEnable:(BOOL)pushEnable {
    if (self.pushEnable != pushEnable) {
        _pushEnable = pushEnable;
        
        [self.settings setValue:[NSNumber numberWithBool:_pushEnable] forKey:kAppBandDevicePushEnableKey];
        [self.settings synchronized];
//        _isDirty = YES;
    }
}

- (void)setPushIntervals:(NSArray *)pushIntervals {
    [_pushIntervals release];
    _pushIntervals = [pushIntervals copy];
    
    [self.settings setValue:_pushIntervals forKey:kAppBandDevicePushDNDIntervalsKey];
    [self.settings synchronized];
}

#pragma mark - ABHttpRequestDelegate

- (void)httpRequest:(ABHttpRequest *)httpRequest didFinishLoadingWithError:(NSError *)error {
    if ([self.requestKey isEqualToString:httpRequest.key]) {
        if ([self.target respondsToSelector:@selector(finishUpdateSettings:)]) {
            ABResponse *response = [[[ABResponse alloc] init] autorelease];
            [response setCode:(ABResponseCode)httpRequest.status];
            [response setError:error];
            [self.target finishUpdateSettings:response];
        }
    }
}

#pragma mark - Private

- (ABHttpRequest *)initializeRequest {
    NSString *url = [NSString stringWithFormat:@"%@/app_registrations", [[[AppBand shared] configuration] server]];
    
    NSString *token = self.token ? self.token : @"";
    NSString *appKey = [[AppBand shared] appKey];
    NSString *appSecret = [[AppBand shared] appSecret];
    NSString *udid = self.udid;
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    NSString *alias = self.alias ? self.alias : @"";
    NSString *tagsStr = self.tags ? self.tags : @"";
    
    NSDictionary *settingDic = nil;
    
    if (self.pushIntervals) {
        settingDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:self.pushEnable], AB_APP_PUSH_CONFIGURATION_ENABLED, self.pushIntervals, AB_APP_PUSH_CONFIGURATION_UNAVAILABLE_INTERVALS, nil];
    } else {
        settingDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:self.pushEnable], AB_APP_PUSH_CONFIGURATION_ENABLED, nil];
    }
    
    NSDictionary *parameters;
    if (self.geo) {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:udid, AB_DEVICE_UDID, bundleId, AB_APP_BUNDLE_IDENTIFIER, appKey, AB_APP_KEY, appSecret, AB_APP_SECRET, token, AB_DEVICE_TOKEN, alias, AB_APP_ALIAS, tagsStr, AB_APP_TAGS, settingDic, AB_APP_SETTING, [[NSLocale preferredLanguages] objectAtIndex:0], AB_APP_LANGUAGE, [[NSTimeZone systemTimeZone] name], AB_APP_TIMEZONE, [UIDevice currentDevice].model, AB_APP_DEVICE_TYPE, [UIDevice currentDevice].systemVersion, AB_APP_OS_VERSION, self.geo, AB_APP_GEO, nil];
    } else {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:udid, AB_DEVICE_UDID, bundleId, AB_APP_BUNDLE_IDENTIFIER, appKey, AB_APP_KEY, appSecret, AB_APP_SECRET, token, AB_DEVICE_TOKEN, alias, AB_APP_ALIAS, tagsStr, AB_APP_TAGS, settingDic, AB_APP_SETTING, [[NSLocale preferredLanguages] objectAtIndex:0], AB_APP_LANGUAGE, [[NSTimeZone systemTimeZone] name], AB_APP_TIMEZONE, [UIDevice currentDevice].model, AB_APP_DEVICE_TYPE, [UIDevice currentDevice].systemVersion, AB_APP_OS_VERSION, nil];
    }
    
    ABHttpRequest *request = [ABHttpRequest requestWithKey:self.requestKey url:url parameter:getParameterData(parameters) timeout:AppBandSettingsTimeout delegate:self];
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
- (void)syncDataToServerWithTarget:(id)target {
//    if (self.isDirty) {
        ABLogInfo(@"Starting registration service");
        
        self.target = target;

        self.requestKey = [[NSDate date] description];
        ABHttpRequest *request = [self initializeRequest];
        [self addToBaseNetworkQueue:request];
//    }
}

#pragma mark - lifecycle

- (id)initWithSettings:(ABAppUserSettings *)settings {
    self = [self init];
    if (self) {
        self.settings = settings;
        
//        _isDirty = [settings getValueOfKey:kAppBandDeviceDirty] ? [[settings getValueOfKey:kAppBandDeviceDirty] boolValue] : YES;
        _token = [[settings getValueOfKey:kAppBandDeviceToken] copy];
        _alias = [[settings getValueOfKey:kAppBandDeviceAlias] copy];
        _tags = [[settings getValueOfKey:kAppBandDeviceTags] copy];
        _pushEnable = [settings getValueOfKey:kAppBandDevicePushEnableKey] ? [[settings getValueOfKey:kAppBandDevicePushEnableKey] boolValue] : YES;
        _pushIntervals = [[settings getValueOfKey:kAppBandDevicePushDNDIntervalsKey] copy];
        
        _udid = [[settings getValueOfKey:kAppBandDeviceUDID] copy];
        if (!_udid || [_udid isEqualToString:@""]) {
            UIDeviceUDID *deviceUDID = [[UIDeviceUDID alloc] init];
            _udid = [[deviceUDID uniqueDeviceIdentifier] copy];
            [deviceUDID release];
        }
        
    }
    
    return self;
}

- (void)dealloc {
    [_token release];
    [_udid release];
    [_alias release];
    [_tags release];
    [_pushIntervals release];
    [_geo release];
    [self setSettings:nil];
    [self setRequestKey:nil];
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
