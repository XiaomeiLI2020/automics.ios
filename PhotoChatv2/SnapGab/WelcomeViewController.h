//
//  WelcomeViewController.h
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupLoader.h"

BOOL initialized = false;

@interface WelcomeViewController:UIViewController
<GroupLoaderDelegate, UIAlertViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *groupButton;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *comicCollectionButton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

- (IBAction)logoutPressed:(id)sender;
- (IBAction)groupsPressed:(id)sender;


@end
