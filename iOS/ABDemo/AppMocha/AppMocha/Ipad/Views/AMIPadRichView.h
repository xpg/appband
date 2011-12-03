//
//  AMIPadRichView.h
//  AppMocha
//
//  Created by Jason Wang on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AMModelConstant.h"

@protocol AMIPadRichViewDelegate;

@interface AMIPadRichView : UIView {
    IBOutlet id<AMIPadRichViewDelegate> delegate;
    IBOutlet UIWebView *webView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UIActivityIndicatorView *indicatorView;
}

@property(nonatomic,assign) IBOutlet id<AMIPadRichViewDelegate> delegate;
@property(nonatomic,retain) AMNotification *notification;

- (void)setTarget:(AMNotification *)notification;

- (IBAction)close:(id)sender;

@end

@protocol AMIPadRichViewDelegate <NSObject>

- (void)richViewClosed:(AMIPadRichView *)richView;

@end
