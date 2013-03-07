//
//  LoginViewController.h
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupLoader.h"
#import "UserLoader.h"
#import "User.h"

@interface LoginViewController : UIViewController
<UITextFieldDelegate, UserLoaderDelegate>

@property NSString* sessionToken;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property NSString *userEmail;
@property NSString *userPassword;


@property UserLoader* userLoader;
@property User* user;

@end
