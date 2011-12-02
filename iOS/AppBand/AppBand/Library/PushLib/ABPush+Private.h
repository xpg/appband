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
#import "ABRichView.h"

@interface ABPush() <ABRichViewDelegate>

@property(nonatomic,retain) NSMutableDictionary *richHandleDictionay;
@property(nonatomic,retain) ABRichView *richView;

- (void)callbackPushSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                pushSelector:(SEL)pushSelector 
              notificationId:(NSString *)notificationId;
                         
- (void)callbackRichSelector:(NSDictionary *)notification 
            applicationState:(UIApplicationState)state 
                      target:(id)target 
                richSelector:(SEL)richSelector 
              notificationId:(NSString *)notificationId;

- (void)impressionRichEnd:(ABRichHandler *)handler;

- (void)showRich:(NSString *)rid;

@end
