//
//  ABDeliverHandler.h
//  AppBand
//
//  Created by Jason Wang on 11/24/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ABProduct;

@interface ABDeliverHandler : NSObject {
    
}

@property(nonatomic,readonly,copy) NSString *notificationKey;

@property(nonatomic,assign) id destroyTarget;
@property(nonatomic,assign) SEL destroySeletor;

+ (ABDeliverHandler *)handlerWithProduct:(ABProduct *)product 
                                    path:(NSString *)path 
                         notificationKey:(NSString *)key 
                           destroyTarget:(id)destroyTarget 
                         destroySelector:(SEL)destroySeletor;

- (void)begin;

@end
