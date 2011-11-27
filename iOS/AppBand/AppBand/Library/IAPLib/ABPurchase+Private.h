//
//  ABPurchase+Private.h
//  AppBand
//
//  Created by Jason Wang on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppBand.h"

#import "ABProductHandler.h"
#import "ABDeliverHandler.h"

#import "ABPurchaseResponse.h"

#import <StoreKit/StoreKit.h>

@interface ABPurchase() <SKPaymentTransactionObserver>

@property(nonatomic,copy) NSString *path;
@property(nonatomic,copy) NSString *notificationKey;

@property(nonatomic,retain) NSMutableDictionary *deliverHnadlerDictionary;
@property(nonatomic,retain) NSMutableDictionary *productsHandlerDictionay;

@property(nonatomic,retain) ABProduct *product;

- (void)destroyProductsHandler:(ABProductHandler *)handler;

- (void)deliverProduct:(ABProduct *)product;

- (void)completeTransaction:(SKPaymentTransaction *)transaction;

- (void)failedTransaction:(SKPaymentTransaction *)transaction;

- (void)restoreTransaction:(SKPaymentTransaction *)transaction;

- (void)provideContent:(SKPaymentTransaction *)transaction;

- (void)sendABPurchaseWithId:(NSString *)productId 
                responseCode:(ABResponseCode)code 
              proccessStatus:(ABPurchaseProccessStatus)proccessStatus 
                      status:(ABPurchaseStatus)status 
                    proccess:(float)proccess 
                       error:(NSError *)error 
             notificationKey:(NSString *)notificationKey;

@end
