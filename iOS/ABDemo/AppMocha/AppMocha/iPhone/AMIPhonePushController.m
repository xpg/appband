//
//  AMIPhonePushController.m
//  AppMocha
//
//  Created by Jason Wang on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define App_Receive_Push @"App_Receive_Push"

#import "AMIPhonePushController.h"

#import "AMModelConstant.h"
#import "I18NController.h"

#import "AMIPhonePushCell.h"

@interface AMIPhonePushController()

@property(nonatomic,copy) NSArray *pushArray;

- (void)controllerDidReceiveNotification:(NSNotification *)notification;

- (void)showRichView:(AMNotification *)notification;

@end

@implementation AMIPhonePushController

@synthesize pushArray = _pushArray;

@synthesize pushTableView;

#pragma mark - Private

- (void)controllerDidReceiveNotification:(NSNotification *)notification {
    NSLog(@"controllerDidReceiveNotification");
    AMNotification *amn = notification.object;
    UIApplicationState state = [[[notification userInfo] objectForKey:AppBand_App_Push_State] intValue];
    NSMutableArray *temp = [NSMutableArray arrayWithObjects:amn, nil];
    [temp addObjectsFromArray:self.pushArray];
    
    self.pushArray = [NSArray arrayWithArray:temp];
    
    [self.pushTableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];
    
    
    if (state == UIApplicationStateActive) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[I18NController shareController] getLocalizedString:App_Receive_Push comment:@"" locale:nil] message:amn.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    } else {
        if ([amn.type intValue] == 1) {
            [self showRichView:amn];
        }
    }
}

- (void)showRichView:(AMNotification *)notification {
    if (richView) {
        if (richView.notification) {
            [richView setTarget:notification];
        } else {
            [richView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, .000001, .000001)];
            
            [self.view addSubview:richView];
            
            [UIView animateWithDuration:.2 animations:^{
                [richView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.15 animations:^{
                    [richView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, .9, .9)];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:.15 animations:^{
                        [richView setTransform:CGAffineTransformIdentity];
                    } completion:^(BOOL finished) {
                        [richView setTarget:notification];
                    }];
                }];
            }];
        }
    }
}

#pragma mark - AMIPhoneRichViewDelegate

- (void)richViewClosed:(AMIPhoneRichView *)rView {
    if (richView) {
        [UIView animateWithDuration:.2 animations:^{
            [richView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.15 animations:^{
                [richView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.15 animations:^{
                    [richView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, .000001, .000001)];
                } completion:^(BOOL finished) {
                    [richView removeFromSuperview];
                }];
            }];
        }];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AMNotification *notification = [self.pushArray objectAtIndex:indexPath.row];
    
    if ([notification.type intValue] == 0) return;
    
    [self showRichView:notification];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pushArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AMIPhonePushCell";
    AMIPhonePushCell *cell = (AMIPhonePushCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        [[NSBundle mainBundle] loadNibNamed:@"AMIPhonePushCell" owner:self options:NULL];
        cell = pushCell;
    }
    
    AMNotification *notification = [self.pushArray objectAtIndex:indexPath.row];
    
    [cell setNotification:notification];
    
    return cell;
}

#pragma mark - UIViewController lifecycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AppMocha_Demo_Notificaion_Receive_Key object:nil];
    [self setPushArray:nil];
    [self setPushTableView:nil];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dataController = [[CoreDataManager defaultManager] fetchCDController:DEMO_STORE_NAME];
        self.pushArray = [dataController getModel:AMNotification_Class predicate:nil sortBy:@"date" isAscending:NO];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AppMocha_Demo_Notificaion_Receive_Key object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDidReceiveNotification:) name:AppMocha_Demo_Notificaion_Receive_Key object:nil];
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
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

@end
