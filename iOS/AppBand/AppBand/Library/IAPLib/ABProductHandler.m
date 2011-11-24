//
//  ABProductHandler.m
//  AppBand
//
//  Created by Jason Wang on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABProductHandler.h"
#import "ABProductHandler+Private.h"

@implementation ABProductHandler

@synthesize productsDictionary = _productsDictionary;
@synthesize response = _response;

@synthesize group = _group;
@synthesize url = _url;

@synthesize productsRequest = _productsRequest;

@synthesize fetchTarget = _fetchTarget;
@synthesize fetchSelector = _fetchSelector;
@synthesize destroyTarget = _destroyTarget;
@synthesize destroySeletor = _destroySeletor;

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *skProducts = [response products];
    NSMutableArray *tmp = [NSMutableArray array];
    for (SKProduct *skProduct in skProducts) {
        ABProduct *product = [self.productsDictionary objectForKey:skProduct.productIdentifier];
        if (product) {
            [product setSkProduct:skProduct];
            [tmp addObject:product];
        }
    }
    
    if ([self.fetchTarget respondsToSelector:self.fetchSelector]) {
        [self.response setProducts:tmp];
        [self.fetchTarget performSelector:self.fetchSelector withObject:self.response];
    }
    
    [request release];
    self.productsRequest = nil;
    
    if ([self.destroyTarget respondsToSelector:self.destroySeletor]) {
        [self.destroyTarget performSelector:self.destroySeletor withObject:self];
    }
}

#pragma mark - Private

- (void)getProductsEnd:(NSDictionary *)response {
    ABHTTPResponseCode code = [[response objectForKey:ABHTTPResponseKeyCode] intValue];
    NSMutableSet *productIdentifiers = [NSMutableSet set];
    self.productsDictionary = [NSMutableDictionary dictionary];
    
    ABProductsResponse *productsResponse = [[[ABProductsResponse alloc] init] autorelease];
    
    if ([self.fetchTarget respondsToSelector:self.fetchSelector]) {
        [productsResponse setCode:[[response objectForKey:ABHTTPResponseKeyCode] intValue]];
        [productsResponse setError:[response objectForKey:ABHTTPResponseKeyError]];
        
        if (code == ABHTTPResponseSuccess) {
            NSString *resp = [response objectForKey:ABHTTPResponseKeyContent];
            
            //parser response json
            NSError *error = nil;
            AB_SBJSON *json = [[AB_SBJSON alloc] init];
            NSDictionary *richDic = [json objectWithString:resp error:&error];
            [json release];
            
            //get products list
            if (richDic && !error) {
                NSArray *products = [richDic objectForKey:AB_Products];
                if ([products count] > 0) {
                    for (NSDictionary *productDic in products) {
                        ABProduct *product = [ABProduct productWithDictionary:productDic];
                        if (product) {
                            [self.productsDictionary setObject:product forKey:product.productId];
                            [productIdentifiers addObject:product.productId];
                        }
                    }
                }
            }
            
        } 
    }
    
    if ([productIdentifiers count] <= 0) {
        [self.fetchTarget performSelector:self.fetchSelector withObject:productsResponse];
        
        if ([self.destroyTarget respondsToSelector:self.destroySeletor]) {
            [self.destroyTarget performSelector:self.destroySeletor withObject:self];
        }
    } else {
        self.response = productsResponse;
        
        self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: productIdentifiers];
        [self.productsRequest setDelegate:self];
        [self.productsRequest start];
    }
    
}

#pragma mark - Public

- (void)begin {
    ABHTTPRequest *request = [ABHTTPRequest requestWithKey:self.url 
                                                       url:self.url 
                                                 parameter:nil
                                                   timeout:kAppBandRequestTimeout
                                                  delegate:self
                                                    finish:@selector(getProductsEnd:)
                                                      fail:@selector(getProductsEnd:)];
    [[ABRestCenter shared] addRequest:request];
}

- (void)cancel {
    if (self.productsRequest) {
        [self.productsRequest setDelegate:nil];
        [self.productsRequest cancel];
        
        [_productsRequest release];
        self.productsRequest = nil;
        
        if ([self.destroyTarget respondsToSelector:self.destroySeletor]) {
            [self.destroyTarget performSelector:self.destroySeletor withObject:self];
        }
    } else {
        NSEnumerator *enumerator = [[[[ABRestCenter shared] queue] operations] objectEnumerator];
        ABHTTPRequest *request = nil;
        while (request = [enumerator nextObject]) {
            if ([request.key isEqualToString:self.url]) {
                [request cancel];
            }
        }
    }
}

#pragma mark - lifecycle

+ (ABProductHandler *)handlerWithGroup:(NSString *)group 
                                   url:(NSString *)url 
                           fetchTarget:(id)fetchTarget 
                         fetchSelector:(SEL)fetchSelector 
                         destroyTarget:(id)destroyTarget 
                       destroySelector:(SEL)destroySeletor {
    ABProductHandler *handler = [[[ABProductHandler alloc] init] autorelease];
    [handler setGroup:group];
    [handler setUrl:url];
    [handler setFetchTarget:fetchTarget];
    [handler setFetchSelector:fetchSelector];
    [handler setDestroyTarget:destroyTarget];
    [handler setDestroySeletor:destroySeletor];
    
    return handler;
}

- (void)dealloc {
    [self setProductsDictionary:nil];
    [self setResponse:nil];
    [self setGroup:nil];
    [self setUrl:nil];
    [super dealloc];
}

@end
