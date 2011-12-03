//
//  AMDemoProduct.m
//  AppMocha
//
//  Created by Jason Wang on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AMDemoProduct.h"

@implementation AMDemoProduct

@synthesize product;
@synthesize filePath;
@synthesize isDownload;
@synthesize icon;

+ (AMDemoProduct *)productWithABProduct:(ABProduct *)pro {
    AMDemoProduct *p = [[[AMDemoProduct alloc] init] autorelease];
    [p setProduct:pro];
    [p setFilePath:nil];
    [p setIcon:nil];
    [p setIsDownload:NO];
    
    return p;
}

- (void)dealloc {
    [self setProduct:nil];
    [self setFilePath:nil];
    [self setIcon:nil];
    [super dealloc];
}

@end
