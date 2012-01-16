//
//  ABNetworkQueue.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/10/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABNetworkQueue : NSOperationQueue

//Convenience constructor
+ (id)networkQueue;

@end
