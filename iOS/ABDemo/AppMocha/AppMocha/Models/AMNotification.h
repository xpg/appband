//
//  AMNotification.h
//  AppMocha
//
//  Created by Jason Wang on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMNotification : NSManagedObject

@property (nonatomic, retain) NSString * abri;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;

@end
