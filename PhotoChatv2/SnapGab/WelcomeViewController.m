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
#import "ResourceLoader.h"
#import "User.h"
#import <QuartzCore/QuartzCore.h>


@interface WelcomeViewController ()
@end

GroupLoader* groupLoader;


@implementation WelcomeViewController
@synthesize imageButton;
@synthesize comicCollectionButton;
@synthesize groupButton;
@synthesize logoutButton;
@synthesize logoImageView;
@synthesize organisationLoader;
@synthesize organisations;
@synthesize organisationCounter;

BOOL alertShown;

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
    
    NSLog(@"WelcomeViewController.viewDidLoad");
    organisationLoader = [[OrganisationLoader alloc] init];
    organisationLoader.delegate = self;
    [organisationLoader submitRequestGetOrganisations];
    organisationCounter = 0;
    organisations = [[NSArray alloc] init];

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
    
    //[self.view sendSubviewToBack:logoImageView];
    
    
    [self.logoutButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.logoutButton.layer.borderWidth=4.0f;
    self.logoutButton.clipsToBounds = YES;
    self.logoutButton.layer.cornerRadius = 10;//half of the width
    [self.view bringSubviewToFront:logoutButton];
    [logoutButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    logoutButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    imageButton.frame = CGRectMake(125.0, 150.0, 80.0, 80.0);
    imageButton.clipsToBounds = YES;
    imageButton.layer.cornerRadius = 40;//half of the width
    imageButton.layer.borderColor=[UIColor blackColor].CGColor;
    imageButton.layer.borderWidth=4.0f;
    [imageButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:26]];
    imageButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    

    comicCollectionButton.frame = CGRectMake(125.0, 240.0, 80.0, 80.0);
    comicCollectionButton.clipsToBounds = YES;
    comicCollectionButton.layer.cornerRadius = 40;//half of the width
    comicCollectionButton.layer.borderColor=[UIColor blackColor].CGColor;
    comicCollectionButton.layer.borderWidth=4.0f;
    [comicCollectionButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:26]];
    comicCollectionButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    groupButton.frame = CGRectMake(125.0, 330.0, 80.0, 80.0);
    groupButton.clipsToBounds = YES;
    groupButton.layer.cornerRadius = 40;//half of the width
    groupButton.layer.borderColor=[UIColor blackColor].CGColor;
    groupButton.layer.borderWidth=4.0f;
    [groupButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:26]];
    groupButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    alertShown = NO;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* email= [prefs objectForKey:@"email"];
    //NSString* groupHashId= [prefs objectForKey:@"current_group_hash"];

    
    self.welcomeLabel.text= [NSString stringWithFormat: @"Logged in as: %@", email];
    self.welcomeLabel.text=@"";
    self.welcomeLabel.numberOfLines = 0; //will wrap text in new line
    [self.welcomeLabel sizeToFit];
    [self.welcomeLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    
    
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
    NSLog(@"WelcomeViewController.viewDidAppear.groupHashId=%@", groupHashId);
    
    //welcomeLabel
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
        imageButton.alpha = 1;
        
        comicCollectionButton.enabled = YES;
        comicCollectionButton.alpha = 1;
        
        //groupLoader = [[GroupLoader alloc] init];
        //[groupLoader submitRequestGetGroupForHashId:groupHashId];
    }
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutPressed:(id)sender {
    //NSLog(@"logout pressed");
    
    if(!alertShown)
    {
        UIAlertView *message = [[UIAlertView alloc]
                                initWithTitle:@"Logout"
                                message:@"You are loging out of Trepic app."
                                delegate:self
                                cancelButtonTitle:@"Confirm"
                                otherButtonTitles:@"Cancel", nil];
        [message show];
        
    }//end if(!alertShown)
    
  
    
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

-(NSArray*)arrayByReplacingObject:(NSArray*)array andObjectIndex:(int)index andNewObject:(Organisation*)organisation
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray replaceObjectAtIndex:index withObject:organisation];
    //[newArray addObject:object];
    return [NSArray arrayWithArray:newArray];
}


/*
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
 */

