//
//  AMIPadRegistrationView.h
//  AppMocha
//
//  Created by Jason Wang on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMIPadRegistrationViewDelegate;

@interface AMIPadRegistrationView : UIView <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
    IBOutlet id<AMIPadRegistrationViewDelegate> delegate;
    IBOutlet UITableView *registerTableView;
    
    UITextField *emailField;
    UITextField *passwordField;
    UITextField *checkField;
    UITextField *codeField;
}

@property(nonatomic,assign) IBOutlet id<AMIPadRegistrationViewDelegate> delegate;
@property(nonatomic,retain) IBOutlet UITableView *registerTableView;

- (IBAction)cancel:(id)sender;

- (IBAction)registration:(id)sender;

- (void)setBecomeFirstResponser;

@end

@protocol AMIPadRegistrationViewDelegate <NSObject>

- (void)registrationSuccess:(AMIPadRegistrationView *)reigsterView 
                      email:(NSString *)email 
                   password:(NSString *)password;

- (void)cancelledRegistrationView:(AMIPadRegistrationView *)reigsterView;

@end
