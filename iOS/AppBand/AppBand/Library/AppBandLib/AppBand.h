//
//  AppBand.h
//  AppHubDemo
//
//  Created by Jason Wang on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ABGlobal.h"
#import "ABHTTPRequest.h"

@class ABRest;

@interface AppBand : NSObject <ABHTTPRequestDelegate> {
    @private
        ABRest *_abRest;
}

@property(nonatomic,readonly) ABRest *abRest;

#pragma mark - lifecycle

+ (void)kickoff:(NSDictionary *)options;

+ (id)shared;

+ (void)end;

#pragma mark - Public 

- (void)updateDeviceToken:(NSData*)tokenData;

- (void)registerDeviceToken:(NSData *)token;

- (void)registerDeviceTokenWithExtraInfo:(NSDictionary *)info;

- (void)registerDeviceToken:(NSData *)token withExtraInfo:(NSDictionary *)info;

@end
