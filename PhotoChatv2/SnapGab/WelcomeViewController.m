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

@implementation WelcomeViewController

@synthesize groupNames;
@synthesize organisationNames;
@synthesize themeNames;

@synthesize groupName;
@synthesize organisationName;
@synthesize themeName;

@synthesize groupTableView;
@synthesize organisationTableView;
@synthesize themeTableView;
@synthesize groupLoader;

@synthesize imageButton;
@synthesize comicButton;
@synthesize comicCollectionButton;

DataLoader* dataLoader;


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
    dataLoader = [[DataLoader alloc] init];
    [dataLoader submitSQLRequestCreateTablesForGroup:1];
    //[dataLoader submitSQLRequestCreateTablesForApp];
    /*
    groupLoader = [[GroupLoader alloc] init];
    groupLoader.delegate = self;
    */
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* groupHashId= [prefs objectForKey:@"current_group_hash"];
    //NSString* userId= [prefs objectForKey:@"user_id"];
    //NSLog(@"WelcomeViewController.groupHashId=%@, userId=%@", groupHashId, userId);
    if(groupHashId==nil)
    {
        //NSLog(@"groupHashId=%@", groupHashId);
        imageButton.enabled = NO;
        imageButton.alpha = 0.4;
        
        comicButton.enabled = NO;
        comicButton.alpha = 0.4;
        
        comicCollectionButton.enabled = NO;
        comicCollectionButton.alpha = 0.4;
    }
    else{
        imageButton.enabled = YES;
        //imageButton.alpha = 0;
        
        comicButton.enabled = YES;
        //comicButton.alpha = 0;
        
        comicCollectionButton.enabled = YES;
        //comicCollectionButton.alpha = 0;
    }
    //NSString* sessionToken = [prefs objectForKey:@"user.currentGroup"];
    //[groupLoader submitRequestGetGroups];
    //sQLiteLoader = [[SQLiteLoader alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutPressed:(id)sender {
    //[self performSegueWithIdentifier:@"logout" sender:self];
    /*
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:@"session"];
    [userDefaults setObject:nil forKey:@"group"];
    [userDefaults setObject:nil forKey:@"user_id"];
    [userDefaults synchronize];
     */
 }

- (IBAction)makeGroup:(id)sender {
    
    //[self performSegueWithIdentifier:@"creategroup" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"logout"])
    {
        NSLog(@"Logout Called.");

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:nil forKey:@"session"];
        [userDefaults setObject:nil forKey:@"current_group_hash"];
        [userDefaults setObject:nil forKey:@"user_id"];
        [userDefaults synchronize];
    }//end if
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"groupTableCell";
    
    TextTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[TextTableCell alloc] initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.label.text = [self.groupNames objectAtIndex: [indexPath row]];
    
    return cell;
}


#pragma mark GroupLoader functions.
-(void)GroupLoader:(GroupLoader*)groupLoader didLoadGroups:(NSArray*)groups{
    if(groups!=nil)
    {
        Group* group = [groups objectAtIndex:0];
        if(group!=nil)
        {
            //NSLog(@"group.name=%@", group.name);
            //NSLog(@"group.groupId=%i", group.groupId);
            //NSLog(@"initialized before=%d", initialized);
            if(!initialized)
            {
                [dataLoader submitSQLRequestCreateTablesForGroup:group.groupId];
                initialized = YES;
            }
            //NSLog(@"initialized after=%d", initialized);
        }
    }
}
-(void)GroupLoader:(GroupLoader*)groupLoader didFailWithError:(NSError*)errors{
    NSLog(@"Groups failed to load");
}

@end
