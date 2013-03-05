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

@interface PanelAddViewController : UIViewController

<UINavigationControllerDelegate, UIImagePickerControllerDelegate, ResourceLoaderDelegate>
{
    BOOL newMedia;
    int subviewId;
    CGRect originalFrame;
}



@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property NSURL* url;
@property BOOL startWithCamera;
@property CGSize imageSize;


@property BOOL keyboardIsShown;

@property MainScrollSelector *thumbnailScrollView;
@property NSMutableArray* resourceList;

- (IBAction)takeSnap:(id)sender;
- (IBAction)showPhotos:(id)sender;


@end
