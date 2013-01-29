//
//  PanelViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 11/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PanelViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

//@property IBOutlet UITableView *photoTableView;

@property IBOutlet UITableView *photoTableView;
- (IBAction)closePressed:(id)sender;


- (void)updateNumImages;

@end
