//
//  AMProduct.h
//  AppMocha
//
//  Created by Jason Wang on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMProduct : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSNumber * isFree;
@property (nonatomic, retain) NSNumber * isPurchased;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * downloadPath;
@property (nonatomic, retain) NSString * receipt;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * localizedDescription;

@end
