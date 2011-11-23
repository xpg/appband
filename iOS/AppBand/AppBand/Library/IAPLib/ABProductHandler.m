//
//  ABProductHandler.m
//  AppBand
//
//  Created by Jason Wang on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABProductHandler.h"

#import "ABPurchaseResponse.h"
#import "ABProduct.h"

#import "ABRestCenter.h"
#import "AB_SBJSON.h"

@interface ABProductHandler()

@property(nonatomic,readwrite,copy) NSString *group;
@property(nonatomic,readwrite,copy) NSString *url;

- (void)getProductsEnd:(NSDictionary *)response;

@end

@implementation ABProductHandler

@synthesize group = _group;
@synthesize url = _url;
@synthesize fetchTarget = _fetchTarget;
@synthesize fetchSelector = _fetchSelector;
@synthesize destroyTarget = _destroyTarget;
@synthesize destroySeletor = _destroySeletor;

#pragma mark - Private

- (void)getProductsEnd:(NSDictionary *)response {
    ABHTTPResponseCode code = [[response objectForKey:ABHTTPResponseKeyCode] intValue];
    
    if ([self.fetchTarget respondsToSelector:self.fetchSelector]) {
        ABPurchaseResponse *r = [[[ABPurchaseResponse alloc] init] autorelease];
        [r setCode:[[response objectForKey:ABHTTPResponseKeyCode] intValue]];
        [r setError:[response objectForKey:ABHTTPResponseKeyError]];
        
        if (code == ABHTTPResponseSuccess) {
            NSString *resp = [response objectForKey:ABHTTPResponseKeyContent];
            
            NSError *error = nil;
            AB_SBJSON *json = [[AB_SBJSON alloc] init];
            NSDictionary *richDic = [json objectWithString:resp error:&error];
            if (richDic && !error) {
                NSArray *products = [richDic objectForKey:AB_Products];
                if ([products count] > 0) {
                    NSMutableArray *tmp = [NSMutableArray array];
                    for (NSDictionary *productDic in products) {
                        NSString *productId = [productDic objectForKey:AB_Product_ID];
                        if (productId && ![productId isEqualToString:@""]) {
                            ABProduct *product = [[[ABProduct alloc] init] autorelease];
                            [product setProductId:productId];
                            [product setName:[productDic objectForKey:AB_Product_Name]];
                            [product setDescription:[productDic objectForKey:AB_Product_Description]];
                            [product setIcon:[productDic objectForKey:AB_Product_Icon]];
                            [product setIsFree:[[productDic objectForKey:AB_Product_IsFree] boolValue]];
                            [product setIsPurchased:[[productDic objectForKey:AB_Product_IsPurchased] boolValue]];
                            [tmp addObject:product];
                        }
                    }
                    [r setProducts:[NSArray arrayWithArray:tmp]];
                }
            }
            [json release];
        }
        
        //parser rich json
        [self.fetchTarget performSelector:self.fetchSelector withObject:r];
        
    }
    
    
        
    
    if ([self.destroyTarget respondsToSelector:self.destroySeletor]) {
        [self.destroyTarget performSelector:self.destroySeletor withObject:self];
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
    NSEnumerator *enumerator = [[[[ABRestCenter shared] queue] operations] objectEnumerator];
    ABHTTPRequest *request = nil;
    while (request = [enumerator nextObject]) {
        if ([request.key isEqualToString:self.url]) {
            [request cancel];
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
    [self setGroup:nil];
    [self setUrl:nil];
    [super dealloc];
}

@end
