//
//  GroupMainViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 28/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupLoader.h"
#import "UserLoader.h"

@interface GroupMainViewController : UIViewController <GroupLoaderDelegate, UserLoaderDelegate>

@property (weak, nonatomic) IBOutlet UILabel *groupsLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIButton *leaveButton;
@property (weak, nonatomic) IBOutlet UIButton *joinGroup;
@property (weak, nonatomic) IBOutlet UILabel *currentGroupLabel;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property GroupLoader* groupLoader;
@property UserLoader* userLoader;

@end
