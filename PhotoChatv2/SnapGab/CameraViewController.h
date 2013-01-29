//
//  CameraViewController.h
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SelectBubbleStyleViewController.h"
#import "ResourceViewController.h"


@interface CameraViewController : UIViewController
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

- (IBAction)takeSnap:(id)sender;
- (IBAction)showPhotos:(id)sender;
- (IBAction)closePressed:(id)sender;




@end
