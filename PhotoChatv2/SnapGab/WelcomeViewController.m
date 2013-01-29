//
//  WelcomeViewController.m
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "WelcomeViewController.h"
#import "TextTableCell.h"

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
    [self getGroups];
    [self getOrganisations];

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
            
            NSString* hashid = [resource objectForKey:@"hashid"];
            NSString* groupName = [resource objectForKey:@"name"];
            self.groupLabel.text = groupName;
            //NSLog(@"hashid= %@", hashid);
            //NSLog(@"groupName= %@", groupName);
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
            NSString* organisationName = [resource objectForKey:@"name"];
            self.organisationLabel.text = organisationName;
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
            
            NSString* id = [resource objectForKey:@"id"];
            NSString* themeName = [resource objectForKey:@"name"];
            //NSLog(@"id= %@", id);
            //NSLog(@"themeName= %@", themeName);
            self.themeLabel.text = themeName;
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

@end
