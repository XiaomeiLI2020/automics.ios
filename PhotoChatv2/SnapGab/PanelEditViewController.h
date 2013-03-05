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
#import "Panel.h"

@interface PanelEditViewController : UIViewController
<UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ResourceLoaderDelegate>

{
    BOOL newMedia;
    int subviewId;
    CGRect originalFrame;
}

@property MainScrollSelector *thumbnailScrollView;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
//@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
//@property IBOutlet UIImageView *imageView;

@property NSURL* url;
@property BOOL startWithCamera;
@property CGSize imageSize;

@property Panel* currentPanel;
@property BOOL keyboardIsShown;
@property NSString* _groupName;
@property NSMutableArray* resourceList;
@property int panelId;

@end
