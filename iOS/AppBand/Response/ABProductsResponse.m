//
//  ABProductsResponse.m
//  AppBand
//
//  Created by Jason Wang on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABProductsResponse.h"

@implementation ABProductsResponse

@synthesize products;

- (void)dealloc {
    [self setProducts:nil];
    [super dealloc];
}

@end
