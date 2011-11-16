//
//  ABRichView.h
//  AppBand
//
//  Created by Jason Wang on 11/11/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ABRichResponse.h"

@protocol ABRichViewDelegate;

@interface ABRichView : UIView <UIWebViewDelegate> {
    id<ABRichViewDelegate> delegate;
    UIToolbar *toolbar;
    UILabel *titleLabel;
    UIWebView *webView;
    UIActivityIndicatorView *indicatorView;
    
    @private
        NSString *_rid;
}

@property(nonatomic,assign) id<ABRichViewDelegate> delegate;
@property(nonatomic,copy) NSString *rid;

- (void)setRichContent:(ABRichResponse *)response;

@end

@protocol ABRichViewDelegate <NSObject>

- (void)cancelRichView:(ABRichView *)richView;

@end
