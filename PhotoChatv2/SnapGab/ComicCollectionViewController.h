//
//  ComicCollectionViewController.h
//  PhotoChat
//
//  Created by horizon on 05/04/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComicLoader.h"
#import "PanelLoader.h"
#import "ImageDownloader.h"

@interface ComicCollectionViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource,ComicLoaderDelegate, PanelLoaderDelegate, ImageDownloaderDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *toolbarImage;
@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property IBOutlet UICollectionView* collectionView;
@property (weak, nonatomic) IBOutlet UILabel *comicsLabel;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

- (IBAction)refreshed:(id)sender;


@end
