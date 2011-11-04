//
//  AppHub.m
//  AppHubDemo
//
//  Created by Jason Wang on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define kAppBandProductionServer @"http://stagingapi.apphub.com"

#define kLastDeviceTokenKey @"ABDeviceTokenChanged"

#define AB_APP_KEY @"appKey"
#define AB_APP_SECRET @"appSecret"
#define AB_APP_BUNDLE_VERSION @"bundleVersion"
#define AB_APP_BUNDLE_IDENTIFIER @"bundleIdentifier"
#define AB_DEVICE_UDID @"deviceUDID"
#define AB_DEVICE_TOKEN @"deviceToken"

#import "AppBand.h"
#import "ABPush.h"

#import "ABRest.h"

#import "ABConstant.h"

static AppBand *_appBand;

@interface AppBand()

@property(nonatomic,copy) NSString *server;
@property(nonatomic,copy) NSString *appKey;
@property(nonatomic,copy) NSString *appSecret;
@property(nonatomic,copy) NSString *deviceToken;

- (id)initWithKey:(NSString *)key secret:(NSString *)secret;

- (NSString*)parseDeviceToken:(NSString*)tokenStr;

- (void)registerDeviceTokenSucceeded:(NSDictionary *)info;

- (void)registerDeviceTokenFailed:(NSDictionary *)info;

@end

@implementation AppBand

@synthesize server = _server;
@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize deviceToken = _deviceToken;

@synthesize abRest = _abRest;

#pragma mark - Private

- (NSString*)parseDeviceToken:(NSString*)tokenStr {
    return [[[tokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""]
             stringByReplacingOccurrencesOfString:@">" withString:@""]
            stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (void)setDeviceToken:(NSString*)tokenStr {
    [_deviceToken release]; 
    _deviceToken = [tokenStr copy];
    
    // Check to see if the device token has changed
    NSString* oldValue = [[NSUserDefaults standardUserDefaults] objectForKey:kLastDeviceTokenKey];
    if(![oldValue isEqualToString:_deviceToken]) {
        [[NSUserDefaults standardUserDefaults] setObject:_deviceToken forKey:kLastDeviceTokenKey];
    }
}

- (void)registerDeviceTokenSucceeded:(NSDictionary *)info {

}

- (void)registerDeviceTokenFailed:(NSDictionary *)info {

}

#pragma mark - Public

- (void)updateDeviceToken:(NSData*)tokenData {
    self.deviceToken = [self parseDeviceToken:[tokenData description]];
}

- (void)registerDeviceToken:(NSData *)token {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setValue:self.appKey forKey:AB_APP_KEY];
    [info setValue:self.appSecret forKey:AB_APP_SECRET];
    
    NSString *bundleVersion = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    NSString *udid = [UIDevice currentDevice].uniqueIdentifier;
    
    if (bundleVersion) {
        [info setObject:bundleVersion forKey:AB_APP_BUNDLE_VERSION];
    }
    
    if (bundleId) {
        [info setObject:bundleId forKey:AB_APP_BUNDLE_IDENTIFIER];
    }
    
    if (udid) {
        [info setObject:udid forKey:AB_DEVICE_UDID];
    }
    
    if (token) {
        [[AppBand shared] registerDeviceToken:token withExtraInfo:info];
    } else {
        [[AppBand shared] registerDeviceTokenWithExtraInfo:info];
    }
}

- (void)registerDeviceTokenWithExtraInfo:(NSDictionary *)info {
    if (!self.deviceToken) return;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",
                           self.server, @"/app_registration"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:info];
    [parameters setObject:self.deviceToken forKey:AB_DEVICE_TOKEN];
    
    ABHTTPRequest *request = [ABHTTPRequest requestWithURL:urlString 
                                                 parameter:parameters
                                                   timeout:kAppBandRequestTimeout
                                                  delegate:self
                                                    finish:@selector(registerDeviceTokenSucceeded:)
                                                      fail:@selector(registerDeviceTokenFailed:)];
    [_abRest addRequest:request];
}

- (void)registerDeviceToken:(NSData *)token withExtraInfo:(NSDictionary *)info {
    [[AppBand shared] updateDeviceToken:token];
    [[AppBand shared] registerDeviceTokenWithExtraInfo:info];
}

#pragma mark - lifecycle

+ (void)kickoff:(NSDictionary *)options {
    if (_appBand) {
        return;
    }
    
    //Application launch options
    NSDictionary *launchOptions = [options objectForKey:AppBandKickOfOptionsLaunchOptionsKey];
    
    // Load configuration
    // Primary configuration comes from the UAirshipTakeOffOptionsAirshipConfig dictionary and will
    // override any options defined in AirshipConfig.plist
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
        
        //Check for a custom UA server value
        NSString *airshipServer = [config objectForKey:AppBandKickOfOptionsAppBandConfigServer];
        if (airshipServer == nil) {
            airshipServer = kAppBandProductionServer;
        }
        
        if (configAppKey && configAppSecret) {
            _appBand = [[AppBand alloc] initWithKey:configAppKey secret:configAppSecret];
            _appBand.server = airshipServer;
        }
    } 
    
    if (!_appBand) {
        DLog(@"AppBand initialize fail, check AppBandConfig.plist configuration!");
    }
    
    [[ABPush shared] registerRemoteNotificationWithTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    [[ABPush shared] handleNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] applicationState:UIApplicationStateInactive];
}

+ (id)shared {
    return _appBand;
}

+ (void)end {
    [_appBand release];
    _appBand = nil;
}

#pragma mark - singleton

- (id)initWithKey:(NSString *)key secret:(NSString *)secret {
    self = [super init];
    if (self) {
        self.appSecret = key;
        self.appSecret = secret;
        
        _abRest = [[ABRest alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_abRest release];
    [self setServer:nil];
    [self setAppKey:nil];
    [self setAppSecret:nil];
	[super dealloc];
}

@end
