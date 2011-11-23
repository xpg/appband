//
//  ABProduct.h
//  AppBand
//
//  Created by Jason Wang on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABProduct : NSObject

@property(nonatomic,copy) NSString *productId;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *description;
@property(nonatomic,copy) NSString *icon;
@property(nonatomic,assign) BOOL isFree;
@property(nonatomic,assign) BOOL isPurchased;

@end
