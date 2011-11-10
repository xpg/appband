//
//  ABPush_Private.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import "AppBand.h"
#import "ABConstant.h"

#import "ABNotification.h"
#import "ABRichHandler.h"

@interface ABPush()

@property(nonatomic,retain) NSMutableDictionary *richHandleDictionay;

- (void)callbackPushSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                pushSelector:(SEL)pushSelector;
                         
- (void)callbackRichSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                richSelector:(SEL)richSelector 
                      richId:(NSString *)richId;

- (void)impressionRichEnd:(ABRichHandler *)handler;

- (void)showRich:(NSString *)rid;

@end
