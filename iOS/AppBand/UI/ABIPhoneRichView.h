//
//  ABIPhoneRichView.h
//  AppBand
//
//  Created by Jason Wang on 12/13/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ABRichView.h"

@interface ABIPhoneRichView : ABRichView {
    UILabel *titleLabel;
    UIWebView *webView;
    UIActivityIndicatorView *indicatorView;
}

@end
