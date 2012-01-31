//
//  ABPurchase+Private.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/20/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABPurchase.h"

#import "ABHttpRequest.h"

#import "AppBand+Private.h"

@interface ABPurchase()

@property(nonatomic,copy) NSString *productsKey;
@property(nonatomic,assign) id productsTarget;
@property(nonatomic,assign) SEL productsSEL;

@property(nonatomic,retain) ABNetworkQueue *purchaseQueue;

- (ABHttpRequest *)initProductsHttpRequest:(NSString *)group;

- (void)addRequestToQueue:(ABHttpRequest *)request;

- (void)getProductsEnd:(NSDictionary *)response;

@end
