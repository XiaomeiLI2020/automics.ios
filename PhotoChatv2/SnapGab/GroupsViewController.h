//
//  GroupsViewController.h
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupsViewController : UIViewController
- (IBAction)logoutPressed:(id)sender;
- (IBAction)snapPressed:(id)sender;
- (IBAction)showPanel:(id)sender;



@property (weak, nonatomic) NSString* token;
@end
