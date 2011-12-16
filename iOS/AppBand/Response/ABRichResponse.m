//
//  ABRichResponse.m
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import "ABRichResponse.h"

@implementation ABRichResponse

@synthesize richTitle;
@synthesize richContent;

- (void)dealloc {
    [self setRichTitle:nil];
    [self setRichContent:nil];
    [super dealloc];
}

@end
