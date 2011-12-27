//
//  ABConstant.h
//  AHPush
//
//  Created by Jason Wang on 11/1/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

// **************** AppBand kickoff Configuration Key ****************

#define AppBandKickOfOptionsLaunchOptionsKey @"AppBandKickOfOptionsLaunchOptionsKey"
#define AppBandKickOfOptionsAppBandConfigKey @"AppBandKickOfOptionsAppBandConfigKey"

#define AppBandKickOfOptionsAppBandConfigRunEnvironment @"APP_STORE_OR_AD_HOC"

#define AppBandKickOfOptionsAppBandConfigProductionKey @"PRODUCTION_APP_KEY"
#define AppBandKickOfOptionsAppBandConfigProductionSecret @"PRODUCTION_APP_SECRET"
#define AppBandKickOfOptionsAppBandConfigSandboxKey @"SANDBOX_APP_KEY"
#define AppBandKickOfOptionsAppBandConfigSandboxSecret @"SANDBOX_APP_SECRET"

#define AppBandKickOfOptionsAppBandConfigServer @"APPBAND_SERVER"

#define AppBandKickOfOptionsAppBandConfigHandlePushAuto @"APPBAND_HANDLE_PUSH_AUTO"
#define AppBandKickOfOptionsAppBandConfigHandleRichAuto @"APPBAND_HANDLE_RICH_AUTO"




// **************** Tag Prefer Key ****************

#define AppBandTagPreferKeyLocation @"location"
#define AppBandTagPreferKeyCounty @"county"



// **************** Push DND Interval Key ****************

#define AppBandPushIntervalBeginTimeKey @"begin_time"
#define AppBandPushIntervalEndTimeKey @"end_time"



// **************** Utilty Mehod ****************

/*
 * Get UTC Time String From NSDate
 * 
 * Paramters:
 *         date: target Date.
 * 
 */
static inline NSString * getUTCFromeDate(NSDate *date) {
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone1 = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone1];
    [dateFormatter setDateFormat:@"HH:mm ZZZ"];
    NSString *utcTime = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    
    return utcTime;
}

/*
 * Get UTC Time String From NSString
 * 
 * Paramters:
 *         timeStr: target string. Note that: the timeStr should be in "HH:mm" format.
 * 
 */
static inline NSString * getUTCFromeString(NSString *timeStr) {
    if ([timeStr length] != 5) return nil;
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^([0-2][0-3]:[0-5][0-9])|(0?[0-9]:[0-5][0-9])$" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSUInteger numberofMatch = [expression numberOfMatchesInString:timeStr 
                                                           options:NSMatchingReportProgress
                                                             range:NSMakeRange(0, timeStr.length)];
    if (numberofMatch < 1) return nil;
    
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *date = [dateFormatter dateFromString:timeStr];
    [dateFormatter release];
    
    return getUTCFromeDate(date);
}


// **************** Singleton Template ****************

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

