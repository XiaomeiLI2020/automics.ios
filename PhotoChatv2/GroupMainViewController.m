//
//  GroupMainViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 28/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "GroupMainViewController.h"

@interface GroupMainViewController ()

@end

@implementation GroupMainViewController

@synthesize joinGroup;
@synthesize inviteButton;
@synthesize leaveButton;

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
    NSLog(@"GroupMainViewController.viewWillAppear.current_group_hash=%@", groupHashId);
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
