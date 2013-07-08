//
//  ComicAddViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 13/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollSelector.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ComicLoader.h"
#import "ResourceLoader.h"
#import "PanelLoader.h"

@interface ComicAddViewController : UIViewController
//<UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>
<UIScrollViewDelegate, UIAlertViewDelegate, PanelLoaderDelegate, ComicLoaderDelegate, ResourceLoaderDelegate>


@property NSString* _groupName;
@property int currentPage;
@property int panelCounter;
@property NSString* comicName;

@property NSURL* url;
@property int thumbPage;
@property CGFloat lastContentOffsetX;

@property MainScrollSelector *panelScrollView;
@property MainScrollSelector *thumbnailScrollView;

@property NSMutableArray *panelArray;
@property NSArray *panels;

-(IBAction)deletePanel:(id*)sender;
-(IBAction)comicsButtonCicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property UIActivityIndicatorView *activityIndicator;

@end
