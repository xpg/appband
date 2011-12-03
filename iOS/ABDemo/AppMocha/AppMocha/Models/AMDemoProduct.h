//
//  AMDemoProduct.h
//  AppMocha
//
//  Created by Jason Wang on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABProduct.h"

@interface AMDemoProduct : NSObject {
    ABProduct *product;
    NSString *filePath;
    BOOL isDownload;
    UIImage *icon;
}

@property(nonatomic,retain) ABProduct *product;
@property(nonatomic,copy) NSString *filePath;
@property(nonatomic,retain) UIImage *icon;
@property(assign) BOOL isDownload;

+ (AMDemoProduct *)productWithABProduct:(ABProduct *)pro;

@end
