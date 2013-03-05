//
//  CameraViewController.h
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>



@interface CameraViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    BOOL newMedia;
    int subviewId;
    CGRect originalFrame;
}


- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property NSURL* url;
@property BOOL startWithCamera;
@property CGSize imageSize;

@property UIScrollView* scrollView;
@property BOOL keyboardIsShown;

- (IBAction)takeSnap:(id)sender;
- (IBAction)showPhotos:(id)sender;
- (IBAction)closePressed:(id)sender;
-(IBAction)editPanel:(id)sender;




@end
