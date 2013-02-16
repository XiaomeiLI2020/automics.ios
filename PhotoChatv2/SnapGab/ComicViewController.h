//
//  ComicViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 12/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollSelector.h"

@interface ComicViewController : UIViewController<UIScrollViewDelegate>

@property MainScrollSelector *panelScrollView;
@property MainScrollSelector *thumbnailScrollView;

@property BOOL wasEdited;
@property NSString* _groupName;
@property int currentPage;
@property BOOL addImage;

@property UITableView* comicTable;
@property UIScrollView* comicList;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property BOOL startWithCamera;
@property BOOL newMedia;


@end