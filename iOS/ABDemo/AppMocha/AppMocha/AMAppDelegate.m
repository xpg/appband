//
//  AMAppDelegate.m
//  AppMocha
//
//  Created by Jason Wang on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define AppMocha_Demo_App @"amd"

//#define kKeyChainLoginForAppMochaDemo @"_AppMochaDemo"
#define kKeyChainEmailForAppMochaDemo @"kKeyChainEmailForAppMochaDemo"
#define kKeyChainPasswordForAppMochaDemo @"kKeyChainPasswordForAppMochaDemo"

#define AppMocha_Demo_Device_Token @"AppMocha_Demo_Device_Token"

#import "AMAppDelegate.h"

#import "AMIPadMainController.h"
#import "AMIPhoneMainController.h"
#import "AMIPadPushController.h"
#import "AMIPadPurchaseController.h"
#import "AMIPadIntroController.h"

#import "AppBandKit.h"
#import "xRestKit.h"

#import "SFHFKeychainUtils.h"

#import "CoreDataManager.h"
#import "AMModelConstant.h"

@interface AMAppDelegate()

@property(nonatomic,copy) NSString *userEmail;
@property(nonatomic,copy) NSString *userPassword;
@property(nonatomic,copy) NSString *token;

- (void)setDeviceToken:(NSData *)tokenData;

- (NSString *)urlScheme;

- (void)didReceiveNotification:(ABNotification *)notification;

- (void)autoLogin;

- (UIViewController *)getFunctionController;

- (UIViewController *)getUnLoginController;

- (NSDictionary *)getDictionaryFromABNotification:(ABNotification *)notification;

@end

@implementation AMAppDelegate

@synthesize userEmail = _userEmail;
@synthesize userPassword = _userPassword;
@synthesize token = _token;

@synthesize window = _window;
@synthesize rootController = _rootController;

#pragma mark - Public

- (NSString *)deviceToken {
    return self.token;
}

- (void)setEmail:(NSString *)email password:(NSString *)password {
    self.userEmail = email;
    self.userPassword = password;
    
    if ([self availableString:self.userEmail] && [self availableString:self.userPassword]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.userEmail forKey:kKeyChainEmailForAppMochaDemo];
        [[NSUserDefaults standardUserDefaults] setObject:self.userPassword forKey:kKeyChainPasswordForAppMochaDemo];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (BOOL)availableString:(NSString *)target {
    if (!target || [target isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

#pragma mark - Private

- (void)setDeviceToken:(NSData *)tokenData {
    NSString *tokenStr = [[[[tokenData description] stringByReplacingOccurrencesOfString:@"<" withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""]
                          stringByReplacingOccurrencesOfString:@" " withString:@""];;
    
    if (!tokenStr || [self.token isEqualToString:tokenStr]) return;
    
    self.token = tokenStr;
    [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:AppMocha_Demo_Device_Token];
}

- (NSString *)urlScheme {
    return [NSString stringWithFormat:@"%@%@",AppMocha_Demo_App,[[AppBand shared] appKey]];
}

- (void)didReceiveNotification:(ABNotification *)notification {
    if ([self availableString:notification.notificationId]) {
        CoreDataController *dataController = [[CoreDataManager defaultManager] fetchCDController:DEMO_STORE_NAME];
        
        AMNotification *noti = [dataController saveModelObject:AMNotification_Class content:[self getDictionaryFromABNotification:notification] identification:[NSPredicate predicateWithFormat:@"abri = %@",notification.notificationId]];
        
        if (noti) {
            [[NSNotificationCenter defaultCenter] postNotificationName:AppMocha_Demo_Notificaion_Receive_Key object:noti];
        }
    }
}

- (void)autoLogin {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *appKey = [[AppBand shared] appKey];
    NSString *appSecret = [[AppBand shared] appSecret];
    NSString *token = [(AMAppDelegate *)[UIApplication sharedApplication].delegate deviceToken];
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    NSDictionary *parameters = nil;
    if (!token || [token isEqualToString:@""]) {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:appKey, AppBand_App_Key, appSecret, AppBand_App_Secret, bundleId, AppBand_App_BundleId, self.userEmail, AppBand_App_Email, self.userPassword, AppBand_App_Password, nil];
    } else {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:appKey, AppBand_App_Key, appSecret, AppBand_App_Secret, bundleId, AppBand_App_BundleId, self.token, AppBand_App_token, self.userEmail, AppBand_App_Email, self.userPassword, AppBand_App_Password, nil];
    }
    
    NSString *url = [[[AppBand shared] server] stringByAppendingPathComponent:@"mobile_users/verify"];
    
    [[xRestManager defaultManager] sendRequestTo:url parameter:parameters timeout:30. completion:^(xRestCompletionType type, NSString *response) {
        
    }];
    
    [pool drain];
}

- (UIViewController *)getFunctionController {
    UIViewController *pushController = nil;
    UIViewController *purchaseController = nil;
    UIViewController *introController = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
    } else {
        pushController = [[[AMIPadPushController alloc] initWithNibName:@"AMIPadPushController" bundle:nil] autorelease];
        UITabBarItem *pushBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMostRecent tag:0];
        [pushController setTabBarItem:pushBarItem];
        [pushBarItem release];
        
        purchaseController = [[[AMIPadPurchaseController alloc] initWithNibName:@"AMIPadPurchaseController" bundle:nil] autorelease];
        UITabBarItem *purchaseBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:1];
        [purchaseController setTabBarItem:purchaseBarItem];
        [purchaseBarItem release];
        
        introController = [[[AMIPadIntroController alloc] initWithNibName:@"AMIPadIntroController" bundle:nil] autorelease];
        UITabBarItem *introBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:2];
        [introController setTabBarItem:introBarItem];
        [introBarItem release];
    }
    
    UINavigationController *naviPushController = [[[UINavigationController alloc] initWithRootViewController:pushController] autorelease];
    [naviPushController.navigationBar.topItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppMocha_Logo"]]];
    
    UINavigationController *naviPurchaseController = [[[UINavigationController alloc] initWithRootViewController:purchaseController] autorelease];
    [naviPurchaseController.navigationBar.topItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppMocha_Logo"]]];
    
    UINavigationController *naviIntroController = [[[UINavigationController alloc] initWithRootViewController:introController] autorelease];
    [naviIntroController.navigationBar.topItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppMocha_Logo"]]];
    
    UITabBarController *barController = [[[UITabBarController alloc] init] autorelease];
    [barController setViewControllers:[NSArray arrayWithObjects:naviPushController, naviPurchaseController, naviIntroController, nil]];
    
    return barController;
}

- (UIViewController *)getUnLoginController {
    UIViewController *viewController = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewController = [[[AMIPhoneMainController alloc] initWithNibName:@"AMIPhoneMainController" bundle:nil] autorelease];
    } else {
        viewController = [[[AMIPadMainController alloc] initWithNibName:@"AMIPadMainController" bundle:nil] autorelease];
    }
    
    UINavigationController *naviController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    [naviController.navigationBar.topItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppMocha_Logo"]]];
    
    return naviController;
}

- (NSDictionary *)getDictionaryFromABNotification:(ABNotification *)notification {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:notification.notificationId forKey:AMNotification_Set_ID];
    [dic setObject:[NSNumber numberWithInt:notification.type] forKey:AMNotification_Set_Type];
    [dic setObject:[NSDate date] forKey:AMNotification_Set_Date];
    
    if (notification.alert) {
        [dic setObject:notification.alert forKey:AMNotification_Set_Message];
    }
    
    return [NSDictionary dictionaryWithDictionary:dic];
}

#pragma mark - Register For Remote Notification

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    [[AppBand shared] handleNotification:userInfo applicationState:appState target:self pushSelector:@selector(didReceiveNotification:) richSelector:@selector(didReceiveNotification:)];
}

