//
//  PanelEditViewController.h
//  PhotoChat
//
//  Created by horizon on 30/01/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollSelector.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "ResourceLoader.h"
#import "PanelLoader.h"
#import "Panel.h"

@interface PanelEditViewController : UIViewController
<UIScrollViewDelegate, PanelLoaderDelegate, ResourceLoaderDelegate, ImageDownloaderDelegate>


@property MainScrollSelector *thumbnailScrollView;
@property MainScrollSelector *panelScrollView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property int subviewId;
@property CGRect originalFrame;

@property NSURL* url;
@property CGSize imageSize;

@property Panel* currentPanel;
@property BOOL keyboardIsShown;
@property (retain) NSMutableArray* resourceList;
@property int panelId;

@end