/*
#pragma mark GroupLoader functions.
-(void)GroupLoader:(GroupLoader*)groupLoader didLoadGroup:(Group*)group{
    if(group!=nil)
    {
        [group]
    }//end if
}
*/

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Confirm"])
    {
        alertShown = NO;
        //NSLog(@"Confirm pressed");
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:nil forKey:@"session"];
        [userDefaults setObject:nil forKey:@"current_group_hash"];
        [userDefaults setObject:nil forKey:@"user_id"];
        [userDefaults setObject:nil forKey:@"current_theme_id"];  
        [userDefaults synchronize];
        
        //[ResourceLoader setResourcesDownloaded:NO];
        
        NSError *err;
        NSString *docsDir;
        NSArray *dirPaths;
        NSString* appName = [NSString stringWithFormat: @"automics.sql"];
        //databaseQueue = dispatch_queue_create("automics.database", NULL);
        
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = [dirPaths objectAtIndex:0];
        // Build the path to the database file
        NSString* databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:appName]];
        databasePathStatic = databasePath;
        //NSLog(@"databasePath=%@, databasePathStatic=%@ ", databasePath, databasePathStatic);
        NSFileManager *filemgr = [NSFileManager defaultManager];
        BOOL fileExists = [filemgr fileExistsAtPath:databasePath];
        //NSLog(@"WelcomeViewController.filexExists=%d", fileExists);
        if(fileExists)
        {
            [filemgr removeItemAtPath:databasePath error:&err];
            if(err)
            {
                NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
            }
            else
            {
                //NSLog(@"File %@ deleted.", appName);
            }

        }
        

        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        return;
    }//end if
    if([title isEqualToString:@"Cancel"])
    {
        alertShown = NO;
        NSLog(@"Cancel pressed");
        
        
        return;
    }//end if
}//end alertView

#pragma mark - OrganisationLoaderDelegate
-(void)OrganisationLoader:(OrganisationLoader*)organisationLoader didLoadOrganisations:(NSArray*)organisationsLocal{
    NSLog(@"WelcomeViewController.didLoadOrganisations.[organisations count]=%i", [organisationsLocal count]);
    self.organisations = organisationsLocal;

    Organisation* organisation = [self.organisations objectAtIndex:0];
    if(organisation!=nil)
    {
        //NSLog(@"organisation.organisationId=%i, name=%@", organisation.organisationId, organisation.name);
        if(organisation.organisationId>0)
        {
            //[self.organisationLoader submitRequestGetThemesForOrganisation:organisation.organisationId];
            [self.organisationLoader submitRequestGetOrganisation:organisation.organisationId];
        }
    }//end if(organisation!=nil)
}
-(void)OrganisationLoader:(OrganisationLoader*)organisationLoader didLoadOrganisation:(Organisation*)organisation{
    if(organisation!=nil)
    {
        self.organisations = [self arrayByReplacingObject:self.organisations andObjectIndex:organisationCounter andNewObject:organisation];
        NSLog(@"WelcomeViewController.didLoadOrganisation. id=%i, name=%@, [themes count]=%i", organisation.organisationId, organisation.name, [organisation.themes count]);
        /*
        if([organisation.themes count]>0)
        {
            for(int i=0; i<[organisation.themes count]; i++)
            {
                Theme* theme = [organisation.themes objectAtIndex:i];
                if(theme!=nil)
                {
                    NSLog(@"theme.name=%@, theme.id=%i", theme.name, theme.themeId);
                }
            }

        }
        */
        
        organisationCounter++;
        if(organisationCounter<[self.organisations count])
        {
            Organisation* organisation = [organisations objectAtIndex:organisationCounter];
            if(organisation!=nil)
            {
                //NSLog(@"organisation.organisationId=%i, name=%@", organisation.organisationId, organisation.name);
                if(organisation.organisationId>0)
                {
                    [self.organisationLoader submitRequestGetOrganisation:organisation.organisationId];
                }//end if
            }//end if(organisation!=nil)

        }//end if(organisationCounter<[self.organisations count])
        else if(organisationCounter==[self.organisations count])
        {
            //All organisations with themes downloaded
            [self.organisationLoader submitSQLRequestSaveOrganisations:self.organisations];
            
        }//end else
        
    }//end if(organisation!=nil)

}


@end
