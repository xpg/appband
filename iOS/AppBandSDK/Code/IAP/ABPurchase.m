//
//  ABPurchase.m
//  AppBandSDK
//
//  Created by Jason Wang on 1/20/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "ABPurchase+Private.h"

@implementation ABPurchase

@synthesize productsKey = _productsKey;
@synthesize productsTarget = _productsTarget;
@synthesize productsSEL = _productsSEL;

@synthesize purchaseQueue = _purchaseQueue;

@synthesize delegate;

SINGLETON_IMPLEMENTATION(ABPurchase)

#pragma mark - Private

- (ABHttpRequest *)initProductsHttpRequest:(NSString *)group {
    NSString *productGroup = group ? group : @"";
    
    NSString *token = [[[AppBand shared] appUser] token] ? [[[AppBand shared] appUser] token] : @"";
    NSString *appKey = [[AppBand shared] appKey];
    NSString *appSecret = [[AppBand shared] appSecret];
    NSString *udid = [[[AppBand shared] appUser] udid];
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    NSString *version = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/client_apps/%@/products.json?udid=%@&bundleid=%@&s=%@&token=%@&version=%@&group=%@",[[[AppBand shared] configuration] server],appKey,udid,bundleId,appSecret,token,version,productGroup];
    
    self.productsKey = [[NSDate date] description];
    
    return [ABHttpRequest requestWithKey:self.productsKey url:urlString parameter:nil timeout:AppBandSettingsTimeout target:self finishSelector:@selector(getProductsEnd:)];
}

- (void)addRequestToQueue:(ABHttpRequest *)request {
    [[ABPurchase shared].purchaseQueue addOperation:request];
}

- (void)getProductsEnd:(NSDictionary *)response {

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
              finishSelector:(SEL)finishSelector {
    self.productsTarget = target;
    self.productsSEL = finishSelector;
    
    ABHttpRequest *request = [[ABPurchase shared] initProductsHttpRequest:group];
    [[ABPurchase shared] addRequestToQueue:request];
}

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        self.purchaseQueue = [ABNetworkQueue networkQueue];
    }
    
    return self;
}

- (void)dealloc {
    [self setPurchaseQueue:nil];
    [self setProductsKey:nil];
    [super dealloc];
}

@end
