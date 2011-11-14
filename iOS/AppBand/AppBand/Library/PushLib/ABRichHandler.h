//
//  ABRichHandler.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABHTTPRequest.h"

@interface ABRichHandler : NSObject <ABHTTPRequestDelegate> {
    
}

@property(nonatomic,copy) NSString *rid;
@property(nonatomic,assign) id fetchTarget;
@property(nonatomic,assign) SEL fetchSelector;

@property(nonatomic,readonly,copy) NSString *fetchKey;
@property(nonatomic,readonly,copy) NSString *impressionKey;

+ (ABRichHandler *)handlerWithRichID:(NSString *)richID 
                         fetchTarget:(id)fetchTarget 
                       fetchSelector:(SEL)fetchSelector 
                    impressionTarget:(id)impressionTarget
                  impressionSelector:(SEL)impressionSelector;

- (void)begin;

- (void)cancel;

@end
