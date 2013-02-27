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
#import "SelectBubbleStyleViewController.h"
#import "ResourceViewController.h"

@interface PanelEditViewController : UIViewController
<UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SelectBubbleStyleDelegateProtocol, ResourceDelegateProtocol>

{
    BOOL newMedia;
    int subviewId;
    CGRect originalFrame;
}

@property MainScrollSelector *thumbnailScrollView;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
//@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property NSURL* url;
@property BOOL startWithCamera;
@property CGSize imageSize;


@property BOOL keyboardIsShown;
@property int currentPage;
@property NSString* _groupName;
@property NSMutableArray* resourceList;

@end
