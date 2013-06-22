//
//  LoginViewController.m
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "LoginViewController.h"
#import "APIWrapper.h"
#import "GroupLoader.h"


@interface LoginViewController ()
@end

@implementation LoginViewController
@synthesize sessionToken;
@synthesize userEmail;
@synthesize userPassword;
@synthesize userLoader;
@synthesize user;
@synthesize dataLoader;


//NSString* hashId=@"8fc8a0ed74ea82888c7a37b0f62a105b83d07a12";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    user = [[User alloc] init];
    userLoader = [[UserLoader alloc] init];
    userLoader.delegate = self;
    dataLoader = [[DataLoader alloc] init];

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


/*
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
        //user.groupHashId = hashId;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:nil forKey:@"current_group_hash"];
        [userDefaults setObject:user.email forKey:@"email"];
        [userDefaults setObject:user.password forKey:@"password"];
        [userDefaults synchronize];
    
        [userLoader submitRequestPostGenerateSessionToken:user];

    }//end if
}
*/
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
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {    // Or whatever orientation it will be presented in.
        return YES;
    }
    return NO;
}


/*
-(void)UserLoader:(UserLoader*)loader didGenerateSession:(Session*)session{
    
    //NSLog(@"Session token generated.");
    if(session!=nil)
    {
        NSLog(@"LoginViewController.didGenerateSession.session=%@", session.token);
        self.sessionToken = session.token;

        if(self.sessionToken!=nil)
        {
            user.currentSession = [[Session alloc] init];
            user.currentSession.token = self.sessionToken;
            
            user.userId = 3;
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:user.currentSession.token forKey:@"session"];
            [userDefaults setObject:[NSNumber numberWithInt:user.userId] forKey:@"user_id"];

            [userDefaults synchronize];
            
            //Generate a database for the user
            //[dataLoader submitSQLRequestCreateTablesForGroup:1];
            
            //Generate a database for the app
            [dataLoader submitSQLRequestCreateTablesForApp];
            
    
            
            [userLoader submitRequestGetUser:user.userId];
            
        }//end if(self.sessionToken!=nil)
    }//end if(session!=nil)
}

-(void)UserLoader:(UserLoader*)loader didLoadUser:(User*)currentUser{

    if(currentUser!=nil)
    {
        NSLog(@"currentUser.userId=%i", currentUser.userId);
        if(currentUser.currentGroup!=nil)
        {
            NSLog(@"currentUser.currentGroup.hashId=%@", currentUser.currentGroup.hashId);
            if(currentUser.currentGroup.hashId!=nil)
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:currentUser.currentGroup.hashId forKey:@"current_group_hash"];
                [userDefaults synchronize];
                
                GroupLoader* groupLoader = [[GroupLoader alloc] init];
                [groupLoader submitRequestGetGroupForHashId:currentUser.currentGroup.hashId];
                
            }
        }
    }
}
 */

/*
-(void)UserLoader:(UserLoader*)loader didJoinGroup:(User*)currentUser{
    
    //NSLog(@"Group join request approved.");
    if(currentUser!=nil)
    {
        user.userId = currentUser.userId;
        user.groupHashId = currentUser.groupHashId;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:user.currentSession.token forKey:@"session"];
        [userDefaults setObject:user.groupHashId forKey:@"group"];
        [userDefaults setObject:[NSNumber numberWithInt:user.userId] forKey:@"user_id"];
        [userDefaults synchronize];
        
        //NSLog(@"user.session=%@", user.currentSession.token);
        //NSLog(@"user.userId=%i", user.userId);
        //NSLog(@"user.group_hash=%@", user.groupHashId);
        //NSLog(@"user.email=%@", user.email);
    }
    
}

*/
/*
- (IBAction)registerPressed:(id)sender {
    
    userEmail = self.emailTextField.text;
    userPassword = self.passwordTextField.text;
    
    if(userEmail!=nil && ![userEmail isEqualToString:@""] && userPassword!=nil)
    {
        
        user.email = userEmail;
        user.password = userPassword;
        
        [userLoader submitRequestPostRegister:user];
    }
    
}
 */
- (IBAction)loginPressed:(id)sender {
    
    userEmail = self.emailTextField.text;
    userPassword = self.passwordTextField.text;
    
    if(userEmail!=nil)
        userEmail = @"urashid@lincoln.ac.uk";
    if(userPassword!=nil)
        userPassword = @"password";
    
    user.email = userEmail;
    user.password = userPassword;
    //user.groupHashId = hashId;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:@"current_group_hash"];
    [userDefaults setObject:user.email forKey:@"email"];
    [userDefaults setObject:user.password forKey:@"password"];
    [userDefaults synchronize];
    
    [userLoader submitRequestPostGenerateSessionToken:user];

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


-(void)UserLoader:(UserLoader*)loader didLoginUser:(User*)currentUser
{
    //NSLog(@"Session token generated.");
    if(currentUser!=nil)
    {
        user = currentUser;
        //NSLog(@"LoginViewController.didLoginUser.userId=%i", user.userId);
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:user.currentSession.token forKey:@"session"];
        [userDefaults setObject:[NSNumber numberWithInt:user.userId] forKey:@"user_id"];
        [userDefaults setObject:user.currentGroup.hashId forKey:@"current_group_hash"];
        [userDefaults synchronize];
        
        
        //Generate a database for the app
        [dataLoader submitSQLRequestCreateTablesForApp];
        
        //[userLoader submitRequestGetUser:user.userId];
        
        //Store current_group_hash into the app's database
        if(user.currentGroup.hashId!=nil)
        {
            GroupLoader* groupLoader = [[GroupLoader alloc] init];
            [groupLoader submitRequestGetGroupForHashId:currentUser.currentGroup.hashId];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
            [self presentViewController:viewController animated:YES completion:nil];
        }
    }//end if(user!=nil)
}



@end
