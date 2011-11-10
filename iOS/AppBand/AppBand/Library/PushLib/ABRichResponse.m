//
//  ABRichResponse.m
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABRichResponse.h"

@implementation ABRichResponse

@synthesize richContent;

- (void)dealloc {
    [self setRichContent:nil];
    [super dealloc];
}

@end
