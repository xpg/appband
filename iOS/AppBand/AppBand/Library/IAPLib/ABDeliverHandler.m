//
//  ABDeliverHandler.m
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABDeliverHandler.h"
#import "ABDeliverHandler+Private.h"

@implementation ABDeliverHandler

@synthesize product = _product;

- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

- (void)begin {
    NSString *urlString = [NSString stringWithFormat:@"%@/client_apps/%@/products/transactions.json?",[[AppBand shared] server],[[AppBand shared] appKey]];
    NSString *token = [[AppBand shared] deviceToken] ? [[AppBand shared] deviceToken] : @"";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[[AppBand shared] appSecret] forKey:AB_APP_SECRET];
    [parameters setObject:[[AppBand shared] udid] forKey:AB_DEVICE_UDID];
    [parameters setObject:[[NSBundle bundleForClass:[self class]] bundleIdentifier] forKey:AB_APP_BUNDLE_IDENTIFIER];
    [parameters setObject:token forKey:AB_DEVICE_TOKEN];
    [parameters setObject:[[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:AB_APP_BUNDLE_VERSION];
    [parameters setObject:token forKey:AB_DEVICE_TOKEN];
    
    if (self.product.transaction) {
        [parameters setObject:self.product.transaction.payment.productIdentifier forKey:AB_Product_ID];
        [parameters setObject:[self encode:(uint8_t *)self.product.transaction.transactionReceipt.bytes length:self.product.transaction.transactionReceipt.length] forKey:AB_Product_Receipt];
    } else {
        [parameters setObject:self.product.productId forKey:AB_Product_ID];
    }
    
    
    
    ABHTTPRequest *request = [ABHTTPRequest requestWithKey:urlString 
                                                       url:urlString 
                                                 parameter:parameters
                                                   timeout:kAppBandRequestTimeout
                                                  delegate:nil
                                                    finish:nil
                                                      fail:nil];
    [[ABRestCenter shared] addRequest:request];
}

#pragma mark - lifecycle

+ (ABDeliverHandler *)handlerWithProduct:(ABProduct *)product {
    ABDeliverHandler *deliverHandler = [[[ABDeliverHandler alloc] init] autorelease];
    [deliverHandler setProduct:product];
    
    return deliverHandler;
}

- (void)dealloc {
    [self setProduct:nil];
    [super dealloc];
}

@end
