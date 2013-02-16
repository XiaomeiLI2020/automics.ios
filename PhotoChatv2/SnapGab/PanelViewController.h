//
//  PanelViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 11/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollSelector.h"

@interface PanelViewController : UIViewController <UIScrollViewDelegate>

@property MainScrollSelector *panelScrollView;
@property MainScrollSelector *thumbnailScrollView;


@property NSString* _groupName;
@property int currentPage;
@property BOOL addImage;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property BOOL startWithCamera;
@property BOOL newMedia;

- (IBAction)cameraOrRoll:(id)sender;


@end