//
//  ABResponse.m
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABResponse.h"

@implementation ABResponse

@synthesize code;
@synthesize error;

- (void)dealloc {
    [self setError:nil];
    [super dealloc];
}

@end
