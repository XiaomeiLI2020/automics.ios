//
//  WelcomeViewController.h
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupLoader.h"
#import "OrganisationLoader.h"

BOOL initialized = false;

@interface WelcomeViewController:UIViewController
<GroupLoaderDelegate, UIAlertViewDelegate, OrganisationLoaderDelegate>


@property (weak, nonatomic) IBOutlet UIButton *groupButton;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *comicCollectionButton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property OrganisationLoader* organisationLoader;
@property NSArray* organisations;
@property int organisationCounter;

- (IBAction)logoutPressed:(id)sender;
- (IBAction)groupsPressed:(id)sender;


@end
