//
//  ABPurchaseDownloadController.m
//  ABPush
//
//  Created by Jason Wang on 11/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABPurchaseDownloadController.h"

#import "AppBandKit.h"

@implementation ABPurchaseDownloadController

@synthesize nKey;

- (void)setProgress:(NSNumber *)progress {
    [progressView setProgress:[progress floatValue]];
}

- (void)showImage:(NSString *)filePath {
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    [imageView setImage:image];
}

- (void)showMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Purchase" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
    
    [alertView release];
}

- (void)downloadProgress:(NSNotification *)notification {
    ABPurchaseResponse *response = [notification object];
    switch (response.proccessStatus) {
        case ABPurchaseProccessStatusEnd: {
            switch (response.status) {
                case ABPurchaseStatusDeliverCancelled: {
                    [self showMessage:@"ABPurchaseStatusDeliverCancelled"];
                    break;
                }
                case ABPurchaseStatusDeliverFail: {
                    [self showMessage:@"ABPurchaseStatusDeliverFail"];
                    break;
                }
                case ABPurchaseStatusSuccess: {
                    [self performSelectorOnMainThread:@selector(showImage:) withObject:response.filePath waitUntilDone:YES];
                    break;
                }
                default:
                    [self showMessage:@"Unknown"];
                    break;
            }
            break;
        }
        case ABPurchaseProccessStatusDoing: {
            switch (response.status) {
                case ABPurchaseStatusDelivering: {
                    [self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:response.proccess] waitUntilDone:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
    }
}

- (void)dealloc {
    [imageView release];
    [progressView release];
    [self setNKey:nil];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 300)];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [progressView setProgress:0.];
    [progressView setCenter:CGPointMake(160, 340)];
    
    [self.view addSubview:imageView];
    [self.view addSubview:progressView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgress:) name:self.nKey object:nil];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:self.nKey object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
