//
//  ABConstant.h
//  AHPush
//
//  Created by Jason Wang on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


/*
 *  AppBand -kickoff Configuration Key
 */
#define AppBandKickOfOptionsLaunchOptionsKey @"AppBandKickOfOptionsLaunchOptionsKey"
#define AppBandKickOfOptionsAppBandConfigKey @"AppBandKickOfOptionsAppBandConfigKey"

#define AppBandKickOfOptionsAppBandConfigRunEnvironment @"APP_STORE_OR_AD_HOC"

#define AppBandKickOfOptionsAppBandConfigProductionKey @"PRODUCTION_APP_KEY"
#define AppBandKickOfOptionsAppBandConfigProductionSecret @"PRODUCTION_APP_SECRET"
#define AppBandKickOfOptionsAppBandConfigSandboxKey @"SANDBOX_APP_KEY"
#define AppBandKickOfOptionsAppBandConfigSandboxSecret @"SANDBOX_APP_SECRET"

#define AppBandKickOfOptionsAppBandConfigServer @"APPBAND_SERVER"

/*
 *  AppBand -registerDeviceToken callback Dictionary Key
 */
typedef enum {
    ABHTTPResponseSuccess,
    ABHTTPResponseInvalidURL,
    ABHTTPResponseNoConnection,
    ABHTTPResponseTimeout,
    ABHTTPResponseError,
} ABHTTPResponseCode;

#define ABHTTPResponseKeyURL @"ABHTTPResponseKeyURL"
#define ABHTTPResponseKeyCode @"ABHTTPResponseKeyCode"
#define ABHTTPResponseKeyContent @"ABHTTPResponseKeyContent"
#define ABHTTPResponseKeyError @"ABHTTPResponseKeyError"