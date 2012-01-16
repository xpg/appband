//
//  ABRichHandler+Private.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/16/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABRichHandler.h"

#import "AppBand+Private.h"
#import "ABPush+Private.h"

#import "ABRichResponse.h"
#import "ABHttpRequest.h"
#import "ABUtilty.h"
#import "ABPrivateConstants.h"

#import "AB_SBJSON.h"

@interface ABRichHandler() <ABHttpRequestDelegate>

@property(nonatomic,assign) id<ABRichHandlerDelegate> handlerDelegate;

@property(nonatomic,readwrite,copy) NSString *fetchKey;
@property(nonatomic,readwrite,copy) NSString *impressionKey;

- (ABHttpRequest *)initializeHttpRequest;

- (void)addRequestToQueue:(ABHttpRequest *)request;

- (void)sendImpression;

- (void)impressionEnd:(NSDictionary *)response;

@end
