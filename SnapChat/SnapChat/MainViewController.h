//
//  MainViewController.h
//  SnapChat
//
//  Created by Duncan Rowland on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property IBOutlet UITableView* photoTableView;

- (void)updateNumImages;

@end
