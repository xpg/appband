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

@synthesize server = _server;
@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize token = _token;
@synthesize udid = _udid;

@synthesize handlePushAuto = _handlePushAuto;
@synthesize handleRichAuto = _handleRichAuto;

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
        
        //Check for a custom AppBand server value
        NSString *airshipServer = [config objectForKey:AppBandKickOfOptionsAppBandConfigServer];
        if (airshipServer == nil) {
            airshipServer = kAppBandProductionServer;
        }
        
        if (configAppKey && configAppSecret) {
            [AppBand shared];
            [[AppBand shared] setAppKey:configAppKey];
            [[AppBand shared] setAppSecret:configAppSecret];
            [[AppBand shared] setServer:airshipServer];
            [[AppBand shared] setHandlePushAuto:[config objectForKey:AppBandKickOfOptionsAppBandConfigHandlePushAuto] ? [[config objectForKey:AppBandKickOfOptionsAppBandConfigHandlePushAuto] boolValue] : YES];
            [[AppBand shared] setHandleRichAuto:[config objectForKey:AppBandKickOfOptionsAppBandConfigHandleRichAuto] ? [[config objectForKey:AppBandKickOfOptionsAppBandConfigHandleRichAuto] boolValue] : YES];
        }
    } 
    
    if (![AppBand shared]) {
        ABLogInfo(@"AppBand initialize fail, check AppBandConfig.plist configuration!");
        exit(-1);
    }
    
    [[AppBand shared] doProvisioningWhenKickoff];
}

/*
 * Get AppBand Singleton Object
 * 
 */
+ (id)shared {
    if (!_appBand) 
        _appBand = [[AppBand alloc] init];
    
    return _appBand;
}

#pragma mark - Private

- (void)doProvisioningWhenKickoff {
    
}

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc {
    [self setAppKey:nil];
    [self setAppSecret:nil];
    [self setServer:nil];
    [self setToken:nil];
    [self setUdid:nil];
    
    [super dealloc];
}

@end
