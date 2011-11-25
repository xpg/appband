//
//  ABProduct.m
//  AppBand
//
//  Created by Jason Wang on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABProduct.h"

#import "ABGlobal.h"

@implementation ABProduct

@synthesize productId;
@synthesize icon;
@synthesize isFree;
@synthesize isPurchased;

@synthesize skProduct;
@synthesize transaction;
@synthesize receipt;

#pragma mark - Public

- (NSString *)localizedPrice:(SKProduct*)product {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    [numberFormatter release];
    
    return formattedString;
}

#pragma mark - lifecycle

+ (id)productWithDictionary:(NSDictionary *)dictionary {
    NSString *productId = [dictionary objectForKey:AB_Product_ID];
    
    if (!productId || [productId isEqualToString:@""]) return nil;
    
    ABProduct *product = [[[ABProduct alloc] init] autorelease];
    [product setProductId:productId];
    [product setIcon:[dictionary objectForKey:AB_Product_Icon]];
    [product setIsFree:[[dictionary objectForKey:AB_Product_IsFree] boolValue]];
    [product setIsPurchased:[[dictionary objectForKey:AB_Product_IsPurchased] boolValue]];
    
    return product;
}

- (void)dealloc {
    [self setProductId:nil];
    [self setIcon:nil];
    [self setSkProduct:nil];
    [self setReceipt:nil];
    [super dealloc];
}

@end
