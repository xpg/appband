//
//  ABRest.h
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABConstant.h"

@class ABHTTPRequest;

@interface ABRestCenter : NSObject {
    @private
        NSOperationQueue *_queue;
}

@property(nonatomic,readonly) NSOperationQueue *queue;

SINGLETON_INTERFACE(ABRestCenter)

- (void)addRequest:(ABHTTPRequest *)request;

@end
