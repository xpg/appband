//
//  ABProvisioning+Private.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/5/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABHttpRequest.h"

#import "ABUtilty.h"
#import "ABConstants.h"
#import "ABPrivateConstants.h"

#import "AppBand.h"

#import "ABLog.h"

@interface ABProvisioning () <ABHttpRequestDelegate>

@property(nonatomic,readwrite,copy) NSString *serverEndpoint;

- (ABHttpRequest *)initializeRequest;

@end
