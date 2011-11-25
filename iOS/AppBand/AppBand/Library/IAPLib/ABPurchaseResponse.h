//
//  ABPurchaseResponse.h
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

typedef enum {
    ABPurchaseStatusPaymentBegan,
    ABPurchaseStatusPaymentUnknown,
    ABPurchaseStatusPaymentSuccess,
    ABPurchaseStatusProductDeliverBegan,
    ABPurchaseStatusProductDelivering,
    ABPurchaseStatusPaymentClientInvalid,
    ABPurchaseStatusPaymentInvalid,
    ABPurchaseStatusPaymentNotAllowed,
    ABPurchaseStatusPaymentCancelled,
    ABPurchaseStatusPaymentUnablePurchase,
    ABPurchaseStatusProductUnavailable,
} ABPurchaseStatus;

#import <Foundation/Foundation.h>

#import "ABResponse.h"

@interface ABPurchaseResponse : ABResponse {
    NSString *filePath;
    NSString *productId;
    
    ABPurchaseStatus status;
    float proccess;
}

@property(nonatomic,copy) NSString *filePath;
@property(nonatomic,copy) NSString *productId;
@property(nonatomic,assign) ABPurchaseStatus status;
@property(nonatomic,assign) float proccess;

@end
