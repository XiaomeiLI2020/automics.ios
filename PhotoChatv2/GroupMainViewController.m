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
   
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    
    [self.createButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.createButton.layer.borderWidth=2.0f;
    self.createButton.clipsToBounds = YES;
    self.createButton.layer.cornerRadius = 10;//half of the width
    
    [self.joinGroup.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.joinGroup.layer.borderWidth=2.0f;
    self.joinGroup.clipsToBounds = YES;
    self.joinGroup.layer.cornerRadius = 10;//half of the width
    
    [self.leaveButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.leaveButton.layer.borderWidth=2.0f;
    self.leaveButton.clipsToBounds = YES;
    self.leaveButton.layer.cornerRadius = 10;//half of the width
    
    [self.inviteButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.inviteButton.layer.borderWidth=2.0f;
    self.inviteButton.clipsToBounds = YES;
    self.inviteButton.layer.cornerRadius = 10;//half of the width
    
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
        
        inviteButton.enabled = NO;
        inviteButton.alpha = 0.4;
        
        leaveButton.enabled = NO;
        leaveButton.alpha = 0.4;
        
        [joinGroup setTitle:@"Select Group" forState:UIControlStateNormal];
        
    }
    else{
        
        self.currentGroupLabel.text= [NSString stringWithFormat: @"Current group: %@", groupName];
        self.currentGroupLabel.numberOfLines = 0; //will wrap text in new line
        [self.currentGroupLabel sizeToFit];
        
        inviteButton.enabled = YES;
        inviteButton.alpha = 1;
        
        leaveButton.enabled = YES;
        leaveButton.alpha = 1;
        
        [joinGroup setTitle:@"Change Group" forState:UIControlStateNormal];
        

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
