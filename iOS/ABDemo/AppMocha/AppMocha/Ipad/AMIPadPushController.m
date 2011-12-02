//
//  AMIPadPushController.m
//  AppMocha
//
//  Created by Jason Wang on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AMIPadPushController.h"

#import "AMModelConstant.h"

@interface AMIPadPushController()

@property(nonatomic,copy) NSArray *pushArray;

- (void)didReceiveNotification:(NSNotification *)notification;

@end

@implementation AMIPadPushController

@synthesize pushArray = _pushArray;

@synthesize pushTableView;

#pragma mark - Private

- (void)didReceiveNotification:(NSNotification *)notification {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    AMNotification *amn = notification.object;
    NSMutableArray *temp = [NSMutableArray arrayWithObjects:amn, nil];
    [temp addObjectsFromArray:self.pushArray];
    
    self.pushArray = [NSArray arrayWithArray:temp];
    
    [self.pushTableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];
    
    [pool drain];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pushArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    AMNotification *notification = [self.pushArray objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:notification.message];
    
    return cell;
}

#pragma mark - UIViewController lifecycle

- (void)dealloc {
    [self setPushArray:nil];
    [self setPushTableView:nil];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dataController = [[CoreDataManager defaultManager] fetchCDController:DEMO_STORE_NAME];
        
        self.pushArray = [dataController getModel:AMNotification_Class predicate:nil sortBy:@"date" isAscending:NO];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:AppMocha_Demo_Notificaion_Receive_Key object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

@end
