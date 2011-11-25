//
//  ABPurchaseResponse.m
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABPurchaseResponse.h"

@implementation ABPurchaseResponse

@synthesize filePath;
@synthesize productId;
@synthesize status;
@synthesize proccess;

- (void)dealloc {
    [self setFilePath:nil];
    [self setProductId:nil];
    [super dealloc];
}

@end
