//
//  ABPushController.m
//  ABPush
//
//  Created by Jason Wang on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABPushController.h"

#import "AppBandKit.h"

@implementation ABPushController

- (void)test {
    UIApplicationState appState = UIApplicationStateActive;
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(applicationState)]) {
        appState = [UIApplication sharedApplication].applicationState;
    }
    [[AppBand shared] handleNotification:[NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"Test Rich Notification", @"alert", [NSNumber numberWithInt:1], @"badge", nil], @"aps", [NSNumber numberWithInt:1], @"abpt", @"123", @"abri", nil] 
                        applicationState:appState 
                                  target:nil 
                            pushSelector:nil 
                            richSelector:nil];
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
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *test = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [test setFrame:CGRectMake(0, 0, 100, 50)];
    [test setCenter:CGPointMake(160, 215)];
    [test setTitle:@"test" forState:UIControlStateNormal];
    [test addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:test];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
