//
//  GroupJoinViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 28/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupLoader.h"
#import "PhotoLoader.h"
#import "UserLoader.h"


@interface GroupJoinViewController : UIViewController
<UICollectionViewDelegate, UICollectionViewDataSource, GroupLoaderDelegate, PhotoLoaderDelegate, ImageDownloaderDelegate, UIAlertViewDelegate, UserLoaderDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property UserLoader* userLoader;
@property (weak, nonatomic) IBOutlet UIButton *groupsButton;
@property (weak, nonatomic) IBOutlet UILabel *selectGroupLabel;

@end
