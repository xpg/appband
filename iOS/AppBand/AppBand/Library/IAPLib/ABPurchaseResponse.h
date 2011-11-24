//
//  ABPurchaseResponse.h
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABResponse.h"

@interface ABPurchaseResponse : ABResponse {
    NSString *filePath;
    NSString *productId;
    float proccess;
}

@property(nonatomic,copy) NSString *filePath;
@property(nonatomic,copy) NSString *productId;
@property(nonatomic,assign) float proccess;

@end
