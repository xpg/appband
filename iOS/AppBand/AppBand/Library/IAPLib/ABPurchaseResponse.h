//
//  ABPurchaseResponse.h
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

typedef enum {
    ABPurchaseStatusPaymentUnablePurchase,
    ABPurchaseStatusPaymentBegan,
    ABPurchaseStatusPaymentUnknown,
    ABPurchaseStatusPaymentSuccess,
    ABPurchaseStatusPaymentClientInvalid,
    ABPurchaseStatusPaymentInvalid,
    ABPurchaseStatusPaymentNotAllowed,
    ABPurchaseStatusPaymentCancelled,
    ABPurchaseStatusDeliverBegan,
    ABPurchaseStatusDelivering,
    ABPurchaseStatusDeliverFail,
    ABPurchaseStatusDeliverCancelled,
    ABPurchaseStatusDeliverURLFailure,
    ABPurchaseStatusParametersUnavailable,
    ABPurchaseStatusSuccess,
} ABPurchaseStatus;

typedef enum {
    ABPurchaseProccessStatusDoing,
    ABPurchaseProccessStatusEnd,
} ABPurchaseProccessStatus;

#import <Foundation/Foundation.h>

#import "ABResponse.h"

@interface ABPurchaseResponse : ABResponse {
    NSString *filePath;
    NSString *productId;
    
    ABPurchaseProccessStatus proccessStatus;
    ABPurchaseStatus status;
    float proccess;
}

@property(nonatomic,copy) NSString *filePath;
@property(nonatomic,copy) NSString *productId;
@property(nonatomic,assign) ABPurchaseProccessStatus proccessStatus;
@property(nonatomic,assign) ABPurchaseStatus status;
@property(nonatomic,assign) float proccess;

@end
