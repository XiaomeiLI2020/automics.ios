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

/*
@interface GroupsFlowViewController : UICollectionViewController<GroupLoaderDelegate, PhotoLoaderDelegate, ImageDownloaderDelegate>

@end
 */

@interface GroupsFlowViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource,GroupLoaderDelegate, PhotoLoaderDelegate, ImageDownloaderDelegate>

@property IBOutlet UICollectionView *collectionView;
-(IBAction)backButtonClick:(id)sender;

@end

