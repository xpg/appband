//
//  ABIPadRichView.h
//  AppBand
//
//  Created by Jason Wang on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ABRichView.h"

@interface ABIPadRichView : ABRichView {
    UILabel *titleLabel;
    UIWebView *webView;
    UIActivityIndicatorView *indicatorView;
}

@end
