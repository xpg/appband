//
//  ABUtilty.h
//  AppBandSDK
//
//  Created by Jason Wang on 1/9/12.
//  Copyright (c) 2012 Xtreme Programming Group. All rights reserved.
//

#import "AB_SBJSON.h"

static inline NSData * getParameterData(NSDictionary *parameter) {
    NSData *data = nil;
    NSError *error = nil;
    AB_SBJSON *sbJson = [[AB_SBJSON alloc] init];
    NSString *postString = [sbJson stringWithObject:parameter error:&error];
    [sbJson release];
    
    if (error) 
        return nil;
    
    data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

