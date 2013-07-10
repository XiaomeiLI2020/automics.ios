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
<UITextFieldDelegate, UIScrollViewDelegate, UIAlertViewDelegate, PanelLoaderDelegate, ComicLoaderDelegate, ResourceLoaderDelegate>

@property MainScrollSelector *panelScrollView;
@property MainScrollSelector *thumbnailScrollView;
@property (weak, nonatomic) IBOutlet UITextField *comicTextField;

@property int currentPage;
@property int thumbPage;
@property NSArray* panelList;
@property NSArray* comicPanelList;
@property NSArray *comicPanelThumbnailIds;
@property NSMutableArray* downloadedComicPanels;
@property NSMutableArray* downloadedPanels;
@property NSMutableArray* downloadedPhotos;
@property NSArray *resourceList;
@property NSArray *placementList;
@property CGFloat lastContentOffsetX;
@property NSString* comicName;

- (IBAction)deletePanel:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *postButton;

@property NSMutableArray *panelArray;
@property int comicId;
@property UIActivityIndicatorView *activityIndicator;

@end
