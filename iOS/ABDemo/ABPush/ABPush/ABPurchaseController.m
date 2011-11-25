//
//  ABPurchaseController.m
//  ABPush
//
//  Created by Jason Wang on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ABPurchaseController.h"

#import "AppBandKit.h"

@interface ABPurchaseController()

@property(nonatomic,copy) NSArray *products;

- (void)getProductsEnd:(ABProductsResponse *)response;

@end

@implementation ABPurchaseController

@synthesize products = _products;

- (void)getProductsEnd:(ABProductsResponse *)response {
    if (response.code == ABResponseCodeHTTPSuccess) {
        self.products = response.products;
        
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ABProduct *product = [self.products objectAtIndex:indexPath.row];
    [[AppBand shared] purchaseProduct:product 
                         statusTarget:nil 
                       statusSelector:nil 
                       proccessTarget:nil 
                     proccessSelector:nil];
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
