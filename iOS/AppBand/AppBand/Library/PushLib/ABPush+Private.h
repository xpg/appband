//
//  ABPush_Private.h
//  AppBand
//
//  Created by Jason Wang on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@interface ABPush()

- (void)handlePushWhenActive:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                pushSelector:(SEL)pushSelector;

- (void)handlePushWhenNonActive:(NSDictionary *)notification 
               applicationState:(UIApplicationState)state
                         target:(id)target 
                   pushSelector:(SEL)pushSelector;

- (void)handleRichWhenActive:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                richSelector:(SEL)richSelector 
                      richId:(NSString *)richId;

- (void)handleRichWhenNonActive:(NSDictionary *)notification 
               applicationState:(UIApplicationState)state
                         target:(id)target 
                   richSelector:(SEL)richSelector 
                         richId:(NSString *)richId;

@end
