//
//  ABPurchase.m
//  AppBand
//
//  Created by Jason Wang on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABPurchase.h"
#import "ABPurchase+Private.h"

@implementation ABPurchase

@synthesize productsHandleDictionay = _productsHandleDictionay;

SINGLETON_IMPLEMENTATION(ABPurchase)

#pragma mark - Private

- (void)getProductsEnd:(NSDictionary *)response {

}

- (void)destroyProductsHandler:(ABProductHandler *)handler {
    [self.productsHandleDictionay removeObjectForKey:handler.url];
}

#pragma mark - Public

/*
 * Get Products List
 * 
 * Paramters:
 *         group: products group, nil is for all products.
 *        target: callback invocator.
 *finishSelector: the SEL will call when done. Notice That: The selector must only has one paramter, which is NSArray object
 */
- (void)getAppProductByGroup:(NSString *)group 
                      target:(id)target 
             finfishSelector:(SEL)finishSelector {
    NSString *token = [[AppBand shared] deviceToken] ? [[AppBand shared] deviceToken] : @"";
    NSString *productGroup = group ? group : @"";
    NSString *urlString = [NSString stringWithFormat:@"%@/client_apps/%@/products?udid=%@&bundleid=%@&s=%@&token=%@&version=%@&group=%@",[[AppBand shared] server],[[AppBand shared] appKey],[[AppBand shared] udid],[[NSBundle bundleForClass:[self class]] bundleIdentifier],[[AppBand shared] appSecret],token,[[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"],productGroup];
    
    ABProductHandler *handler = [self.productsHandleDictionay objectForKey:urlString];
    if (handler) {
        [handler setFetchTarget:target];
        [handler setFetchSelector:finishSelector];
    } else {
        handler = [ABProductHandler handlerWithGroup:group url:urlString fetchTarget:target fetchSelector:finishSelector destroyTarget:self destroySelector:@selector(destroyProductsHandler:)];
        [self.productsHandleDictionay setObject:handler forKey:urlString];
        
        [handler begin];
    }
}

/*
 * Purchase Product
 * 
 * Paramters:
 *       product: product.
 *       
 */
- (void)purchaseProduct:(id)product {

}

/*
 * Download Product
 * 
 * Paramters:
 *       product: product.
 *       
 */
- (void)downloadProduct:(id)product {

}

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        _productsHandleDictionay = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [self setProductsHandleDictionay:nil];
    [super dealloc];
}

@end
