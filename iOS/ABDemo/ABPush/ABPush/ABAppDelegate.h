//
//  ABAppDelegate.h
//  ABPush
//
//  Created by Jason Wang on 11/1/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABPushController;

@interface ABAppDelegate : UIResponder <UIApplicationDelegate> {
    ABPushController *pushController;
}

@property (strong, nonatomic) UIWindow *window;

@end
