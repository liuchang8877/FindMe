//
//  UserRegisterViewController.h
//  LBSFind
//
//  Created by liu on 4/15/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserRegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *anPwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
- (IBAction)onClickRegister:(id)sender;

@end
