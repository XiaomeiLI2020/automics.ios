//
//  PanelAddViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 11/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollSelector.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ResourceLoader.h"
#import "PanelPopupWindow.h"

@interface PanelAddViewController : UIViewController

<UINavigationControllerDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, ResourceLoaderDelegate, PanelPopupWindowDelegate>
{
    BOOL newMedia;
    int subviewId;
    CGRect originalFrame;
}



@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property BOOL initialized;
@property NSURL* url;
@property BOOL startWithCamera;
@property CGSize imageSize;
@property BOOL keyboardIsShown;
@property (weak, nonatomic) IBOutlet UIButton *imagesButton;

@property MainScrollSelector *panelScrollView;
@property MainScrollSelector *thumbnailScrollView;
@property (retain) NSMutableArray* resourceList;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
- (IBAction)postPanel:(id)sender;

- (IBAction)takeSnap:(id)sender;
- (IBAction)showPhotos:(id)sender;


@end
