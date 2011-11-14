//
//  ABRichView.m
//  AppBand
//
//  Created by Jason Wang on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABRichView.h"

#import "AppBand.h"

@interface ABRichView()

- (void)cancel;

- (void)showRich:(ABRichResponse *)response;

@end

@implementation ABRichView

@synthesize rid = _rid;

#pragma mark - Public

- (void)setRichContent:(ABRichResponse *)response {
    [self performSelectorOnMainThread:@selector(showRich:) withObject:response waitUntilDone:YES];
}

- (void)showRich:(ABRichResponse *)response {
    [indicatorView removeFromSuperview];
    [indicatorView release];
    indicatorView = nil;
    
    if (response.code == ABResponseCodeSuccess && response.richContent) {
        [titleLabel setText:response.richTitle];
        
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44, 280, 336)];
        [webView setBackgroundColor:[UIColor clearColor]];
        [webView setDelegate:self];
        [webView loadHTMLString:response.richContent baseURL:nil];
        
        [self addSubview:webView];
    }
}

#pragma mark - Private

- (void)cancel {
    [[AppBand shared] cancelGetRichContent:self.rid];
    
    [UIView animateWithDuration:.3 animations:^{
        [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 animations:^{
            [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.2 animations:^{
                [self setTransform:CGAffineTransformScale(CGAffineTransformIdentity, .000001, .000001)];
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }];
    }];
}

#pragma mark - lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0. alpha:.6]];
        
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        [toolbar setBarStyle:UIBarStyleBlack];
        [toolbar setTranslucent:YES];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self   action:@selector(cancel)];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, toolbar.frame.size.width, toolbar.frame.size.height)];
        titleLabel.font =[UIFont fontWithName:@"Helvetica-Bold" size:18];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        // Just add UILabel like UIToolBar's subview 
        [toolbar addSubview:titleLabel];
        [toolbar setItems:[NSArray arrayWithObjects:spaceItem, cancelItem, nil]];
        
        [cancelItem release];
        [spaceItem release];
        
        [self addSubview:toolbar];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicatorView setCenter:CGPointMake(frame.size.width / 2, frame.size.height / 2)];
        [indicatorView startAnimating];
        
        [self addSubview:indicatorView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [toolbar release];
    [titleLabel release];
    [webView release];
    [indicatorView release];
    [self setRid:nil];
    [super dealloc];
}

@end
