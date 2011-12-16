//
//  ABProduct.h
//  AppBand
//
//  Created by Jason Wang on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>

@interface ABProduct : NSObject

@property(nonatomic,copy) NSString *productId;
@property(nonatomic,copy) NSString *icon;
@property(nonatomic,retain) SKProduct *skProduct;
@property(nonatomic,retain) SKPaymentTransaction *transaction;
@property(nonatomic,assign) BOOL isFree;
@property(nonatomic,assign) BOOL isPurchased;

@property(nonatomic,copy) NSData *receipt;

+ (id)productWithDictionary:(NSDictionary *)dictionary;

- (NSString *)localizedPrice:(SKProduct*)product;

@end
