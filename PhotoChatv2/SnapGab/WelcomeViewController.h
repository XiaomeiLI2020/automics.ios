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
<GroupLoaderDelegate>

@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIButton *comicCollectionButton;

- (IBAction)logoutPressed:(id)sender;
- (IBAction)groupsPressed:(id)sender;


@end
