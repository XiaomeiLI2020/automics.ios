//
//  GroupAddViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 24/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "GroupAddViewController.h"
#import "ThemeViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GroupAddViewController ()

@end


@implementation GroupAddViewController

@synthesize groupName;
@synthesize groupLoader;
@synthesize cancelButton;
@synthesize selectThemeButton;
@synthesize groupsButton;
@synthesize groupNameLabel;
@synthesize typeGroupLabel;

BOOL alertShown;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    alertShown = NO;
    
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
    
    [self.groupsButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.groupsButton.layer.borderWidth=4.0f;
    self.groupsButton.clipsToBounds = YES;
    self.groupsButton.layer.cornerRadius = 10;//half of the width
    [self.groupsButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    groupsButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    [groupNameLabel setFont:[UIFont fontWithName: @"Transit Display" size:28]];
    [typeGroupLabel setFont:[UIFont fontWithName: @"Transit Display" size:28]];
    
    [self.cancelButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.cancelButton.layer.borderWidth=2.0f;
    self.cancelButton.clipsToBounds = YES;
    self.cancelButton.layer.cornerRadius = 10;//half of the width
    [self.cancelButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    cancelButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    [self.selectThemeButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.selectThemeButton.layer.borderWidth=2.0f;
    self.selectThemeButton.clipsToBounds = YES;
    self.selectThemeButton.layer.cornerRadius = 10;//half of the width
    [self.selectThemeButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    selectThemeButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    groupLoader = [[GroupLoader alloc] init];
    groupLoader.delegate=self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self setGroupTextField:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectTheme:(id)sender {
    
    groupName = self.groupTextField.text;
    if(groupName!=nil && ![groupName isEqualToString:@""])
    {

        //Create a new group
        Group* group = [[Group alloc] init];
        group.name = groupName;
        group.theme = [[Theme alloc] init];
        group.theme.themeId = 2;
        group.organisation = [[Organisation alloc] init];
        group.organisation.organisationId=1;
        [groupLoader submitRequestPostGroup:group];
        
        if(!alertShown)
        {
            
            if([groupLoader isReachable])
            {
                alertShown = YES;
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"Request Successful"
                                      message: [NSString stringWithFormat:@"Group %@ will be created soon", group.name]
                                      delegate: self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                
                
            }//end if([groupLoader isReachable])

            else if(![groupLoader isReachable])
            {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"Request Failed"
                                      message:@"Group created only when Internet is available"
                                      delegate: nil
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:nil];
                [alert show];
                
            }//end else if(![groupLoader isReachable])
        }

       
        
           

        
        /*
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        ThemeViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ThemeViewController"];
        //[self presentViewController:viewController animated:YES completion:nil];
        [self.navigationController pushViewController:viewController animated:YES];
         */
    }
}

- (IBAction)cancelPressed:(id)sender {

    self.groupTextField.text = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //NSLog(@"textFieldShouldReturn");
    if (theTextField == self.groupTextField) {
        [theTextField resignFirstResponder];
    }

    return YES;
}

/*
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if(groupName!=nil && ![groupName isEqualToString:@""])
    {
    if([[segue identifier] isEqualToString:@"selectTheme"])
    {

        groupName = self.groupTextField.text;
        if(groupName!=nil && ![groupName isEqualToString:@""])
        {
            Group* group = [[Group alloc] init];
            group.name = groupName;
            [groupLoader submitRequestPostGroup:group];
        }
        
    }//end if
    }
}
*/
#pragma mark - GroupLoaderDelegate
-(void)GroupLoader:(GroupLoader*)groupLoader didSaveGroup:(Group*)group{
    NSLog(@"GroupAddViewController.didSaveGroup. Group saved=%@ ", group.hashId);
    if(group!=nil)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:group.hashId forKey:@"new_group_hash"];
        [userDefaults synchronize];
        
        [self.groupLoader submitRequestPostMembershipForGroup:group];
        
    }
}

-(void)GroupLoader:(GroupLoader*)groupLoader didJoinGroup:(Group*)group{
    NSLog(@"GroupAddViewController.didJoinGroup.Became group member");
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        alertShown = NO;
        NSArray* viewControllers = self.navigationController.viewControllers;
        [self.navigationController popToViewController:[viewControllers objectAtIndex:1] animated:YES];
    }
}

@end
