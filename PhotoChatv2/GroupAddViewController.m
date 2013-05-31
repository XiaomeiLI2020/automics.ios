//
//  GroupAddViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 24/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "GroupAddViewController.h"

@interface GroupAddViewController ()

@end


@implementation GroupAddViewController

@synthesize groupName;
@synthesize groupLoader;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    
    if(groupName!=nil)
    {
        
        
    }
}

- (IBAction)cancelPressed:(id)sender {
    
    groupName = self.groupTextField.text;
    
    //if(groupName!=nil && ![groupName isEqualToString:@""])
    {
        
       //[self performSegueWithIdentifier:@"selectTheme" sender:self];
        
        //[[self navigationController] pushViewController:[self destinationViewController] animated:NO];
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //NSLog(@"textFieldShouldReturn");
    if (theTextField == self.groupTextField) {
        [theTextField resignFirstResponder];
    }

    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

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

#pragma mark - GroupLoaderDelegate
-(void)GroupLoader:(GroupLoader*)groupLoader didSaveGroup:(Group*)group{
    NSLog(@"Group saved=%@ ", group.hashId);
    if(group!=nil)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:group.hashId forKey:@"new_group_hash"];
        [userDefaults synchronize];
        
        [self.groupLoader submitRequestPostMembershipForGroup:group];
        
    }
}

-(void)GroupLoader:(GroupLoader*)groupLoader didJoinGroup:(Group*)group{
    NSLog(@"Became group member");
}
/*
 
 -(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
 
 
 if([[segue identifier] isEqualToString:@"editPanel"])
 {
 if([self.panels count]>0 && [self.panels count]>currentPage)
 {
 //NSLog(@"editPanel.currentPage=%i", currentPage);
 Panel *panel = [self.panels objectAtIndex:(currentPage)];
 if(panel!=nil)
 {
 PanelEditViewController *pevc = (PanelEditViewController *)[segue destinationViewController];
 
 
 */

@end