// one of these will be called after calling -registerForRemoteNotifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self setDeviceToken:deviceToken];
    [[AppBand shared] registerDeviceToken:deviceToken target:nil finishSelector:nil];
}

#pragma mark - UIApplication lifecycle

- (void)dealloc {
    [_window release];
    [_rootController release];
    [self setToken:nil];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor colorWithRed:223. / 255 green:230. / 255 blue:235. / 255 alpha:1.];
    
    self.token = [[NSUserDefaults standardUserDefaults] objectForKey:AppMocha_Demo_Device_Token];
    self.userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyChainEmailForAppMochaDemo];
    self.userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyChainPasswordForAppMochaDemo];
    
    // init AppBand 
    NSMutableDictionary *configOptions = [NSMutableDictionary dictionary];
    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigRunEnvironment];
    
    [configOptions setValue:@"14" forKey:AppBandKickOfOptionsAppBandConfigSandboxKey];
    [configOptions setValue:@"e1c70f12-1bf5-11e1-81fe-0019d181644b" forKey:AppBandKickOfOptionsAppBandConfigSandboxSecret];
    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigHandlePushAuto];
    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigHandleRichAuto];
    
    NSMutableDictionary *kickOffOptions = [NSMutableDictionary dictionary];
    [kickOffOptions setValue:launchOptions forKey:AppBandKickOfOptionsLaunchOptionsKey];
    [kickOffOptions setValue:configOptions forKey:AppBandKickOfOptionsAppBandConfigKey];
    
    [AppBand kickoff:kickOffOptions];
    
    [[AppBand shared] resetBadge];
    [[AppBand shared] registerRemoteNotificationWithTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    
    [[AppBand shared] handleNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] applicationState:UIApplicationStateInactive target:nil pushSelector:nil richSelector:nil];
    
    if ([self availableString:self.userEmail] && [self availableString:self.userPassword]) {
         self.rootController = [self getFunctionController];
        [self performSelectorInBackground:@selector(autoLogin) withObject:nil];
    } else {
        self.rootController = [self getUnLoginController];
    }
    
    self.window.rootViewController = self.rootController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [AppBand end];
}

@end
