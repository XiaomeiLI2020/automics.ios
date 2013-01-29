//
//  GroupsViewController.m
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "GroupsViewController.h"

@interface GroupsViewController ()


@end

@implementation GroupsViewController
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

- (IBAction)logoutPressed:(id)sender {
    
    //[self performSegueWithIdentifier:@"logoutgroup" sender:self];
}

- (IBAction)snapPressed:(id)sender {
    
   //[self performSegueWithIdentifier:@"camview" sender:self];
}

- (IBAction)showPanel:(id)sender {
    
}


/*
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    if([[segue identifier] isEqualToString:@"startPanelView"]){

    }//end if
    
}
*/

@end
