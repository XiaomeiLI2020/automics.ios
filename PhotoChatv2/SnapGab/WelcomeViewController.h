//
//  WelcomeViewController.h
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

{
    NSArray *groupNames;
    NSArray *organisationNames;
    NSArray *themeNames;
}

@property IBOutlet UITableView *groupTableView;
@property IBOutlet UITableView *organisationTableView;
@property IBOutlet UITableView *themeTableView;

@property IBOutlet UILabel *groupLabel;
@property IBOutlet UILabel *organisationLabel;
@property IBOutlet UILabel *themeLabel;

@property (strong, nonatomic) NSArray *groupNames;
@property (strong, nonatomic) NSArray *organisationNames;
@property (strong, nonatomic) NSArray *themeNames;

@property NSString *groupName;
@property NSString *organisationName;
@property NSString *themeName;


- (IBAction)logoutPressed:(id)sender;
- (IBAction)makeGroup:(id)sender;

@end
