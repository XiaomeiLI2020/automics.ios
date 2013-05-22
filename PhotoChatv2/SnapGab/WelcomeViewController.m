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
    dataLoader = [[DataLoader alloc] init];
    groupLoader = [[GroupLoader alloc] init];
    groupLoader.delegate = self;
    [groupLoader submitRequestGetGroups];
    
    //sQLiteLoader = [[SQLiteLoader alloc] init];
    //[self getGroups];
    //[self getOrganisations];
   // [self getResources];

}



- (void)getGroups
{
    NSString* urlResourceString = [NSString stringWithFormat:@"http://automicsapi.wp.horizon.ac.uk/v1/group"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlResourceString]
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    if(response)
    {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&parseError];
        for(NSDictionary* resource in jsonObject)
        {
            
            //NSString* hashid = [resource objectForKey:@"hashid"];
            NSString* groupName1 = [resource objectForKey:@"name"];
            //int groupId = [[resource objectForKey:@"id"] integerValue];
            self.groupLabel.text = groupName1;
            
            //NSLog(@"hashid= %@", hashid);
            //NSLog(@"groupName= %@", groupName);
            //NSLog(@"groupId= %i", groupId);
        }//end for
        
    }//end if
}

- (void)getOrganisations
{
    NSString* urlResourceString = [NSString stringWithFormat:@"http://automicsapi.wp.horizon.ac.uk/v1/organisation"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlResourceString]
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    if(response)
    {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&parseError];
        for(NSDictionary* resource in jsonObject)
        {
            
            NSString* id = [resource objectForKey:@"id"];
            NSString* organisation = [resource objectForKey:@"name"];
            self.organisationLabel.text = organisation;
            //NSLog(@"id= %@", id);
            //NSLog(@"organisationName= %@", organisationName);
            [self getThemesOfOrganisation:id];
        }//end for
        
    }//end if
}

- (void)getThemesOfOrganisation:(id)organisationId
{
    NSString* urlResourceString = [NSString stringWithFormat:@"http://automicsapi.wp.horizon.ac.uk/v1/organisation/%@/theme", organisationId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlResourceString]
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    if(response)
    {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&parseError];
        for(NSDictionary* resource in jsonObject)
        {
            
            //NSString* id = [resource objectForKey:@"id"];
            NSString* themeName1 = [resource objectForKey:@"name"];
            //NSLog(@"id= %@", id);
            //NSLog(@"themeName= %@", themeName);
            self.themeLabel.text = themeName1;
        }//end for
        
    }//end if
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutPressed:(id)sender {
    //[self performSegueWithIdentifier:@"logout" sender:self];
 }

- (IBAction)makeGroup:(id)sender {
    
    //[self performSegueWithIdentifier:@"creategroup" sender:self];
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
