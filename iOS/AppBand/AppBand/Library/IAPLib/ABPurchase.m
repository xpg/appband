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

@synthesize isPurchasing = _isPurchasing;

@synthesize path = _path;
@synthesize notificationKey = _notificationKey;

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

- (void)sendABPurchaseWithId:(NSString *)productId 
                responseCode:(ABResponseCode)code 
              proccessStatus:(ABPurchaseProccessStatus)proccessStatus 
                      status:(ABPurchaseStatus)status 
                    proccess:(float)proccess 
                       error:(NSError *)error 
             notificationKey:(NSString *)notificationKey {
    
    ABPurchaseResponse *productResponse = [[[ABPurchaseResponse alloc] init] autorelease];
    [productResponse setProductId:productId];
    [productResponse setCode:code];
    [productResponse setError:error];
    [productResponse setProccessStatus:proccessStatus];
    [productResponse setStatus:status];
    [productResponse setProccess:proccess];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationKey object:productResponse];
}

- (void)destroyProductsHandler:(ABProductHandler *)handler {
    [self.productsHandlerDictionay removeObjectForKey:handler.url];
}

- (void)destroyDeliverProduct:(ABDeliverHandler *)handler {
    [self.deliverHnadlerDictionary removeObjectForKey:handler.notificationKey];
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
    ABDeliverHandler *handler = [self.deliverHnadlerDictionary objectForKey:self.notificationKey];
    if (!handler) {
        handler = [ABDeliverHandler handlerWithProduct:product path:self.path notificationKey:self.notificationKey destroyTarget:self destroySelector:@selector(destroyDeliverProduct:)];
        
        [self.deliverHnadlerDictionary setObject:handler forKey:self.notificationKey];
        
        [handler begin];
    }
    
    self.isPurchasing = NO;
    self.path = nil;
    self.product = nil;
    self.notificationKey = nil;
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self provideContent:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self provideContent:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
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
    
    [self sendABPurchaseWithId:transaction.payment.productIdentifier responseCode:ABResponseCodeHTTPError proccessStatus:ABPurchaseProccessStatusEnd status:code proccess:0. error:[NSError errorWithDomain:AppBandSDKErrorDomain code:code userInfo:nil] notificationKey:self.notificationKey];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    self.isPurchasing = NO;
    self.path = nil;
    self.product = nil;
    self.notificationKey = nil;
}

- (void)provideContent:(SKPaymentTransaction *)transaction {
    [self sendABPurchaseWithId:transaction.payment.productIdentifier responseCode:ABResponseCodeHTTPSuccess proccessStatus:ABPurchaseProccessStatusDoing status:ABPurchaseStatusPaymentSuccess proccess:0. error:nil notificationKey:self.notificationKey];
    
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
             finishSelector:(SEL)finishSelector {
    NSString *token = [[AppBand shared] deviceToken] ? [[AppBand shared] deviceToken] : @"";
    NSString *productGroup = group ? group : @"";
    NSString *server = [[AppBand shared] server];
    NSString *appKey = [[AppBand shared] appKey];
    NSString *appSecret = [[AppBand shared] appSecret];
    NSString *udid = [[AppBand shared] udid];
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    NSString *version = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/client_apps/%@/products.json?udid=%@&bundleid=%@&s=%@&token=%@&version=%@&group=%@",server,appKey,udid,bundleId,appSecret,token,version,productGroup];
    
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
- (void)purchaseProduct:(ABProduct *)product notificationKey:(NSString *)key path:(NSString *)path {
    
    if (!product || [product.productId isEqualToString:@""] || !key || [key isEqualToString:@""] || !path || [path isEqualToString:@""]) {
        [self sendABPurchaseWithId:product.productId responseCode:ABResponseCodeHTTPError proccessStatus:ABPurchaseProccessStatusEnd status:ABPurchaseStatusParametersUnavailable proccess:0. error:[NSError errorWithDomain:AppBandSDKErrorDomain code:ABResponseCodeHTTPError userInfo:nil] notificationKey:key];
        
        return;
    }
    
    if (![SKPaymentQueue canMakePayments] && !product.isFree && !product.transaction) {
        [self sendABPurchaseWithId:product.productId responseCode:ABResponseCodeHTTPError proccessStatus:ABPurchaseProccessStatusEnd status:ABPurchaseStatusPaymentUnablePurchase proccess:0. error:[NSError errorWithDomain:AppBandSDKErrorDomain code:ABResponseCodeHTTPError userInfo:nil] notificationKey:key];
        
        return;
    }
    
    if (self.isPurchasing) {
        [self sendABPurchaseWithId:product.productId responseCode:ABResponseCodeHTTPError proccessStatus:ABPurchaseProccessStatusEnd status:ABPurchaseStatusPaymentBlocking proccess:0. error:[NSError errorWithDomain:AppBandSDKErrorDomain code:ABResponseCodeHTTPError userInfo:nil] notificationKey:key];
        
        return;
    }
    
    self.notificationKey = key;
    self.path = path;
    
    self.isPurchasing = YES;
    
    if (product.isFree || product.transaction) {
        [self deliverProduct:product];
    } else {
        self.product = nil;
        self.product = product;
        
        [self sendABPurchaseWithId:product.productId responseCode:ABResponseCodeHTTPSuccess proccessStatus:ABPurchaseProccessStatusDoing status:ABPurchaseStatusPaymentBegan proccess:0. error:nil notificationKey:self.notificationKey];
        
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
    [self setPath:nil];
    [self setNotificationKey:nil];
    [self setProduct:nil];
    [self setProductsHandlerDictionay:nil];
    [self setDeliverHnadlerDictionary:nil];
    [super dealloc];
}

@end
