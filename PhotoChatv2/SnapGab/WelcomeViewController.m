//
//  WelcomeViewController.m
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "WelcomeViewController.h"
#import "TextTableCell.h"
#import "DataLoader.h"
#import "User.h"

@interface WelcomeViewController ()
@end

GroupLoader* groupLoader;

@implementation WelcomeViewController
@synthesize imageButton;
@synthesize comicCollectionButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }//end if(self)
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    //Create databse for the app
    //dataLoader = [[DataLoader alloc] init];
    //[dataLoader submitSQLRequestCreateTablesForGroup:1];
    //[dataLoader submitSQLRequestCreateTablesForApp];
    /*
    groupLoader = [[GroupLoader alloc] init];
    groupLoader.delegate = self;
    */
    
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSString* groupHashId= [prefs objectForKey:@"current_group_hash"];
    //NSString* userId= [prefs objectForKey:@"user_id"];
    //NSLog(@"WelcomeViewController.viewDidLoad.groupHashId=%@", groupHashId);
    /*
    if(groupHashId==nil)
    {
        //NSLog(@"groupHashId=%@", groupHashId);
        imageButton.enabled = NO;
        imageButton.alpha = 0.4;
        
        comicCollectionButton.enabled = NO;
        comicCollectionButton.alpha = 0.4;
    }
    else{
        imageButton.enabled = YES;
        //imageButton.alpha = 0;
        
        comicCollectionButton.enabled = YES;
        //comicCollectionButton.alpha = 0;
    }
     */
    //NSString* sessionToken = [prefs objectForKey:@"user.currentGroup"];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* groupHashId= [prefs objectForKey:@"current_group_hash"];
    //NSString* userId= [prefs objectForKey:@"user_id"];
    //NSLog(@"WelcomeViewController.viewDidAppear.groupHashId=%@", groupHashId);
    if(groupHashId==nil)
    {
        //NSLog(@"groupHashId=%@", groupHashId);
        imageButton.enabled = NO;
        imageButton.alpha = 0.4;
        
        comicCollectionButton.enabled = NO;
        comicCollectionButton.alpha = 0.4;
    }
    else{
        imageButton.enabled = YES;
        //imageButton.alpha = 0;
        
        comicCollectionButton.enabled = YES;
        //comicCollectionButton.alpha = 0;
        
        //groupLoader = [[GroupLoader alloc] init];
        //[groupLoader submitRequestGetGroupForHashId:groupHashId];
    }
    
}

/*
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutPressed:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    
    //[self performSegueWithIdentifier:@"logout" sender:self];
    /*
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:@"session"];
    [userDefaults setObject:nil forKey:@"group"];
    [userDefaults setObject:nil forKey:@"user_id"];
    [userDefaults synchronize];
     */
 }

- (IBAction)groupsPressed:(id)sender {
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if([[segue identifier] isEqualToString:@"logout"])
    {
        //NSLog(@"Logout Called.");

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:nil forKey:@"session"];
        [userDefaults setObject:nil forKey:@"current_group_hash"];
        [userDefaults setObject:nil forKey:@"user_id"];
        [userDefaults synchronize];
    }//end if

}

/*
#pragma mark GroupLoader functions.
-(void)GroupLoader:(GroupLoader*)groupLoader didLoadGroup:(Group*)group{
    if(group!=nil)
    {
        [group]
    }//end if
}
*/

@end
