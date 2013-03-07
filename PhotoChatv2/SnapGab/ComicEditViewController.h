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


- (IBAction)deletePanel:(id)sender;


@property NSMutableArray *panelArray;
@property int comicId;


@end
