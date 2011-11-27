//
//  ABPurchaseController.m
//  ABPush
//
//  Created by Jason Wang on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define AppBand_Demo_Download_Notification @"AppBand_Demo_Download_Notification_"

#import "ABPurchaseController.h"

#import "ABPurchaseDownloadController.h"

#import "AppBandKit.h"

@interface ABPurchaseController()

@property(nonatomic,copy) NSArray *products;

- (void)showMessage:(NSString *)message;

- (NSString *)getDocumentPath;

- (void)getProductsEnd:(ABProductsResponse *)response;

- (void)downloadProccess:(NSNotification *)notification;

@end

@implementation ABPurchaseController

@synthesize products = _products;

- (void)showMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Purchase" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertView show];
    
    [alertView release];
}

- (NSString *)getDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

- (void)getProductsEnd:(ABProductsResponse *)response {
    if (response.code == ABResponseCodeHTTPSuccess) {
        self.products = response.products;
        
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (void)downloadProccess:(NSNotification *)notification {
    ABPurchaseResponse *response = [notification object];
    switch (response.proccessStatus) {
        case ABPurchaseProccessStatusEnd: {
            switch (response.status) {
                case ABPurchaseStatusParametersUnavailable: {
                    [self showMessage:@"ABPurchaseStatusParametersUnavailable"];
                    break;
                }
                case ABPurchaseStatusPaymentClientInvalid: {
                    [self showMessage:@"ABPurchaseStatusPaymentClientInvalid"];
                    break;
                }
                case ABPurchaseStatusPaymentNotAllowed: {
                    [self showMessage:@"ABPurchaseStatusPaymentNotAllowed"];
                    break;
                }
                case ABPurchaseStatusPaymentCancelled: {
                    [self showMessage:@"ABPurchaseStatusPaymentCancelled"];
                    break;
                }
                case ABPurchaseStatusDeliverURLFailure: {
                    [self showMessage:@"ABPurchaseStatusDeliverURLFailure"];
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
                case ABPurchaseStatusDeliverBegan: {
                    [[NSNotificationCenter defaultCenter] removeObserver:self];
                    
                    ABPurchaseDownloadController *controller = [[ABPurchaseDownloadController alloc] init];
                    [controller setNKey:[NSString stringWithFormat:@"%@%@",AppBand_Demo_Download_Notification,response.productId]];
                    [self.navigationController pushViewController:controller animated:YES];
                    [controller release];
                    break;
                }
                default:
                    break;
            }
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ABProduct *product = [self.products objectAtIndex:indexPath.row];
    
    NSString *nKey = [NSString stringWithFormat:@"%@%@",AppBand_Demo_Download_Notification,product.productId];
    NSString *path = [self getDocumentPath];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProccess:) name:nKey object:nil];
    [[AppBand shared] purchaseProduct:product notificationKey:nKey path:path];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    ABProduct *product = [self.products objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:product.skProduct.localizedTitle];
    [cell.detailTextLabel setText:[product localizedPrice:product.skProduct]];
    
    return cell;
}

#pragma mark - UIViewController Lifecycle

- (void)dealloc {
    [self setProducts:nil];
    [_tableView release];
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
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.title = @"In-App Purchase";
    self.products = nil;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 387) style:UITableViewStylePlain];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    [self.view addSubview:_tableView];
    
    [[AppBand shared] getAppProductByGroup:nil target:self finfishSelector:@selector(getProductsEnd:)];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
