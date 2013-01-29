//
//  LoginViewController.m
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginPressed:(id)sender {
    
    NSString* groupname = @"umartest";
    if(groupname.length==0) groupname=@"umartest"; //return;
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
    
    //NSString* urlString = [NSString stringWithFormat:@"http://www.automics.net/automics/register.php?group_name=%@",groupname];
    
    
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
        
        //NSLog(@"main view opened");
        //[self performSegueWithIdentifier:@"showpanels" sender:self];
        
    }

    
    //[self performSegueWithIdentifier:@"login" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    /*
    if([[segue identifier] isEqualToString:@"login"]){

    }//end if
     */
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
