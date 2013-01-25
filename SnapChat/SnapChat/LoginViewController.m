//
//  LoginViewController.m
//  SleepApp
//
//  Created by Duncan Rowland on 04/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize groupnameTextField;
//@synthesize passwordTextField;
@synthesize token;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    groupnameTextField.text = [prefs objectForKey:@"groupname"];
//    passwordTextField.text = [prefs objectForKey:@"password"];
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if( textField == groupnameTextField )
//        [passwordTextField becomeFirstResponder];
//    else
//    {
//        [textField resignFirstResponder];
//    }
//    return NO;
//}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
 
-(void)loginPressed:(id)sender
{
    NSString* groupname = groupnameTextField.text;
    if(groupname.length==0) return;
//    NSString* password = passwordTextField.text;    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    token = [prefs objectForKey:@"token"];
    if(token==nil)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Failed to get token"
                              message: @"Please restart the app"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    

    NSString* urlString = [NSString stringWithFormat:@"http://www.automics.net/automics/register.php?group_name=%@&token=%@",groupname,token];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] 
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if(requestError)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Failed to register, error:"
                          message: [NSString stringWithFormat:@"%@", requestError]
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    } else {
    
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];    
        [prefs setObject:groupname forKey:@"groupname"];
//      [prefs setObject:password forKey:@"password"];
        [prefs synchronize];

    [self performSegueWithIdentifier:@"login" sender:self];
    }
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"login"]) {
//        ((MainViewController *)(segue.destinationViewController)).config = config;
//    }
//}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
