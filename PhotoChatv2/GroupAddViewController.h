//
//  GroupAddViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 24/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupLoader.h"

@interface GroupAddViewController : UIViewController
<UITextFieldDelegate, GroupLoaderDelegate>

@property (weak, nonatomic) IBOutlet UITextField *groupTextField;
@property NSString* groupName;
@property GroupLoader* groupLoader;

- (IBAction)selectTheme:(id)sender;
- (IBAction)cancelPressed:(id)sender;

@end
