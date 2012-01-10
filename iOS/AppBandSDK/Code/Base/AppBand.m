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

#pragma mark - Private

- (void)initializeEnvironment:(NSDictionary *)config {
    [_appBand setNetworkQueue:[ABNetworkQueue networkQueue]];
    [self initializeConfiguration:config];
    [self initializeAppUser];
}

- (void)initializeConfiguration:(NSDictionary *)config {
    self.configuration = [[[ABConfiguration alloc] init] autorelease];
    [self.configuration setHandlePushAuto:[config objectForKey:AppBandKickOfOptionsAppBandConfigHandlePushAuto] ? [[config objectForKey:AppBandKickOfOptionsAppBandConfigHandlePushAuto] boolValue] : YES];
    [self.configuration setHandleRichAuto:[config objectForKey:AppBandKickOfOptionsAppBandConfigHandleRichAuto] ? [[config objectForKey:AppBandKickOfOptionsAppBandConfigHandleRichAuto] boolValue] : YES];
}

- (void)initializeAppUser {
    self.appUser = [[[ABAppUser alloc] initWithSettings:[[[ABAppUserSettings alloc] init] autorelease]] autorelease];
}

- (void)doProvisioningWhenKickoff {
    [self.configuration provisioning];
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
