//
//  AppHub.m
//  AppHubDemo
//
//  Created by Jason Wang on 10/28/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

//#define kAppBandProductionServer @"https://apphub.gizwits.com"
#define kAppBandProductionServer @"https://192.168.1.60"

#define kLastDeviceTokenKey @"ABDeviceTokenChanged"

#import "AppBand.h"
#import "AppBand+Private.h"

static AppBand *_appBand;

@implementation AppBand

@synthesize server = _server;
@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize deviceToken = _deviceToken;

@synthesize registerTarget = _registerTarget;
@synthesize registerFinishSelector = _registerFinishSelector;

@synthesize handlePushAuto = _handlePushAuto;
@synthesize handleRichAuto = _handleRichAuto;

#pragma mark - Private

- (void)updateDeviceToken:(NSData*)tokenData {
    self.deviceToken = [self parseDeviceToken:[tokenData description]];
}

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

- (void)registerDeviceTokenWithExtraInfo:(NSDictionary *)info {
    if (!self.deviceToken) return;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",
                           self.server, @"/app_registrations"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:info];
    [parameters setObject:self.deviceToken forKey:AB_DEVICE_TOKEN];
    
    ABHTTPRequest *request = [ABHTTPRequest requestWithURL:urlString 
                                                 parameter:parameters
                                                   timeout:kAppBandRequestTimeout
                                                  delegate:self
                                                    finish:@selector(registerDeviceTokenEnd:)
                                                      fail:@selector(registerDeviceTokenEnd:)];
    [[ABRestCenter shared] addRequest:request];
}

- (void)registerDeviceToken:(NSData *)token
              withExtraInfo:(NSDictionary *)info {
    [[AppBand shared] updateDeviceToken:token];
    [[AppBand shared] registerDeviceTokenWithExtraInfo:info];
}

- (void)registerDeviceTokenEnd:(NSDictionary *)response {
    if ([self.registerTarget respondsToSelector:self.registerFinishSelector]) {
        ABRegisterTokenResponse *r = [[[ABRegisterTokenResponse alloc] init] autorelease];
        [r setCode:[[response objectForKey:ABHTTPResponseKeyCode] intValue]];
        [r setError:[response objectForKey:ABHTTPResponseKeyError]];
        
        [self.registerTarget performSelector:self.registerFinishSelector withObject:r];
    }
}

#pragma mark - AppBand Mehods

+ (void)kickoff:(NSDictionary *)options {
    if (_appBand) {
        return;
    }
    
    //Application launch options
    //    NSDictionary *launchOptions = [options objectForKey:AppBandKickOfOptionsLaunchOptionsKey];
    
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
            _appBand.handlePushAuto = [config objectForKey:AppBandKickOfOptionsAppBandConfigHandlePushAuto] ? [[config objectForKey:AppBandKickOfOptionsAppBandConfigHandlePushAuto] boolValue] : YES;
            _appBand.handlePushAuto = [config objectForKey:AppBandKickOfOptionsAppBandConfigHandleRichAuto] ? [[config objectForKey:AppBandKickOfOptionsAppBandConfigHandleRichAuto] boolValue] : YES;
        }
    } 
    
    if (!_appBand) {
        DLog(@"AppBand initialize fail, check AppBandConfig.plist configuration!");
    }
}

+ (id)shared {
    return _appBand;
}

+ (void)end {
    [_appBand release];
    _appBand = nil;
}

- (void)registerDeviceToken:(NSData *)token
                     target:(id)target
             finishSelector:(SEL)finishSeletor {
    self.registerTarget = target;
    self.registerFinishSelector = finishSeletor;
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setValue:self.appKey forKey:AB_APP_KEY];
    [info setValue:self.appSecret forKey:AB_APP_SECRET];
    
    NSString *bundleVersion = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    UIDeviceUDID *deviceUDID = [[UIDeviceUDID alloc] init];
    NSString *udid = [deviceUDID uniqueDeviceIdentifier];
    
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
    
    [deviceUDID release];
}

#pragma mark - Push Mehods

- (void)handleNotification:(NSDictionary *)notification
          applicationState:(UIApplicationState)state 
                    target:(id)target 
              pushSelector:(SEL)pushSelector
              richSelector:(SEL)richSelector {
    [[ABPush shared] handleNotification:notification applicationState:state target:target pushSelector:pushSelector richSelector:richSelector];
}

- (void)getRichContent:(NSString *)rid target:(id)target finishSelector:(SEL)finishSelector {
    [[ABPush shared] getRichContent:rid target:target finishSelector:finishSelector];
}

- (void)registerRemoteNotificationWithTypes:(UIRemoteNotificationType)types {
    [[ABPush shared] registerRemoteNotificationWithTypes:types];
}

- (void)setBadgeNumber:(NSInteger)badgeNumber {
    [[ABPush shared] setBadgeNumber:badgeNumber];
}

- (void)resetBadge {
    [[ABPush shared] resetBadge];
}

#pragma mark - singleton

- (id)initWithKey:(NSString *)key secret:(NSString *)secret {
    self = [super init];
    if (self) {
        self.appKey = key;
        self.appSecret = secret;
    }
    
    return self;
}

- (void)dealloc {
    [self setServer:nil];
    [self setAppKey:nil];
    [self setAppSecret:nil];
	[super dealloc];
}

@end
