//
//  ABPurchase+Private.h
//  AppBand
//
//  Created by Jason Wang on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppBand.h"

#import "ABProductHandler.h"
#import "ABPurchaseResponse.h"

#import <StoreKit/StoreKit.h>

@interface ABPurchase() <SKPaymentTransactionObserver>

@property(nonatomic,assign) id paymentStatusTarget;
@property(nonatomic,assign) SEL paymentStatusSelector;

@property(nonatomic,retain) NSMutableDictionary *deliverHnadlerDictionary;
@property(nonatomic,retain) NSMutableDictionary *productsHandlerDictionay;

- (void)getProductsEnd:(NSDictionary *)response;

- (void)destroyProductsHandler:(ABProductHandler *)handler;

/*
 * Deliver Product
 * 
 * Paramters:
 *       product: product.
 *       
 */
- (void)deliverProduct:(ABProduct *)product;

- (void)completeTransaction:(SKPaymentTransaction *)transaction;

- (void)failedTransaction:(SKPaymentTransaction *)transaction;

- (void)restoreTransaction:(SKPaymentTransaction *)transaction;

- (void)provideContent:(SKPaymentTransaction *)transaction;

@end
