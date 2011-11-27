//
//  ABDonwloadManager.h
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABGlobal.h"

@interface ABDonwloadManager : NSObject {
    @private
        NSOperationQueue *_downloaderQueue;
}

SINGLETON_INTERFACE(ABDonwloadManager)

- (void)deliverWithProductId:(NSString *)productId url:(NSString*)url savePath:(NSString*)path notificationKey:(NSString*)notificationKey;

@end
