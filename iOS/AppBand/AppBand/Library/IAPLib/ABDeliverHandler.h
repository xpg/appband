//
//  ABDeliverHandler.h
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABProduct;

@interface ABDeliverHandler : NSObject {
}

+ (ABDeliverHandler *)handlerWithProduct:(ABProduct *)product;

- (void)begin;

@end
