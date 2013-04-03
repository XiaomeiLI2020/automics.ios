//
//  ComicEditViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 13/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollSelector.h"
#import "ComicLoader.h"
#import "ResourceLoader.h"
#import "PanelLoader.h"

@interface ComicEditViewController : UIViewController
<UIScrollViewDelegate, UIAlertViewDelegate, PanelLoaderDelegate, ComicLoaderDelegate, ResourceLoaderDelegate>

@property MainScrollSelector *panelScrollView;
@property MainScrollSelector *thumbnailScrollView;

@property int currentPage;
@property NSArray* panelList;
@property NSArray* comicPanelList;
@property NSMutableArray* downloadedPanels;
@property NSArray *resourceList;
@property NSArray *placementList;


- (IBAction)deletePanel:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *postButton;

@property NSMutableArray *panelArray;
@property int comicId;
@property UIActivityIndicatorView *activityIndicator;

@end
