//
//  ThemeViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 24/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrganisationLoader.h"
#import "ResourceLoader.h"
#import "GroupLoader.h"
#import "PhotoLoader.h"
#import "UserLoader.h"

@interface ThemeViewController : UIViewController
<UICollectionViewDelegate, UICollectionViewDataSource, GroupLoaderDelegate, ImageDownloaderDelegate, UIAlertViewDelegate, UserLoaderDelegate, OrganisationLoaderDelegate, ResourceLoaderDelegate>


@property NSArray* organisations;
@property NSMutableArray* themes;
@property OrganisationLoader* organisationLoader;
@property int organisationCounter;
@property UIScrollView* themeScrollView;
@property UIScrollView* resourceScrollView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
