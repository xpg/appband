//
//  ABInboxResponse.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/31/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABResponse.h"

@interface ABInboxResponse : ABResponse {
    NSUInteger sum;
    NSArray *notificationsArray;
}

@property(nonatomic,assign) NSUInteger sum;
@property(nonatomic,copy) NSArray *notificationsArray;

@end
