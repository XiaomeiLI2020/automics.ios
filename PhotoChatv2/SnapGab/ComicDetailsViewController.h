//
//  ComicDetailsViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 16/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollSelector.h"

@interface ComicDetailsViewController : UIViewController<UIScrollViewDelegate>

@property MainScrollSelector *panelScrollView;
@property MainScrollSelector *thumbnailScrollView;


@property NSString* _groupName;
@property int currentPage;
@property BOOL addImage;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property BOOL startWithCamera;
@property BOOL newMedia;

@property (strong, nonatomic) IBOutlet UIButton *editPressed;

@property int comicId;

@end