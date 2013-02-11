//
//  LoginViewController.h
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
<UIScrollViewDelegate, UINavigationControllerDelegate>
- (IBAction)loginPressed:(id)sender;

@property (weak, nonatomic) NSString* token;

@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *password;

@property UIScrollView* scrollView;
@property BOOL keyboardIsShown;

@end
