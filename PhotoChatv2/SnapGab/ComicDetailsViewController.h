//
//  ComicDetailsViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 16/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollSelector.h"
#import "PanelLoader.h"
#import "ComicLoader.h"
#import "ResourceLoader.h"


@interface ComicDetailsViewController : UIViewController
<UIScrollViewDelegate, PanelLoaderDelegate, ComicLoaderDelegate, ResourceLoaderDelegate>

@property MainScrollSelector *panelScrollView;


@property int currentPage;

@property (strong, nonatomic) IBOutlet UIButton *editPressed;
@property (weak, nonatomic) IBOutlet UILabel *comicNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property int comicId;
@property UIActivityIndicatorView *activityIndicator;
@property NSString* comicName;

-(IBAction)comicsButtonCicked:(id)sender;

@end
