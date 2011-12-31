//
//  ABGlobal.h
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#define APPBAND_SDK_VERSION @"version 0.2.0"

#define AB_APP_KEY @"k"
#define AB_APP_SECRET @"s"
#define AB_APP_BUNDLE_VERSION @"version"
#define AB_APP_BUNDLE_IDENTIFIER @"bundleid"
#define AB_DEVICE_UDID @"udid"
#define AB_DEVICE_TOKEN @"token"
#define AB_APP_ALIAS @"device_alias"
#define AB_APP_TAGS @"tags"
#define AB_APP_SETTING @"setting"
#define AB_APP_TIMEZONE @"timezone"
#define AB_APP_LANGUAGE @"language"
#define AB_APP_OS_VERSION @"os_version"
#define AB_APP_DEVICE_TYPE @"device_type"

#define AB_Error @"error"

#define AB_APP_NOTIFICATION_SUM @"sum"
#define AB_APP_NOTIFICATION_NOTIFICATIONS @"notifications"

#define AB_APP_NOTIFICATION_ID @"abni"
#define AB_APP_NOTIFICATION_ALERT @"alert"
#define AB_APP_NOTIFICATION_TYPE @"is_rich"
#define AB_APP_NOTIFICATION_SEND_TIME @"send_time"
#define AB_APP_NOTIFICATION_ISREAD @"is_read"

#define AB_APP_NOTIFICATION_SEND_TIME_FORMAT @"yyyy-MM-dd HH:mm:ss ZZZ"

#define AB_APP_PUSH_CONFIGURATION_ENABLED @"push_enabled"
#define AB_APP_PUSH_CONFIGURATION_UNAVAILABLE_INTERVALS @"dnd_intervals"

#define AB_Rich_Title @"rich_title"
#define AB_Rich_Content @"rich_content"

#define AB_Products @"products"

#define AB_Product_ID @"product_id"
#define AB_Product_Name @"name"
#define AB_Product_Description @"description"
#define AB_Product_IsFree @"is_free"
#define AB_Product_Icon @"icon_url"
#define AB_Product_IsPurchased @"is_purchased"
#define AB_Product_Receipt @"receipt"

#define AB_Transaction_ID @"transaction_id"
#define AB_Transaction_URL @"content_url"

#define Fetch_Rich_ID_Prefix @"Fetch_Rich_ID_Prefix_"
#define Impression_Rich_ID_Prefix @"Impression_Rich_ID_Prefix_"

//Push Notification Payload Key
#define AppBandNotificationAPS @"aps"
#define AppBandNotificationAlert @"alert"
#define AppBandNotificationBadge @"badge"
#define AppBandNotificationSound @"sound"
#define AppBandNotificationId @"abni"
#define AppBandPushNotificationType @"abpt"

//Webservice 
#define kAppBandRequestTimeout 30.

typedef enum {
    ABHTTPResponseSuccess,
    ABHTTPResponseInvalidURL,
    ABHTTPResponseNoConnection,
    ABHTTPResponseTimeout,
    ABHTTPResponseCancel,
    ABHTTPResponseAuthorError = 403,
    ABHTTPResponseResourceNotFound = 404,
    ABHTTPResponseServerError = 500,
} ABHTTPResponseCode;

#define ABHTTPResponseKey @"ABHTTPResponseKey"
#define ABHTTPResponseKeyURL @"ABHTTPResponseKeyURL"
#define ABHTTPResponseKeyCode @"ABHTTPResponseKeyCode"
#define ABHTTPResponseKeyContent @"ABHTTPResponseKeyContent"
#define ABHTTPResponseKeyError @"ABHTTPResponseKeyError"
#define ABHTTPRequesterObject @"ABHTTPRequesterObject"

#ifdef DEBUG
#define DLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]
#else
#define DLog(...) do { } while (0)
#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif
#define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif
