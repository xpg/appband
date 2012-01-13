//
//  ABRichView.m
//  AppBand
//
//  Created by Jason Wang on 11/11/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import "ABRichView.h"

@interface ABRichView()

- (void)setRichContent:(ABRichResponse *)response;

@end

@implementation ABRichView

@synthesize delegate;
@synthesize rid = _rid;

#pragma mark - ABRichDelegate

- (void)didRecieveRichContent:(ABRichResponse *)response {
    [self setRichContent:response];
}

#pragma mark - Public

- (void)setRichContent:(ABRichResponse *)response {
   
}

- (void)cancel {
    [[ABPush shared] cancelGetRichContent:self.rid];
    if (self.delegate) {
        [self.delegate cancelRichView:self];
    }
}


#pragma mark - lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        
    }
    return self;
}

- (void)dealloc {
    [self setRid:nil];
    [super dealloc];
}

@end
