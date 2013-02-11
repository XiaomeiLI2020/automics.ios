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
#import "SelectBubbleStyleViewController.h"
#import "ResourceViewController.h"

@interface PanelAddViewController : UIViewController

<UINavigationControllerDelegate, UIImagePickerControllerDelegate, SelectBubbleStyleDelegateProtocol, ResourceDelegateProtocol>
{
    BOOL newMedia;
    int subviewId;
    CGRect originalFrame;
}


- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;


@property NSURL* url;
@property BOOL startWithCamera;
@property CGSize imageSize;

@property UIScrollView* scrollView;
@property BOOL keyboardIsShown;

@property MainScrollSelector *thumbnailScrollView;

- (IBAction)takeSnap:(id)sender;
- (IBAction)showPhotos:(id)sender;
- (IBAction)closePressed:(id)sender;
-(IBAction)editPanel:(id)sender;

@end
