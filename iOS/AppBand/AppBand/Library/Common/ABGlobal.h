//
//  ABGlobal.h
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#define AB_APP_KEY @"k"
#define AB_APP_SECRET @"s"
#define AB_APP_BUNDLE_VERSION @"version"
#define AB_APP_BUNDLE_IDENTIFIER @"bundleid"
#define AB_DEVICE_UDID @"udid"
#define AB_DEVICE_TOKEN @"token"

#define Fetch_Rich_ID_Prefix @"Fetch_Rich_ID_Prefix_"
#define Impression_Rich_ID_Prefix @"Impression_Rich_ID_Prefix_"

//Push Notification Payload Key
#define AppBandNotificationAPS @"aps"
#define AppBandNotificationAlert @"alert"
#define AppBandNotificationBadge @"badge"
#define AppBandNotificationSound @"sound"
#define AppBandPushNotificationType @"abpt"
#define AppBandRichNotificationId @"abri"

//Webservice 
#define kAppBandRequestTimeout 30.

typedef enum {
    ABHTTPResponseSuccess,
    ABHTTPResponseInvalidURL,
    ABHTTPResponseNoConnection,
    ABHTTPResponseTimeout,
    ABHTTPResponseCancel,
    ABHTTPResponseError,
} ABHTTPResponseCode;

#define ABHTTPResponseKeyURL @"ABHTTPResponseKeyURL"
#define ABHTTPResponseKeyCode @"ABHTTPResponseKeyCode"
#define ABHTTPResponseKeyContent @"ABHTTPResponseKeyContent"
#define ABHTTPResponseKeyError @"ABHTTPResponseKeyError"


//Singleton Template
#define SINGLETON_INTERFACE(CLASSNAME)  \
+ (CLASSNAME*)shared;\
- (void)forceRelease;


#define SINGLETON_IMPLEMENTATION(CLASSNAME)         \
\
static CLASSNAME* g_shared##CLASSNAME = nil;        \
\
+ (CLASSNAME*)shared                                \
{                                                   \
if (g_shared##CLASSNAME != nil) {                   \
return g_shared##CLASSNAME;                         \
}                                                   \
\
@synchronized(self) {                               \
if (g_shared##CLASSNAME == nil) {                   \
g_shared##CLASSNAME = [[self alloc] init];      \
}                                                   \
}                                                   \
\
return g_shared##CLASSNAME;                         \
}                                                   \
\
+ (id)allocWithZone:(NSZone*)zone                   \
{                                                   \
@synchronized(self) {                               \
if (g_shared##CLASSNAME == nil) {                   \
g_shared##CLASSNAME = [super allocWithZone:zone];    \
return g_shared##CLASSNAME;                         \
}                                                   \
}                                                   \
NSAssert(NO, @ "[" #CLASSNAME                       \
" alloc] explicitly called on singleton class.");   \
return nil;                                         \
}                                                   \
\
- (id)copyWithZone:(NSZone*)zone                    \
{                                                   \
return self;                                        \
}                                                   \
\
- (id)retain                                        \
{                                                   \
return self;                                        \
}                                                   \
\
- (oneway void)release                                     \
{                                                   \
}                                                   \
\
- (void)forceRelease {                              \
@synchronized(self) {                               \
if (g_shared##CLASSNAME != nil) {                   \
g_shared##CLASSNAME = nil;                          \
}                                                   \
}                                                   \
[super release];                                    \
}                                                   \
\
- (id)autorelease                                   \
{                                                   \
return self;                                        \
}
