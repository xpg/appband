//
//  AMIPadRegistrationView.m
//  AppMocha
//
//  Created by Jason Wang on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define AM_Registration_View_Email @"AM_Registration_View_Email"
#define AM_Registration_View_Password @"AM_Registration_View_Password"
#define AM_Registration_View_Check @"AM_Registration_View_Check"
#define AM_Registration_View_Code @"AM_Registration_View_Code"

#import "AMIPadRegistrationView.h"

#import "AppBandKit.h"
#import "xRestKit.h"

#import "AMAppDelegate.h"

#import "I18NController.h"

@interface AMIPadRegistrationView()

- (void)registration;

@end

@implementation AMIPadRegistrationView

@synthesize delegate;
@synthesize registerTableView;

#pragma mark - IBAction

- (IBAction)cancel:(id)sender {
    if (self.delegate) {
        [self.delegate cancelledRegistrationView:self];
    }
}

- (IBAction)registration:(id)sender {
    [self registration];
}

- (void)setBecomeFirstResponser {
    [emailField becomeFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *EmailCellIdentifier = @"EmailCellIdentifier";
    static NSString *PasswordCellIdentifier = @"PasswordCellIdentifier";
    static NSString *CheckCellIdentifier = @"CheckCellIdentifier";
    static NSString *CodeCellIdentifier = @"CodeCellIdentifier";
    UITableViewCell *cell = nil;
    
    switch (indexPath.row) {
        case 0: {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:EmailCellIdentifier] autorelease];
            [cell.textLabel setText:[[I18NController shareController] getLocalizedString:AM_Registration_View_Email comment:@"" locale:nil]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UITextField *field = [[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width * .4, cell.frame.size.height * .3, cell.frame.size.width * .58, cell.frame.size.height * .5)] autorelease];
            [field setBorderStyle:UITextBorderStyleNone];
            [field setTextAlignment:UITextAlignmentLeft];
            [field setReturnKeyType:UIReturnKeyDone];
            [field setBackgroundColor:[UIColor clearColor]];
            [field setTextColor:[UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1]];
            [field setDelegate:self];
            
            [cell insertSubview:field aboveSubview:cell.textLabel];
            emailField = field;
            
            break;
        }
        case 1:
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:PasswordCellIdentifier] autorelease];
            [cell.textLabel setText:[[I18NController shareController] getLocalizedString:AM_Registration_View_Password comment:@"" locale:nil]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UITextField *field = [[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width * .4, cell.frame.size.height * .3, cell.frame.size.width * .58, cell.frame.size.height * .5)] autorelease];
            [field setBorderStyle:UITextBorderStyleNone];
            [field setTextAlignment:UITextAlignmentLeft];
            [field setSecureTextEntry:YES];
            [field setReturnKeyType:UIReturnKeyDone];
            [field setBackgroundColor:[UIColor clearColor]];
            [field setTextColor:[UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1]];
            [field setDelegate:self];
            
            [cell insertSubview:field aboveSubview:cell.textLabel];
            passwordField = field;
            break;
        case 2: {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CheckCellIdentifier] autorelease];
            [cell.textLabel setText:[[I18NController shareController] getLocalizedString:AM_Registration_View_Check comment:@"" locale:nil]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UITextField *field = [[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width * .4, cell.frame.size.height * .3, cell.frame.size.width * .58, cell.frame.size.height * .5)] autorelease];
            [field setBorderStyle:UITextBorderStyleNone];
            [field setTextAlignment:UITextAlignmentLeft];
            [field setSecureTextEntry:YES];
            [field setReturnKeyType:UIReturnKeyDone];
            [field setBackgroundColor:[UIColor clearColor]];
            [field setTextColor:[UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1]];
            [field setDelegate:self];
            
            [cell insertSubview:field aboveSubview:cell.textLabel];
            checkField = field;
            break;
        }
        case 3: {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CodeCellIdentifier] autorelease];
            [cell.textLabel setText:[[I18NController shareController] getLocalizedString:AM_Registration_View_Code comment:@"" locale:nil]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UITextField *field = [[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width * .4, cell.frame.size.height * .3, cell.frame.size.width * .58, cell.frame.size.height * .5)] autorelease];
            [field setBorderStyle:UITextBorderStyleNone];
            [field setTextAlignment:UITextAlignmentLeft];
            [field setReturnKeyType:UIReturnKeyDone];
            [field setBackgroundColor:[UIColor clearColor]];
            [field setTextColor:[UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1]];
            [field setDelegate:self];
            
            [cell insertSubview:field aboveSubview:cell.textLabel];
            codeField = field;
            
            break;
        }
    }
    
    return cell;
}

#pragma mark - Private

- (void)registration {
    NSString *appKey = [[AppBand shared] appKey];
    NSString *appSecret = [[AppBand shared] appSecret];
    NSString *token = [(AMAppDelegate *)[UIApplication sharedApplication].delegate deviceToken];
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    NSString *email = @"jwang_test1@xtremeprog.com";
    NSString *password = @"go4xpg";
    NSDictionary *parameters = nil;
    if (!token || [token isEqualToString:@""]) {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:appKey, AppBand_App_Key, appSecret, AppBand_App_Secret, bundleId, AppBand_App_BundleId, email, AppBand_App_Email, password, AppBand_App_Password, nil];
    } else {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:appKey, AppBand_App_Key, appSecret, AppBand_App_Secret, bundleId, AppBand_App_BundleId, token, AppBand_App_token, email, AppBand_App_Email, password, AppBand_App_Password, nil];
    }
    
    NSString *url = [[[AppBand shared] server] stringByAppendingPathComponent:@"mobile_users"];
    
    [[xRestManager defaultManager] sendRequestTo:url parameter:parameters timeout:30. completion:^(xRestCompletionType type, NSString *response) {
        if (type == xRestCompletionTypeSuccess) {
            NSLog(@"Success");
        }
    }];
}

- (void)awakeFromNib {
    self.registerTableView.backgroundView = nil;
    self.registerTableView.backgroundView = [[[UIView alloc] init] autorelease];
    self.registerTableView.backgroundColor = [UIColor clearColor];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [self setRegisterTableView:nil];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
