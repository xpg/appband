//
//  ABRichView.h
//  AppBand
//
//  Created by Jason Wang on 11/11/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ABRichResponse.h"

@interface ABRichView : UIView <UIWebViewDelegate> {
    UIToolbar *toolbar;
    UILabel *titleLabel;
    UIWebView *webView;
    UIActivityIndicatorView *indicatorView;
    
    @private
        NSString *_rid;
}

@property(nonatomic,copy) NSString *rid;

- (void)setRichContent:(ABRichResponse *)response;

@end
