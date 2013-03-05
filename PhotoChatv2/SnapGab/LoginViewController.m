//
//  LoginViewController.m
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "LoginViewController.h"
#import "APIWrapper.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize sessionToken;
@synthesize userEmail;
@synthesize userPassword;

@synthesize userLoader;
@synthesize user;

NSString* hashId=@"8fc8a0ed74ea82888c7a37b0f62a105b83d07a12";


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    userLoader = [[UserLoader alloc] init];
    userLoader.delegate = self;
    
    user = [[User alloc] init];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    
}

- (void)dealloc {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"login"])
    {
        userEmail = self.emailTextField.text;
        userPassword = self.passwordTextField.text;
        
        if(userEmail!=nil)
            userEmail = @"urashid@lincoln.ac.uk";
        if(userPassword!=nil)
            userPassword = @"password";
        
        user.email = userEmail;
        user.password = userPassword;
        user.groupHashId = hashId;
    
        [userLoader submitRequestPostGenerateSessionToken:user];

    }//end if
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //NSLog(@"textFieldShouldReturn");
    if (theTextField == self.emailTextField) {
        [theTextField resignFirstResponder];
    }

    if (theTextField == self.passwordTextField) {
        [theTextField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark UserLoader methods
-(void)UserLoader:(UserLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"Group request failed.");
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Failed to register, error:"
                          message: [NSString stringWithFormat:@"%@", error]
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}


-(void)UserLoader:(UserLoader*)loader didGenerateSession:(Session*)session{
    
    //NSLog(@"Session token generated.");
    if(session!=nil)
    {
        //NSLog(@"session=%@", session.token);
        self.sessionToken = session.token;

        if(self.sessionToken!=nil)
        {
            user.currentSession = [[Session alloc] init];
            user.currentSession.token = self.sessionToken;
            [userLoader submitRequestPostJoinGroup:sessionToken andGroupHashId:hashId];
        }
    }
}

-(void)UserLoader:(UserLoader*)loader didJoinGroup:(User*)currentUser{
    
    //NSLog(@"Group join request approved.");
    if(currentUser!=nil)
    {
        user.userId = currentUser.userId;
        user.groupHashId = currentUser.groupHashId;
        /*
        NSLog(@"user.userId=%i", user.userId);
        NSLog(@"user.group_hash=%@", user.groupHashId);
        NSLog(@"user.session=%@", user.currentSession.token);
        NSLog(@"user.email=%@", user.email);
         */
    }
    
}


@end
