//
//  AppHub.m
//  AppHubDemo
//
//  Created by Jason Wang on 10/28/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

//#define kAppBandProductionServer @"https://api.apphub.com/v1"
//#define kAppBandProductionServer @"http://192.168.1.138:3000/v1"

#define kAppBandProductionServer @"https://api.appmocha.com/v1"

#import "AppBand.h"
#import "AppBand+Private.h"

static AppBand *_appBand;

@implementation AppBand

@synthesize server = _server;
@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize deviceToken = _deviceToken;
@synthesize udid = _udid;

@synthesize appRegistrationKey = _appRegistrationKey;

@synthesize registerTarget = _registerTarget;
@synthesize registerFinishSelector = _registerFinishSelector;

@synthesize handlePushAuto = _handlePushAuto;
@synthesize handleRichAuto = _handleRichAuto;
@synthesize defaultViewSupportOrientation = _defaultViewSupportOrientation;

#pragma mark - Private

- (NSString *)udid {
    if (!_udid) {
        _udid = [[ABDataStoreCenter shared] getValueOfKey:kAppBandDeviceUDID];
        if (!_udid) {
            UIDeviceUDID *deviceUDID = [[UIDeviceUDID alloc] init];
            _udid = [[deviceUDID uniqueDeviceIdentifier] copy];
            [[ABDataStoreCenter shared] setValue:_udid forKey:kAppBandDeviceUDID];
            [deviceUDID release];
        }
    }
    
    return _udid;
}

- (void)updateDeviceToken:(NSData*)tokenData {
    NSString *token = [self parseDeviceToken:[tokenData description]];
    if (![self.deviceToken isEqualToString:token])
        self.deviceToken = token;
}

- (NSString*)parseDeviceToken:(NSString*)tokenStr {
    return [[[tokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""]
             stringByReplacingOccurrencesOfString:@">" withString:@""]
            stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (void)setDeviceToken:(NSString*)tokenStr {
    [_deviceToken release]; 
    _deviceToken = [tokenStr copy];
    
    [[ABDataStoreCenter shared] setValue:_deviceToken forKey:kAppBandDeviceToken];
}

- (void)appRegisterWithExtraInfo:(NSDictionary *)info {
    NSString *urlString = [NSString stringWithFormat:@"%@%@",
                           self.server, @"/app_registrations"];
    
    NSString *token = self.deviceToken ? self.deviceToken : @"";
    
    NSNumber *enableNum = [NSNumber numberWithBool:[[ABPush shared] getPushEnabled]];
    NSDictionary *settingDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[enableNum intValue]], AB_APP_PUSH_CONFIGURATION_ENABLED, [self getIntervalsArray:[[ABPush shared] getPushDNDIntervals]], AB_APP_PUSH_CONFIGURATION_UNAVAILABLE_INTERVALS, nil];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:info];
    [parameters setObject:token forKey:AB_DEVICE_TOKEN];
    [parameters setObject:settingDic forKey:AB_APP_SETTING];
    [parameters setObject:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:AB_APP_LANGUAGE];
    [parameters setObject:[[NSTimeZone systemTimeZone] name] forKey:AB_APP_TIMEZONE];
    [parameters setObject:[UIDevice currentDevice].model forKey:AB_APP_DEVICE_TYPE];
    [parameters setObject:[UIDevice currentDevice].systemVersion forKey:AB_APP_OS_VERSION];
    
    ABHTTPRequest *request = [ABHTTPRequest requestWithKey:self.appRegistrationKey
                                                       url:urlString 
                                                 parameter:parameters
                                                   timeout:kAppBandRequestTimeout
                                                  delegate:self
                                                    finish:@selector(registerDeviceTokenEnd:)
                                                      fail:@selector(registerDeviceTokenEnd:)];
    [[ABRestCenter shared] addRequest:request];
}

- (void)registerDeviceTokenEnd:(NSDictionary *)response {
    ABResponseCode code = [[response objectForKey:ABHTTPResponseKeyCode] intValue];
    if (code == ABResponseCodeHTTPSuccess) 
        [[ABDataStoreCenter shared] synchronizedWithServer];
    
    NSString *requestKey = [response objectForKey:ABHTTPResponseKey];
    if ([self.appRegistrationKey isEqualToString:requestKey] && [self.registerTarget respondsToSelector:self.registerFinishSelector]) {
        ABResponse *r = [[[ABResponse alloc] init] autorelease];
        [r setCode:code];
        [r setError:[response objectForKey:ABHTTPResponseKeyError]];
        
        [self.registerTarget performSelector:self.registerFinishSelector withObject:r];
    }
}

- (NSString *)getTagsString:(NSDictionary *)tags {
    NSString *tagsStr = @"";
    NSArray *tagsKey = [tags allKeys];
    
    for (int index = 0; index < [tagsKey count]; index++) {
        NSString *key = [tagsKey objectAtIndex:index];
        id value = [tags objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            NSString *tmp = nil;
            if (index < [tagsKey count] - 1) {
                tmp = [NSString stringWithFormat:@"%@=%@, ", key, value];
            } else {
                tmp = [NSString stringWithFormat:@"%@=%@", key, value];
            }
            tagsStr = [tagsStr stringByAppendingString:tmp];
        }
    }
    
    if ([tagsStr length] > 500) {
        tagsStr = [tagsStr substringToIndex:499];
    }
    
    return tagsStr;
}

