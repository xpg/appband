//
//  ABProductHandler.h
//  AppBand
//
//  Created by Jason Wang on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABHTTPRequest.h"

@interface ABProductHandler : NSObject <ABHTTPRequestDelegate>

@property(nonatomic,readonly,copy) NSString *group;
@property(nonatomic,readonly,copy) NSString *url;

@property(nonatomic,assign) id fetchTarget;
@property(nonatomic,assign) SEL fetchSelector;
@property(nonatomic,assign) id destroyTarget;
@property(nonatomic,assign) SEL destroySeletor;

+ (ABProductHandler *)handlerWithGroup:(NSString *)group 
                                   url:(NSString *)url 
                           fetchTarget:(id)fetchTarget 
                         fetchSelector:(SEL)fetchSelector 
                         destroyTarget:(id)destroyTarget 
                       destroySelector:(SEL)destroySeletor;

- (void)begin;

- (void)cancel;

@end
