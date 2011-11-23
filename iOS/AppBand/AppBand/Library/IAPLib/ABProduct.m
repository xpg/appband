//
//  ABProduct.m
//  AppBand
//
//  Created by Jason Wang on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABProduct.h"

@implementation ABProduct

@synthesize productId;
@synthesize name;
@synthesize description;
@synthesize icon;
@synthesize isFree;
@synthesize isPurchased;

#pragma mark - lifecycle

- (void)dealloc {
    [self setProductId:nil];
    [self setName:nil];
    [self setDescription:nil];
    [self setIcon:nil];
    [super dealloc];
}

@end