- (NSArray *)getIntervalsArray:(NSArray *)array {
    if ([array count] < 1) return [NSArray array];
    
    NSMutableArray *tmp = [NSMutableArray array];
    for (NSDictionary *interval in array) {
        NSDate *bTime = [interval  objectForKey:AppBandPushIntervalBeginTimeKey];
        NSDate *eTime = [interval objectForKey:AppBandPushIntervalEndTimeKey];
        
        [tmp addObject:[NSDictionary dictionaryWithObjectsAndKeys:getUTCFromeDate(bTime), AppBandPushIntervalBeginTimeKey, getUTCFromeDate(eTime), AppBandPushIntervalEndTimeKey, nil]];
    }
    
    return [NSArray arrayWithArray:tmp];
}

/*
 * Application Register
 * 
 * Paramters:
 *         target: the object takes charge of perform finish selector.
 *  finishSeletor: callback when registration finished. Notice that : The selector must only has one paramter, which is ABRegisterTokenResponse object. e.g. - (void)registerDeviceTokenFinished:(ABRegisterTokenResponse *)response
 */
- (void)appRegistrationWithTarget:(id)target finishSelector:(SEL)finishSeletor {
    if ([[ABDataStoreCenter shared] isDuty]) {
        self.registerTarget = target;
        self.registerFinishSelector = finishSeletor;
        self.appRegistrationKey = [[NSDate date] description];
        
        NSString *alias = [[ABDataStoreCenter shared] getValueOfKey:kAppBandDeviceAlias] ? [[ABDataStoreCenter shared] getValueOfKey:kAppBandDeviceAlias] : @"";
        NSString *tags = [[ABDataStoreCenter shared] getValueOfKey:kAppBandDeviceAlias] ? [self getTagsString:[[ABDataStoreCenter shared] getValueOfKey:kAppBandDeviceTags]] : @"";
        
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:self.appKey forKey:AB_APP_KEY];
        [info setValue:self.appSecret forKey:AB_APP_SECRET];
        [info setObject:self.udid forKey:AB_DEVICE_UDID];
        [info setObject:alias forKey:AB_APP_ALIAS];
        [info setObject:tags forKey:AB_APP_TAGS];
        
        NSString *bundleVersion = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
        
        
        if (bundleVersion) {
            [info setObject:bundleVersion forKey:AB_APP_BUNDLE_VERSION];
        }
        
        if (bundleId) {
            [info setObject:bundleId forKey:AB_APP_BUNDLE_IDENTIFIER];
        }
        
        [[AppBand shared] appRegisterWithExtraInfo:info];
    } else {
        if ([self.registerTarget respondsToSelector:self.registerFinishSelector]) {
            ABResponse *r = [[[ABResponse alloc] init] autorelease];
            [r setCode:ABResponseCodeHTTPSuccess];
            [r setError:nil];
            
            [self.registerTarget performSelector:self.registerFinishSelector withObject:r];
        }
    }
}

- (void)backgroundUpdate {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [_appBand appRegistrationWithTarget:nil finishSelector:nil];
    [pool drain];
}

#pragma mark - AppBand Mehods

/*
 * initialize AppBand and Set Configuration. 
 * 
 * Paramters:
 *          options: App Launch Options and AppBand Configuration.
 */
