//
//  ABRichResponse.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABResponse.h"

@interface ABRichResponse : ABResponse {
    NSString *richTitle;
    NSString *richContent;
    NSString *notificationId;
}

@property(nonatomic,copy) NSString *richTitle;
@property(nonatomic,copy) NSString *richContent;
@property(nonatomic,copy) NSString *notificationId;

@end
