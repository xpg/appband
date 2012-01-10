//
//  ABConfiguration+Private.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/5/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABConfiguration.h"

#import "ABHttpRequest.h"

#import "ABUtilty.h"
#import "ABConstants.h"
#import "ABPrivateConstants.h"

#import "AppBand+Private.h"

#import "ABLog.h"

@interface ABConfiguration () <ABHttpRequestDelegate>

- (ABHttpRequest *)initializeRequest;

- (void)addToBaseNetworkQueue:(ABHttpRequest *)request;

@end
