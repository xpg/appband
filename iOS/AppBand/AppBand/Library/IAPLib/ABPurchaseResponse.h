//
//  ABPurchaseResponse.h
//  AppBand
//
//  Created by Jason Wang on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABResponse.h"

@interface ABPurchaseResponse : ABResponse {
    NSArray *products;
}

@property(nonatomic,copy) NSArray *products;

@end
