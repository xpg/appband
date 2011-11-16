//
//  ABRichView.m
//  AppBand
//
//  Created by Jason Wang on 11/11/11.
//  Copyright (c) 2011 XPG. All rights reserved.
//

#import "ABRichView.h"

#import "AppBand.h"

@interface ABRichView()

- (void)cancel;

- (void)showRich:(ABRichResponse *)response;

@end

@implementation ABRichView

@synthesize delegate;
@synthesize rid = _rid;

#pragma mark - Public

- (void)setRichContent:(ABRichResponse *)response {
    [self performSelectorOnMainThread:@selector(showRich:) withObject:response waitUntilDone:YES];
}

- (void)showRich:(ABRichResponse *)response {
    if (indicatorView) {
        [indicatorView removeFromSuperview];
        [indicatorView release];
        indicatorView = nil;
    }
    
    if (response.code == ABResponseCodeSuccess && response.richContent) {
        [titleLabel setText:response.richTitle];
        
        if (!webView) {
            webView = [[UIWebView alloc] initWithFrame:CGRectMake(7.5, 51.5, 265, 321)];
            [webView setBackgroundColor:[UIColor clearColor]];
            [webView setDelegate:self];
            
            [self addSubview:webView];
        }
        
        [webView loadHTMLString:response.richContent baseURL:nil];
    }
}

#pragma mark - Private

- (void)cancel {
    [[AppBand shared] cancelGetRichContent:self.rid];
    if (self.delegate) {
        [self.delegate cancelRichView:self];
    }
}

#pragma mark - lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIImage *icon = [UIImage imageNamed:@"AppBandIcon"];
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 17, 25, 25)];
        [iconView setImage:icon];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.5, 7.5, 265, 44)];
        titleLabel.font =[UIFont fontWithName:@"Helvetica-Bold" size:18];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(227.5, 7.5, 35, 44)];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"AppBandRichClose"] forState:UIControlStateNormal];
        [closeButton setShowsTouchWhenHighlighted:YES];
        [closeButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:iconView];
        [self addSubview:titleLabel];
        [self addSubview:closeButton];
        
        [iconView release];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView setCenter:CGPointMake(frame.size.width / 2, frame.size.height / 2)];
        [indicatorView startAnimating];
        
        [self addSubview:indicatorView];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [[UIImage imageNamed:@"AppBandRichBackground"] drawInRect:(CGRect){CGPointZero,rect.size}];
}

- (void)dealloc {
    [toolbar release];
    [titleLabel release];
    [webView release];
    [indicatorView release];
    [self setRid:nil];
    [super dealloc];
}

@end
