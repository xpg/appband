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

@synthesize paymentStatusTarget = _paymentStatusTarget;
@synthesize paymentStatusSelector = _paymentStatusSelector;

@synthesize deliverHnadlerDictionary = _deliverHnadlerDictionary;
@synthesize productsHandlerDictionay = _productsHandlerDictionay;

@synthesize product = _product;

SINGLETON_IMPLEMENTATION(ABPurchase)

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchased:
              [self completeTransaction:transaction];
              break;
            case SKPaymentTransactionStateFailed:
              [self failedTransaction:transaction];
              break;
            case SKPaymentTransactionStateRestored:
              [self restoreTransaction:transaction];
            default:
              break;
        }
    }
}

#pragma mark - Private

- (void)destroyProductsHandler:(ABProductHandler *)handler {
    NSString *key = [NSString stringWithString:handler.url];
    [self.productsHandlerDictionay removeObjectForKey:key];
}

/*
 * Download Product
 * 
 * Paramters:
 *       product: product.
 *       
 */
- (void)deliverProduct:(ABProduct *)product {
    if (!product) return;
    ABDeliverHandler *handler = [self.deliverHnadlerDictionary objectForKey:product.productId];
    if (handler) {
    } else {
        handler = [ABDeliverHandler handlerWithProduct:product];
        [handler begin];
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self provideContent:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self provideContent:transaction];
}

- (void)failedTransaction: (SKPaymentTransaction *)transaction {
    ABPurchaseResponse *productResponse = [[[ABPurchaseResponse alloc] init] autorelease];
    ABPurchaseStatus code;
    switch (transaction.error.code) {
        case SKErrorUnknown:
            code = ABPurchaseStatusPaymentUnknown;
            break;
        case SKErrorClientInvalid:
            code = ABPurchaseStatusPaymentClientInvalid;
            break;
        case SKErrorPaymentInvalid:
            code = ABPurchaseStatusPaymentInvalid;
            break;
        case SKErrorPaymentNotAllowed:
            code = ABPurchaseStatusPaymentNotAllowed;
            break;
        default:
            code = ABPurchaseStatusPaymentCancelled;
            break;
    }
    
    [productResponse setCode:ABResponseCodeHTTPError];
    [productResponse setError:[NSError errorWithDomain:AppBandSDKErrorDomain code:code userInfo:nil]];
    [productResponse setProductId:transaction.payment.productIdentifier];
    [productResponse setStatus:code];
    
    if ([self.paymentStatusTarget respondsToSelector:self.paymentStatusSelector]) {
        [self.paymentStatusTarget performSelector:self.paymentStatusSelector withObject:productResponse];
    }
    
    
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)provideContent:(SKPaymentTransaction *)transaction {
    ABPurchaseResponse *productResponse = [[[ABPurchaseResponse alloc] init] autorelease];
    [productResponse setCode:ABResponseCodeHTTPSuccess];
    [productResponse setError:nil];
    [productResponse setProductId:transaction.payment.productIdentifier];
    [productResponse setStatus:ABPurchaseStatusPaymentSuccess];
    
    if ([self.paymentStatusTarget respondsToSelector:self.paymentStatusSelector]) {
        [self.paymentStatusTarget performSelector:self.paymentStatusSelector withObject:productResponse];
    }
    
    self.product.transaction = transaction;
    
    if (transaction.originalTransaction) {
        self.product.transaction = transaction.originalTransaction;
    }
    
    [self deliverProduct:self.product];
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
    NSString *urlString = [NSString stringWithFormat:@"%@/client_apps/%@/products.json?udid=%@&bundleid=%@&s=%@&token=%@&version=%@&group=%@",[[AppBand shared] server],[[AppBand shared] appKey],[[AppBand shared] udid],[[NSBundle bundleForClass:[self class]] bundleIdentifier],[[AppBand shared] appSecret],token,[[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"],productGroup];
    
    ABProductHandler *handler = [self.productsHandlerDictionay objectForKey:urlString];
    if (handler) {
        [handler setFetchTarget:target];
        [handler setFetchSelector:finishSelector];
    } else {
        handler = [ABProductHandler handlerWithGroup:group url:urlString fetchTarget:target fetchSelector:finishSelector destroyTarget:self destroySelector:@selector(destroyProductsHandler:)];
        [self.productsHandlerDictionay setObject:handler forKey:urlString];
        
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
- (void)purchaseProduct:(ABProduct *)product 
           statusTarget:(id)statusTarget 
         statusSelector:(SEL)statusSelector 
         proccessTarget:(id)proccessTarget 
       proccessSelector:(SEL)proccessSeletor {
    
    self.paymentStatusTarget = statusTarget;
    self.paymentStatusSelector = statusSelector;
    
    if (!product || [product.productId isEqualToString:@""]) {
        ABPurchaseResponse *productResponse = [[[ABPurchaseResponse alloc] init] autorelease];
        [productResponse setCode:ABResponseCodeHTTPError];
        [productResponse setError:[NSError errorWithDomain:AppBandSDKErrorDomain code:ABResponseCodeHTTPError userInfo:nil]];
        [productResponse setProductId:product.productId];
        [productResponse setStatus:ABPurchaseStatusProductUnavailable];
        
        if ([self.paymentStatusTarget respondsToSelector:self.paymentStatusSelector]) {
            [self.paymentStatusTarget performSelector:self.paymentStatusSelector withObject:productResponse];
        }
        
        return;
    }
    
    if (![SKPaymentQueue canMakePayments] && !product.isFree && !product.transaction) {
        ABPurchaseResponse *productResponse = [[[ABPurchaseResponse alloc] init] autorelease];
        [productResponse setCode:ABResponseCodeHTTPError];
        [productResponse setError:[NSError errorWithDomain:AppBandSDKErrorDomain code:ABResponseCodeHTTPError userInfo:nil]];
        [productResponse setProductId:product.productId];
        [productResponse setStatus:ABPurchaseStatusPaymentUnablePurchase];
        
        if ([self.paymentStatusTarget respondsToSelector:self.paymentStatusSelector]) {
            [self.paymentStatusTarget performSelector:self.paymentStatusSelector withObject:productResponse];
        }
        
        return;
    }
    
    if (product.isFree || product.transaction) {
        [self deliverProduct:product];
    } else {
        self.product = nil;
        self.product = product;
        
        ABPurchaseResponse *productResponse = [[[ABPurchaseResponse alloc] init] autorelease];
        [productResponse setCode:ABResponseCodeHTTPSuccess];
        [productResponse setError:nil];
        [productResponse setProductId:product.productId];
        [productResponse setStatus:ABPurchaseStatusPaymentBegan];
        
        if ([self.paymentStatusTarget respondsToSelector:self.paymentStatusSelector]) {
            [self.paymentStatusTarget performSelector:self.paymentStatusSelector withObject:productResponse];
        }
        
        SKPayment *payment = [SKPayment paymentWithProduct:product.skProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

#pragma mark - lifecycle

- (id)init {
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        _productsHandlerDictionay = [[NSMutableDictionary alloc] init];
        _deliverHnadlerDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [self setProduct:nil];
    [self setProductsHandlerDictionay:nil];
    [self setDeliverHnadlerDictionary:nil];
    [super dealloc];
}

@end
