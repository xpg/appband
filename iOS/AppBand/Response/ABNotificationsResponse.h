//
//  ABNotificationsResponse.h
//  AppBand
//
//  Created by Jason Wang on 12/9/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ABResponse.h"

@interface ABNotificationsResponse : ABResponse {
    NSUInteger sum;
    NSArray *notificationArray;
}

@property(nonatomic,assign) NSUInteger sum;
@property(nonatomic,copy) NSArray *notificationArray;

@end
