//
//  GroupsFlowViewController.h
//  scaleView
//
//  Created by horizon on 22/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupLoader.h"
#import "PhotoLoader.h"

@interface GroupsFlowViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource,GroupLoaderDelegate, PhotoLoaderDelegate, ImageDownloaderDelegate, UIAlertViewDelegate>

@property IBOutlet UICollectionView *collectionView;
-(IBAction)backButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *groupsButton;
@property (weak, nonatomic) IBOutlet UILabel *inviteLabel;

@end

