//
//  ABRest.h
//  AppBand
//
//  Created by Jason Wang on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABGlobal.h"

@class ABHTTPRequest;

@interface ABRest : NSObject {
    @private
        NSOperationQueue *_queue;
}

@property(nonatomic,readonly) NSOperationQueue *queue;

- (void)addRequest:(ABHTTPRequest *)request;

@end
