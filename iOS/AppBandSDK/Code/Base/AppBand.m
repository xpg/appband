//
//  AppBandBase.m
//  AppBandBase
//
//  Created by Yan Liu on 1/4/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "AppBand+Private.h"

static AppBand *_appBand;

@implementation AppBand

@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;

@synthesize configuration = _configuration;
@synthesize appUser = _appUser;
@synthesize networkQueue = _networkQueue;

#pragma mark - Public

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
        
        if (configAppKey && configAppSecret) {
            _appBand = [[AppBand alloc] initWithKey:configAppKey secret:configAppSecret];
            [_appBand initializeEnvironment:config];
        }
    } 
    
    if (!_appBand) {
        ABLogInfo(@"AppBand initialize fail, check AppBandConfig.plist configuration!");
        exit(-1);
    }
    
    [_appBand doProvisioningWhenKickoff];
    [_appBand updateSettingsWithTarget:nil];
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
    [_appBand.networkQueue cancelAllOperations];
    [_appBand setNetworkQueue:nil];
    [_appBand setConfiguration:nil];
    [_appBand setAppUser:nil];
    [_appBand release];
    _appBand = nil;
}

/*
 * Update Settings
 * 
 * Paramters:
 *         target: the object takes charge of perform finish selector.
 *  finishSeletor: callback when registration finished. Notice that : The selector must only has one paramter, which is ABResponse object.
 */
- (void)updateSettingsWithTarget:(id<ABUpdateSettingsProtocol>)target {
    [self.appUser syncDataToServerWithTarget:target];
}

/*
 * Set Device Token
 * 
 * Paramters:
 *          token: the token of the Device.
 */
- (void)setPushToken:(NSData *)token {
    [self.appUser setTokenDisable:NO];
    [self.appUser setToken:[self parseDeviceToken:[token description]]];
}

/*
 * Fetch Device Token Failed
 * 
 */
- (void)fetchPushTokenFailed {
    [self.appUser setTokenDisable:YES];
}

/*
 * Set Alias (Max Length 30)
 * 
 * Paramters:
 *          alias: the Alias of the Device.
 */
- (void)setAlias:(NSString *)alias {
    [self.appUser setAlias:alias];
}

/*
 * Get Alias
 * 
 */
- (NSString *)getAlias {
    return self.appUser.alias;
}

/*
 * Set Tags (Max 5 tags)
 * 
 * Paramters:
 *          tags: tag dictionary.
 */
//- (void)setTags:(NSString *)tags {
//    [self.appUser setTags:tags];
//}
- (void)setTagsWithK1:(NSString *)k1 k2:(NSString *)k2 k3:(NSString *)k3 k4:(NSString *)k4 k5:(NSString *)k5 {
    k1 = k1 ? k1 : @"";
    k2 = k2 ? k2 : @"";
    k3 = k3 ? k3 : @"";
    k4 = k4 ? k4 : @"";
    k5 = k5 ? k5 : @"";
    [self.appUser setTags:[NSString stringWithFormat:@"k1=%@,k2=%@,k3=%@,k4=%@,k5=%@",k1,k2,k3,k4,k5]];
}

/*
 * Set GEO
 * 
 * Paramters:
 *          latitude: latitude.
 *          longitude: longitude.
 *          country: country.
 *          state: state.
 *          city: city.
 *          street: street.
 */
//- (void)setTags:(NSString *)tags;
- (void)setGeoLatitude:(double)latitude longitude:(double)longitude country:(NSString *)country countryCode:(NSString *)countryCode state:(NSString *)state city:(NSString *)city district:(NSString *)district street:(NSString *)street zipCode:(NSString *)zipCode {
    NSMutableDictionary *geoDic = [NSMutableDictionary dictionary];
    [geoDic setObject:[NSNumber numberWithDouble:latitude] forKey:AB_APP_GEO_Latitude];
    [geoDic setObject:[NSNumber numberWithDouble:longitude] forKey:AB_APP_GEO_Longitude];
    
    if (country && ![country isEqualToString:@""]) {
        [geoDic setObject:country forKey:AB_APP_GEO_CountryName];
    }
    
    if (countryCode && ![countryCode isEqualToString:@""]) {
        [geoDic setObject:countryCode forKey:AB_APP_GEO_CountryCode];
    }
    
    if (state && ![state isEqualToString:@""]) {
        [geoDic setObject:state forKey:AB_APP_GEO_State];
    }
    
    if (city && ![city isEqualToString:@""]) {
        [geoDic setObject:city forKey:AB_APP_GEO_City];
    }
    
    if (district && ![district isEqualToString:@""]) {
        [geoDic setObject:district forKey:AB_APP_GEO_District];
    }
    
    if (street && ![street isEqualToString:@""]) {
        [geoDic setObject:street forKey:AB_APP_GEO_Street];
    }
    
    if (zipCode && ![zipCode isEqualToString:@""]) {
        [geoDic setObject:zipCode forKey:AB_APP_GEO_ZipCode];
    }
    
    [self.appUser setGeo:[NSDictionary dictionaryWithDictionary:geoDic]];
    [self.appUser syncDataToServerWithTarget:nil];
}

/*
 * Get Tags
 * 
 */
- (NSString *)getTags {
    return self.appUser.tags;
}

#pragma mark - Private

- (void)initializeEnvironment:(NSDictionary *)config {
    [_appBand setNetworkQueue:[ABNetworkQueue networkQueue]];
    self.configuration = [self initializeConfiguration:config];
    self.appUser = [self initializeAppUser:[[[ABAppUserSettings alloc] init] autorelease]];
}

- (ABConfiguration *)initializeConfiguration:(NSDictionary *)config {
    ABConfiguration *configuration = [[[ABConfiguration alloc] init] autorelease];
    [configuration setServer:kAppBandProductionServer];
    [configuration setHandlePushAuto:[config objectForKey:AppBandKickOfOptionsAppBandConfigHandlePushAuto] ? [[config objectForKey:AppBandKickOfOptionsAppBandConfigHandlePushAuto] boolValue] : YES];
    [configuration setHandleRichAuto:[config objectForKey:AppBandKickOfOptionsAppBandConfigHandleRichAuto] ? [[config objectForKey:AppBandKickOfOptionsAppBandConfigHandleRichAuto] boolValue] : YES];
    
    return configuration;
}

- (ABAppUser *)initializeAppUser:(ABAppUserSettings *)setting {
    return [[[ABAppUser alloc] initWithSettings:setting] autorelease];
}

- (void)doProvisioningWhenKickoff {
    [self.configuration provisioning];
}

- (NSString*)parseDeviceToken:(NSString*)tokenStr {
    return [[[tokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""]
             stringByReplacingOccurrencesOfString:@">" withString:@""]
            stringByReplacingOccurrencesOfString:@" " withString:@""];
}

#pragma mark - lifecycle

- (id)initWithKey:(NSString *)appKey secret:(NSString *)secret {
    self = [super init];
    if (self) {
        [self setAppKey:appKey];
        [self setAppSecret:secret];

    }
    
    return self;
}

- (void)dealloc {
    [self setAppKey:nil];
    [self setAppSecret:nil];
    [super dealloc];
}

@end
