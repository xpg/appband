//
//  ABDeliverHandler+Private.h
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppBand.h"
#import "ABProduct.h"
#import "ABGlobal.h"

#import "ABPurchaseResponse.h"
#import "ABDonwloadManager.h"

#import "ABHTTPRequest.h"
#import "ABRestCenter.h"

#import "AB_SBJSON.h"

@interface ABDeliverHandler() <ABHTTPRequestDelegate>

@property(nonatomic,copy) NSString *transactionId;
@property(nonatomic,readwrite,copy) NSString *notificationKey;
@property(nonatomic,retain) ABProduct *product;
@property(nonatomic,copy) NSString *path;

- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length;

- (void)getDownloadURLEnd:(NSDictionary *)response;

@end
