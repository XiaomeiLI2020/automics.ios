//
//  LoginViewController.h
//  SleepApp
//
//  Created by Duncan Rowland on 04/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *groupnameTextField;
//@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) NSString* token;

-(IBAction)loginPressed:(id)sender;

@end
