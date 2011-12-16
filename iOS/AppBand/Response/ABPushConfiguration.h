//
//  ABPushConfiguration.h
//  AppBand
//
//  Created by Jason Wang on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABResponse.h"

@interface ABPushConfiguration : ABResponse {
    BOOL enabled;
    NSArray *unavailableIntervals;
}

@property(nonatomic,assign) BOOL enabled;
@property(nonatomic,copy) NSArray *unavailableIntervals;

@end
