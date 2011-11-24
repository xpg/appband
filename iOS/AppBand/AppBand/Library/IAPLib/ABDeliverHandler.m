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
