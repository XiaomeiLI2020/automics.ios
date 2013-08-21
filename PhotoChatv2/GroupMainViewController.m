//
//  GroupMainViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 28/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "GroupMainViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GroupMainViewController ()

@end

@implementation GroupMainViewController

@synthesize createButton;
@synthesize joinGroup;
@synthesize inviteButton;
@synthesize leaveButton;
@synthesize currentGroupLabel;
@synthesize groupsLabel;
@synthesize menuButton;
@synthesize groupLoader;
@synthesize userLoader;

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
   
    //NSLog(@"GroupMainViewController.viewDidLoad");
    groupLoader = [[GroupLoader alloc] init];
    groupLoader.delegate = self;
    [groupLoader submitRequestRefreshGroups];
    
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
    
    [groupsLabel setFont:[UIFont fontWithName: @"Transit Display" size:24]];
    
    
    [menuButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    menuButton.layer.borderWidth=4.0f;
    menuButton.clipsToBounds = YES;
    menuButton.layer.cornerRadius = 10;//half of the width
    [menuButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    menuButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    [self.createButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.createButton.layer.borderWidth=4.0f;
    self.createButton.clipsToBounds = YES;
    self.createButton.layer.cornerRadius = 10;//half of the width
    [createButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    createButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    [self.joinGroup.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.joinGroup.layer.borderWidth=4.0f;
    self.joinGroup.clipsToBounds = YES;
    self.joinGroup.layer.cornerRadius = 10;//half of the width
    [joinGroup.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    joinGroup.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    [self.leaveButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.leaveButton.layer.borderWidth=4.0f;
    self.leaveButton.clipsToBounds = YES;
    self.leaveButton.layer.cornerRadius = 10;//half of the width
    [leaveButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    leaveButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    [self.inviteButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.inviteButton.layer.borderWidth=4.0f;
    self.inviteButton.clipsToBounds = YES;
    self.inviteButton.layer.cornerRadius = 10;//half of the width
    [inviteButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    inviteButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    /*
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* groupHashId= [prefs objectForKey:@"current_group_hash"];
    NSLog(@"GroupMainViewController.viewDidLoad.current_group_hash=%@", groupHashId);
    if(groupHashId==nil)
    {

        inviteButton.enabled = NO;
        inviteButton.alpha = 0.4;
        
        leaveButton.enabled = NO;
        leaveButton.alpha = 0.4;
        
        [joinGroup setTitle:@"Select Group" forState:UIControlStateNormal];

    }
    else{
        inviteButton.enabled = YES;
        inviteButton.alpha = 1;
        
        leaveButton.enabled = YES;
        leaveButton.alpha = 1;
        
        [joinGroup setTitle:@"Change Group" forState:UIControlStateNormal];
    }
     */
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* groupHashId= [prefs objectForKey:@"current_group_hash"];
    NSString* groupName= [prefs objectForKey:@"current_group_name"];
    NSLog(@"GroupMainViewController.viewWillAppear.current_group_hash=%@, current_group_name=%@", groupHashId, groupName);
    if(groupHashId==nil)
    {
        self.currentGroupLabel.text= @"";
        self.currentGroupLabel.numberOfLines = 0; //will wrap text in new line
        [self.currentGroupLabel sizeToFit];
        [self.currentGroupLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
        
        
        inviteButton.enabled = NO;
        inviteButton.alpha = 0.4;
        
        leaveButton.enabled = NO;
        leaveButton.alpha = 0.4;
        
        [joinGroup setTitle:@"Select Group" forState:UIControlStateNormal];
        
    }
    else if(groupHashId!=nil)
    {

        
        if(groupName!=nil)
        {
            self.currentGroupLabel.text= [NSString stringWithFormat: @"Current group: %@", groupName];
        }
        else
        {

            [groupLoader submitRequestGetGroupForHashId:groupHashId];
        }
        self.currentGroupLabel.numberOfLines = 0; //will wrap text in new line
        [self.currentGroupLabel sizeToFit];
        [self.currentGroupLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
        
        inviteButton.enabled = YES;
        inviteButton.alpha = 1;
        
        leaveButton.enabled = YES;
        leaveButton.alpha = 1;
        
        [joinGroup setTitle:@"Change Group" forState:UIControlStateNormal];
        

    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- GroupLoaderDelegate

-(void)GroupLoader:(GroupLoader *)groupLoader didLoadGroup:(Group*)group{
    if(group!=nil)
    {
        NSLog(@"GroupMainViewController.group.name=%@, group.theme.themeId=%i", group.name, group.theme.themeId);
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //NSString* currentGroupHash = [userDefaults objectForKey:@"current_group_hash"];
        //int userId = [[userDefaults objectForKey:@"user_id"] intValue];
        
        if(group.name!=nil)
        {
            self.currentGroupLabel.text= [NSString stringWithFormat: @"Current group: %@", group.name];
            [userDefaults setObject:group.name forKey:@"current_group_name"];
        }

        /*
        //[userDefaults setObject:[NSNumber numberWithInt:group.theme.themeId] forKey:@"current_theme_id"];
        if(group.theme.themeId<1)
            [userDefaults setObject:[NSNumber numberWithInt:1] forKey:@"current_theme_id"];
        else
            [userDefaults setObject:[NSNumber numberWithInt:group.theme.themeId] forKey:@"current_theme_id"];
        
        [userDefaults synchronize];
        
        userLoader = [[UserLoader alloc] init];
        userLoader.delegate = self;
        [userLoader submitSQLRequestUpdateCurrentGroup:currentGroupHash andUserId:userId];
         */
    }
}

-(void)GroupLoader:(GroupLoader*)groupLoader didLoadRefreshedGroups:(NSArray*)groups
{
    NSLog(@"GroupMainViewController. didLoadRefrehedGroups=%i", [groups count]);
}


@end