+ (void)kickoff:(NSDictionary *)options {
    if (_appBand) {
        return;
    }

    //Application launch options
    //    NSDictionary *launchOptions = [options objectForKey:AppBandKickOfOptionsLaunchOptionsKey];
    
    // Load configuration
    // Primary configuration comes from the AppBandKickOfOptionsAppBandConfigKey dictionary and will
    // override any options defined in AppBandConfig.plist
    NSMutableDictionary *config;
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"AppBandConfig" ofType:@"plist"];
    
    if (configPath) {
        config = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
        [config addEntriesFromDictionary:[options objectForKey:AppBandKickOfOptionsAppBandConfigKey]];
    } else {
        config = [NSMutableDictionary dictionaryWithDictionary:[options objectForKey:AppBandKickOfOptionsAppBandConfigKey]];
    }
    
    if ([config count] > 0) {
        BOOL inProduction = [[config objectForKey:AppBandKickOfOptionsAppBandConfigRunEnvironment] boolValue];
        
        NSString *configAppKey;
        NSString *configAppSecret;
        
        if (inProduction) {
            configAppKey = [config objectForKey:AppBandKickOfOptionsAppBandConfigProductionKey];
            configAppSecret = [config objectForKey:AppBandKickOfOptionsAppBandConfigProductionSecret];
        } else {
            configAppKey = [config objectForKey:AppBandKickOfOptionsAppBandConfigSandboxKey];
            configAppSecret = [config objectForKey:AppBandKickOfOptionsAppBandConfigSandboxSecret];
        }
        
        // strip leading and trailing whitespace
        configAppKey = [configAppKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        configAppSecret = [configAppSecret stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        //Check for a custom AppBand server value
        NSString *airshipServer = [config objectForKey:AppBandKickOfOptionsAppBandConfigServer];
        if (airshipServer == nil) {
            airshipServer = kAppBandProductionServer;
        }
        
        if (configAppKey && configAppSecret) {
            _appBand = [[AppBand alloc] initWithKey:configAppKey secret:configAppSecret];
            _appBand.server = airshipServer;
            _appBand.handlePushAuto = [config objectForKey:AppBandKickOfOptionsAppBandConfigHandlePushAuto] ? [[config objectForKey:AppBandKickOfOptionsAppBandConfigHandlePushAuto] boolValue] : YES;
            _appBand.handleRichAuto = [config objectForKey:AppBandKickOfOptionsAppBandConfigHandleRichAuto] ? [[config objectForKey:AppBandKickOfOptionsAppBandConfigHandleRichAuto] boolValue] : YES;
        }
    } 
    
    if (!_appBand) {
        DLog(@"AppBand initialize fail, check AppBandConfig.plist configuration!");
        exit(-1);
    } 
    
    [_appBand performSelectorInBackground:@selector(backgroundUpdate) withObject:nil];
}

/*
 * Get AppBand Singleton Object
 * 
 */
+ (id)shared {
    return _appBand;
}

/*
 * Release
 * 
 */
+ (void)end {
    [_appBand release];
    _appBand = nil;
}

/*
 * Get SDK Version
 * 
 */
- (NSString *)getVersion {
    return APPBAND_SDK_VERSION;
}

/*
 * Set Device Token
 * 
 * Paramters:
 *          token: the token of the Device.
 */
- (void)setPushToken:(NSData *)token {
    [[AppBand shared] updateDeviceToken:token];
}

/*
 * Set Alias
 * 
 * Paramters:
 *          alias: the Alias of the Device.
 */
- (void)setAlias:(NSString *)alias {
    if (!alias) return;
    
    NSString *tmp = [NSString stringWithString:alias];
    if ([alias length] > 30) {
        NSLog(@"Warning! The Alias(%@) length is more than 30, will be cut",alias);
        tmp = [alias substringToIndex:29];
    }
    
    [[ABDataStoreCenter shared] setValue:tmp forKey:kAppBandDeviceAlias];
}

/*
 * Get Alias
 * 
 */
- (NSString *)getAlias {
    return [[ABDataStoreCenter shared] getValueOfKey:kAppBandDeviceAlias];
}

/*
 * Set Tags
 * 
 * Paramters:
 *          tags: tag dictionary.
 */
- (void)setTags:(NSDictionary *)tags {
    if ([[tags allKeys] count] > 5) {
        NSLog(@"Warning! The number of tags > 5");
    }
    [[ABDataStoreCenter shared] setValue:tags forKey:kAppBandDeviceTags];
}

/*
 * Set Tag
 * 
 * Paramters:
 *           key: The key of the tag.
 *         value: The value of the tag.
 */
- (void)setTag:(NSString *)key value:(NSString *)value {
    if (!key) return;
    
    NSDictionary *tags = [[ABDataStoreCenter shared] getValueOfKey:kAppBandDeviceTags];
    
    NSMutableDictionary *tmp = [NSMutableDictionary dictionary];
    if (tags) {
        if ([[tags allKeys] count] >= 5) {
            NSLog(@"Warning! The number of tags > 5");
        }
        [tmp addEntriesFromDictionary:tags];
    }
    
    if (!value) {
        [tmp removeObjectForKey:key];
    } else {
        [tmp setObject:value forKey:key];
    }
    
    [[ABDataStoreCenter shared] setValue:[NSDictionary dictionaryWithDictionary:tmp] forKey:kAppBandDeviceTags];
}

/*
 * Get Tags
 * 
 */
- (NSDictionary *)getTags {
    return [[ABDataStoreCenter shared] getValueOfKey:kAppBandDeviceTags];
}

/*
 * Update Settings
 * 
 * Paramters:
 *         target: the object takes charge of perform finish selector.
 *  finishSeletor: callback when registration finished. Notice that : The selector must only has one paramter, which is ABResponse object.
 */
- (void)updateSettingsWithTarget:(id)target finishSelector:(SEL)finishSeletor {
    [self appRegistrationWithTarget:target finishSelector:finishSeletor];
}

#pragma mark - singleton

- (id)initWithKey:(NSString *)key secret:(NSString *)secret {
    self = [super init];
    if (self) {
        self.appKey = key;
        self.appSecret = secret;
        
        _deviceToken = [[[ABDataStoreCenter shared] getValueOfKey:kAppBandDeviceToken] copy];
    }
    
    return self;
}

- (void)dealloc {
    [self setAppRegistrationKey:nil];
    [self setServer:nil];
    [self setDeviceToken:nil];
    [self setAppKey:nil];
    [self setAppSecret:nil];
	[super dealloc];
}

@end
