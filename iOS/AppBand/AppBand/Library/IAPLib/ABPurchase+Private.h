//
//  ABPurchase+Private.h
//  AppBand
//
//  Created by Jason Wang on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppBand.h"
#import "ABProductHandler.h"

@interface ABPurchase()

@property(nonatomic,retain) NSMutableDictionary *productsHandleDictionay;

- (void)getProductsEnd:(NSDictionary *)response;

- (void)destroyProductsHandler:(ABProductHandler *)handler;

@end
