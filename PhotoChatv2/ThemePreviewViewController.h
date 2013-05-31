//
//  ThemePreviewViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 30/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrganisationLoader.h"
#import "ResourceLoader.h"
#import "GroupLoader.h"
#import "PhotoLoader.h"
#import "UserLoader.h"

@interface ThemePreviewViewController : UIViewController
<UICollectionViewDelegate, UICollectionViewDataSource, GroupLoaderDelegate, PhotoLoaderDelegate, ImageDownloaderDelegate, UIAlertViewDelegate, UserLoaderDelegate, ResourceLoaderDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property int themeId;

@property NSMutableArray* themes;
@property NSMutableArray* resources;


@end
