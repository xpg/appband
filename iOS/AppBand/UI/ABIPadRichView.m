//
//  ABIPadRichView.m
//  AppBand
//
//  Created by Jason Wang on 12/13/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import "ABIPadRichView.h"

@implementation ABIPadRichView

#pragma mark - Public

- (void)setRichContent:(ABRichResponse *)response {
    [self performSelectorOnMainThread:@selector(showRich:) withObject:response waitUntilDone:YES];
}

#pragma mark - Private

- (void)showRich:(ABRichResponse *)response {
    if (indicatorView) {
        [indicatorView removeFromSuperview];
        [indicatorView release];
        indicatorView = nil;
    }
    
    if (response.code == ABResponseCodeHTTPSuccess && response.richContent) {
        [titleLabel setText:response.richTitle];
        
        if (!webView) {
            webView = [[UIWebView alloc] initWithFrame:CGRectMake(20, 90, 600, 758)];
            [webView setBackgroundColor:[UIColor clearColor]];
            [webView setDelegate:self];
            
            [self addSubview:webView];
        }
        
        [webView loadHTMLString:response.richContent baseURL:nil];
    }
}

#pragma mark - UIView lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 49, 600, 39)];
        titleLabel.font =[UIFont fontWithName:@"Helvetica-Bold" size:18];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(560, 4, 70, 70)];
        [closeButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AppBand.bundle/AppBandRichClose_iPad.png"]] forState:UIControlStateNormal];
        [closeButton setShowsTouchWhenHighlighted:YES];
        [closeButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:titleLabel];
        [self addSubview:closeButton];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicatorView setCenter:CGPointMake(342, 413)];
        [indicatorView startAnimating];
        
        [self addSubview:indicatorView];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AppBand.bundle/AppBandRichBackground_iPad.png"]] drawInRect:(CGRect){CGPointZero,rect.size}];
}

- (void)dealloc {
    [titleLabel release];
    [webView release];
    [indicatorView release];
    [super dealloc];
}


@end
