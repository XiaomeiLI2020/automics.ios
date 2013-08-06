//
//  LoginViewController.m
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "LoginViewController.h"
#import "APIWrapper.h"
#import <QuartzCore/QuartzCore.h>


@interface LoginViewController ()
@end

@implementation LoginViewController
@synthesize sessionToken;
@synthesize userEmail;
@synthesize userPassword;
@synthesize userLoader;
@synthesize user;
@synthesize dataLoader;

@synthesize emailLabel;
@synthesize passwordLabel;
@synthesize loginButton;

//NSString* hashId=@"8fc8a0ed74ea82888c7a37b0f62a105b83d07a12";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    UIImageView *backgroundImage;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        //NSLog(@"This is iPhone 5");
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background@x5.png"]];
        [backgroundImage setFrame:CGRectMake(0, 0, 320, 568)];
    }
    else
    {
        //NSLog(@"This is iPhone 4");
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
        [backgroundImage setFrame:CGRectMake(0, 0, 320, 480)];
    }
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    
    [self.loginButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.loginButton.layer.borderWidth=4.0f;
    self.loginButton.clipsToBounds = YES;
    self.loginButton.layer.cornerRadius = 10;//half of the width
    [loginButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    loginButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    [self.emailLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    [self.passwordLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    
    user = [[User alloc] init];
    userLoader = [[UserLoader alloc] init];
    userLoader.delegate = self;
    dataLoader = [[DataLoader alloc] init];
    

    [dataLoader initiateSQL];
    int userId = [dataLoader submitSQLRequestCheckLoggedInUser];
    NSLog(@"LoginViewController.ViewDidLoad.userId=%i", userId);
    if(userId>0)
    {
        NSArray* users = [dataLoader convertUsersSQLIntoUsers:userId];
        if(users!=nil && [users count]>0)
        {
            User* currentUser = [users objectAtIndex:0];
            if(currentUser!=nil)
            {
                NSLog(@"LoginViewController..ViewDidLoad.user.currentGroup.hashId=%@", currentUser.currentGroup.hashId);
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:currentUser.email forKey:@"email"];
                [userDefaults setObject:currentUser.currentSession.token forKey:@"session"];
                [userDefaults setObject:[NSNumber numberWithInt:currentUser.userId] forKey:@"user_id"];
                [userDefaults setObject:currentUser.currentGroup.hashId forKey:@"current_group_hash"];
                [userDefaults synchronize];
                

                [userLoader submitRequestPostDeviceToken];
                
                //Store current_group_hash into the app's database
                if(currentUser.currentGroup.hashId!=nil)
                {
                    
                    GroupLoader* groupLoader = [[GroupLoader alloc] init];
                    groupLoader.delegate = self;
                    [groupLoader submitRequestGetGroupForHashId:currentUser.currentGroup.hashId];
                }
                

                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
                //[self presentViewController:viewController animated:YES completion:nil];
                [self.navigationController pushViewController:viewController animated:YES];
                
            }//end if(currentUser!=nil)
                        
            
            //[userLoader submitRequestPostDeviceToken];
            
            //Generate a database for the app
            //[dataLoader submitSQLRequestCreateTablesForApp];
            
            /*
            NSMutableArray* users = [[NSMutableArray alloc] init];
            [users addObject:user];
            [dataLoader submitSQLRequestSaveUsers:users];
            */
            
            //[userLoader submitRequestGetUser:user.userId];
            
            //user.currentGroup.hashId = @"8fc8a0ed74ea82888c7a37b0f62a105b83d07a12";
            //NSLog(@"LoginViewController.didLoginUser.user.currentGroup.hashId=%@", user.currentGroup.hashId);
            
            /*
            //Store current_group_hash into the app's database
            if(user.currentGroup.hashId!=nil)
            {
                GroupLoader* groupLoader = [[GroupLoader alloc] init];
                [groupLoader submitRequestGetGroupForHashId:currentUser.currentGroup.hashId];
            }
            */



        }//end if(users!=nil && [users count]>0)
    }//end if(userId>0)
    /*
    NSError* err;
    NSString *docsDir;
    NSArray *dirPaths;
    NSString* appName = [NSString stringWithFormat: @"automics.sql"];
    //databaseQueue = dispatch_queue_create("automics.database", NULL);
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    // Build the path to the database file
    NSString* databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:appName]];
    //NSLog(@"databasePath=%@, databasePathStatic=%@ ", databasePath, databasePathStatic);
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    BOOL fileExists = [fileMgr fileExistsAtPath:databasePath];
    NSLog(@"fileExists=%d", fileExists);
    
    if(fileExists)
    {
        int userId = [dataLoader submitSQLRequestCheckLoggedInUser];
        NSLog(@"userId=%i", userId);
        
    }//end if
    */
    
    /*
    if(fileExists)
    {
        [fileMgr removeItemAtPath:databasePath error:&err];
        if(err)
        {
            NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        }
        else
        {
            //NSLog(@"File %@ deleted.", appName);
        }
    }
*/
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
    //NSLog(@"login pressed");
    userEmail = self.emailTextField.text;
    userPassword = self.passwordTextField.text;
    
    /*
    if(userEmail!=nil)
        userEmail = @"urashid@lincoln.ac.uk";
    if(userPassword!=nil)
        userPassword = @"password";
    */
    
    if(userEmail!=nil && ![userEmail isEqualToString:@""]
       && userPassword!=nil && ![userPassword isEqualToString:@""])
    {
        user.email = userEmail;
        user.password = userPassword;
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:nil forKey:@"current_group_hash"];
        [userDefaults setObject:user.email forKey:@"email"];
        [userDefaults setObject:user.password forKey:@"password"];
        [userDefaults synchronize];
        
        [userLoader submitRequestPostGenerateSessionToken:user];

    }//end if(userEmail!=nil && userPassword!=nil)
   
}

#pragma mark UserLoader methods
-(void)UserLoader:(UserLoader*)loader didFailWithError:(NSError*)error{
    //NSLog(@"Group request failed.");
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Failed to log in:"
                          //message: [NSString stringWithFormat:@"%@", error]
                          message: @"Invalid password or email Id"
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
        
        
        [userLoader submitRequestPostDeviceToken];
        
        //Generate a database for the app
        [dataLoader submitSQLRequestCreateTablesForApp];
        
        NSMutableArray* users = [[NSMutableArray alloc] init];
        [users addObject:user];
        [dataLoader submitSQLRequestSaveUsers:users];
        
        //[userLoader submitRequestGetUser:user.userId];
        
        //user.currentGroup.hashId = @"8fc8a0ed74ea82888c7a37b0f62a105b83d07a12";
        //NSLog(@"LoginViewController.didLoginUser.user.currentGroup.hashId=%@", user.currentGroup.hashId);

        //Store current_group_hash into the app's database
        if(user.currentGroup.hashId!=nil)
        {
            
            GroupLoader* groupLoader = [[GroupLoader alloc] init];
            groupLoader.delegate = self;
            [groupLoader submitRequestGetGroupForHashId:currentUser.currentGroup.hashId];
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
        //[self presentViewController:viewController animated:YES completion:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }//end if(user!=nil)
}

#pragma mark GroupLoader methods
-(void)GroupLoader:(GroupLoader*)loader didLoadGroup:(Group *)group{
    if(group!=nil)
    {
        //NSLog(@"LoginViewController.group.name=%@, group.theme.themeId=%i", group.name, group.theme.themeId);
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:group.name forKey:@"current_group_name"];
        if(group.theme.themeId<1)
            [userDefaults setObject:[NSNumber numberWithInt:1] forKey:@"current_theme_id"];
        else
            [userDefaults setObject:[NSNumber numberWithInt:group.theme.themeId] forKey:@"current_theme_id"];
        [userDefaults synchronize];
    }
}

@end
