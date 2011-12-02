//
//  AMIPadLoginView.m
//  AppMocha
//
//  Created by Jason Wang on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define AM_Login_View_Email @"AM_Login_View_Email"
#define AM_Login_View_Password @"AM_Login_View_Password"

#import "AMIPadLoginView.h"

#import "AppBandKit.h"
#import "xRestKit.h"

#import "AMAppDelegate.h"
#import "I18NController.h"

@interface AMIPadLoginView()

@property(nonatomic,copy) NSString *email;
@property(nonatomic,copy) NSString *password;

- (void)login;

@end

@implementation AMIPadLoginView

@synthesize email = _email;
@synthesize password = _password;

@synthesize delegate;
@synthesize lgoinTableView;

#pragma mark - IBAction

- (IBAction)cancel:(id)sender {
    if (self.delegate) {
        [self.delegate cancelledLoginView:self];
    }
}

- (IBAction)login:(id)sender {
    if (![(AMAppDelegate *)[UIApplication sharedApplication].delegate availableString:self.email] || ![(AMAppDelegate *)[UIApplication sharedApplication].delegate availableString:self.password]) return;
    
    [self login];
}

- (void)setBecomeFirstResponser {
    [emailField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == emailField) {
        self.email = textField.text;
    } else {
        self.password = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *EmailCellIdentifier = @"EmailCellIdentifier";
    static NSString *PasswordCellIdentifier = @"PasswordCellIdentifier";
    UITableViewCell *cell = nil;
    
    switch (indexPath.row) {
        case 0: {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:EmailCellIdentifier] autorelease];
            [cell.textLabel setText:[[I18NController shareController] getLocalizedString:AM_Login_View_Email comment:@"" locale:nil]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UITextField *field = [[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width * .4, cell.frame.size.height * .3, cell.frame.size.width * .58, cell.frame.size.height * .5)] autorelease];
            [field setBorderStyle:UITextBorderStyleNone];
            [field setTextAlignment:UITextAlignmentLeft];
            [field setReturnKeyType:UIReturnKeyDone];
            [field setBackgroundColor:[UIColor clearColor]];
            [field setTextColor:[UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1]];
            [field setDelegate:self];
            [field setText:self.email];
            
            [cell insertSubview:field aboveSubview:cell.textLabel];
            emailField = field;
            [emailField becomeFirstResponder];
            
            break;
        }
        case 1:
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:PasswordCellIdentifier] autorelease];
            [cell.textLabel setText:[[I18NController shareController] getLocalizedString:AM_Login_View_Password comment:@"" locale:nil]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UITextField *field = [[[UITextField alloc] initWithFrame:CGRectMake(cell.frame.size.width * .4, cell.frame.size.height * .3, cell.frame.size.width * .58, cell.frame.size.height * .5)] autorelease];
            [field setBorderStyle:UITextBorderStyleNone];
            [field setTextAlignment:UITextAlignmentLeft];
            [field setSecureTextEntry:YES];
            [field setReturnKeyType:UIReturnKeyDone];
            [field setBackgroundColor:[UIColor clearColor]];
            [field setTextColor:[UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1]];
            [field setDelegate:self];
            [field setText:self.password];
            
            [cell insertSubview:field aboveSubview:cell.textLabel];
            passwordField = field;
            break;
    }
    
    return cell;
}

#pragma mark - Private

- (void)login {
    NSString *appKey = [[AppBand shared] appKey];
    NSString *appSecret = [[AppBand shared] appSecret];
    NSString *token = [(AMAppDelegate *)[UIApplication sharedApplication].delegate deviceToken];
    NSString *bundleId = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    NSDictionary *parameters = nil;
    if (!token || [token isEqualToString:@""]) {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:appKey, AppBand_App_Key, appSecret, AppBand_App_Secret, bundleId, AppBand_App_BundleId, self.email, AppBand_App_Email, self.password, AppBand_App_Password, nil];
    } else {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:appKey, AppBand_App_Key, appSecret, AppBand_App_Secret, bundleId, AppBand_App_BundleId, token, AppBand_App_token, self.email, AppBand_App_Email, self.password, AppBand_App_Password, nil];
    }
    
    NSString *url = [[[AppBand shared] server] stringByAppendingPathComponent:@"mobile_users/verify"];
    
    [[xRestManager defaultManager] sendRequestTo:url parameter:parameters timeout:30. completion:^(xRestCompletionType type, NSString *response) {
        if (type == xRestCompletionTypeSuccess) {
            if (self.delegate) {
                [self.delegate loginSuccess:self email:self.email password:self.password];
            }
        }
    }];
}

- (void)awakeFromNib {
    self.lgoinTableView.backgroundView = nil;
    self.lgoinTableView.backgroundView = [[[UIView alloc] init] autorelease];
    self.lgoinTableView.backgroundColor = [UIColor clearColor];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.email = @"jwang_test1@xtremeprog.com";
        self.password = @"go4xpg";
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
    [self setLgoinTableView:nil];
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
