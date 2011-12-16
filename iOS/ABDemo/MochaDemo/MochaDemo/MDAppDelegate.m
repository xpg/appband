//
//  MDAppDelegate.m
//  MochaDemo
//
//  Created by Jason Wang on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MDAppDelegate.h"

#import "MDPushController.h"
#import "MDPurchaseController.h"

#import "AppBandKit.h"

@implementation MDAppDelegate

@synthesize window = _window;

#pragma mark - Private

- (void)registerDeviceTokenFinish:(ABRegisterTokenResponse *)response {
}

- (void)handleRich:(ABNotification *)notification {
}

#pragma mark - Register For Remote Notification

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    [[AppBand shared] handleNotification:userInfo applicationState:appState target:nil pushSelector:nil richSelector:nil];
}

// one of these will be called after calling -registerForRemoteNotifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[AppBand shared] registerDeviceToken:deviceToken target:self finishSelector:@selector(registerDeviceTokenFinish:)];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}

#pragma mark - UIApplication lifecycle

- (void)dealloc {
    [controller release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    controller = [[UITabBarController alloc] init];
    
    MDPushController *pushController = [[MDPushController alloc] init];
    UITabBarItem *pushBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMostRecent tag:0];
    [pushController setTabBarItem:pushBarItem];
    [pushBarItem release];
    
    UINavigationController *pushNavController = [[UINavigationController alloc] initWithRootViewController:pushController];
    [pushController release];
    
    MDPurchaseController *purchaseController = [[MDPurchaseController alloc] init];
    UITabBarItem *purchaseBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:1];
    [purchaseController setTabBarItem:purchaseBarItem];
    [purchaseBarItem release];
    
    UINavigationController *purchaseNavController = [[UINavigationController alloc] initWithRootViewController:purchaseController];
    [purchaseController release];
    
    [controller setViewControllers:[NSArray arrayWithObjects:pushNavController, purchaseNavController, nil]];
    
    [self.window addSubview:controller.view];
    
    NSMutableDictionary *configOptions = [NSMutableDictionary dictionary];
    [configOptions setValue:[NSNumber numberWithBool:NO] forKey:AppBandKickOfOptionsAppBandConfigRunEnvironment];
    [configOptions setValue:$yourAppKey forKey:AppBandKickOfOptionsAppBandConfigSandboxKey];
    [configOptions setValue:$yourAppSecret forKey:AppBandKickOfOptionsAppBandConfigSandboxSecret];
    
    NSMutableDictionary *kickOffOptions = [NSMutableDictionary dictionary];
    [kickOffOptions setValue:launchOptions forKey:AppBandKickOfOptionsLaunchOptionsKey];
    [kickOffOptions setValue:configOptions forKey:AppBandKickOfOptionsAppBandConfigKey];
    
    [AppBand kickoff:kickOffOptions];
    
    [[AppBand shared] resetBadge];
    [[AppBand shared] registerRemoteNotificationWithTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    
    [[AppBand shared] handleNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] applicationState:UIApplicationStateInactive target:nil pushSelector:nil richSelector:nil];
    
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
