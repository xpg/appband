//
//  ABProductHandler+Private.h
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>

#import "ABHTTPRequest.h"

#import "ABProductsResponse.h"
#import "ABProduct.h"

#import "ABRestCenter.h"
#import "AB_SBJSON.h"

@interface ABProductHandler() <ABHTTPRequestDelegate,SKProductsRequestDelegate>

@property(nonatomic,retain) NSMutableDictionary *productsDictionary;
@property(nonatomic,retain) ABProductsResponse *response;

@property(nonatomic,readwrite,copy) NSString *group;
@property(nonatomic,readwrite,copy) NSString *url;

@property(nonatomic,assign) SKProductsRequest *productsRequest;

- (void)getProductsEnd:(NSDictionary *)response;

- (void)finishedRequestProduct:(SKRequest *)request;

@end
