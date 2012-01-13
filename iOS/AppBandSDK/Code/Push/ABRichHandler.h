//
//  ABRichHandler.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ABPush.h"

@protocol ABRichHandlerDelegate;

@interface ABRichHandler : NSObject {
    
}

@property(nonatomic,assign) id<ABRichDelegate> richDelegate;

@property(nonatomic,copy) NSString *rid;

@property(nonatomic,readonly,copy) NSString *fetchKey;
@property(nonatomic,readonly,copy) NSString *impressionKey;

+ (ABRichHandler *)handlerWithRichID:(NSString *)richID richDelegate:(id<ABRichDelegate>)richDelegate handlerDelegate:(id<ABRichHandlerDelegate>)handlerDelegate;

- (void)begin;

- (void)cancel;

@end

@protocol ABRichHandlerDelegate <NSObject>

- (void)getRichEnd:(ABRichHandler *)richHandler;

@end
