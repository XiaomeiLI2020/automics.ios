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
@property MainScrollSelector *thumbnailScrollView;

@property int currentPage;


@property (strong, nonatomic) IBOutlet UIButton *editPressed;

@property int comicId;

@end
