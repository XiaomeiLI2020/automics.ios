//
//  ComicAddViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 13/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollSelector.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SelectBubbleStyleViewController.h"
#import "ResourceViewController.h"


@interface ComicAddViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, SelectBubbleStyleDelegateProtocol, ResourceDelegateProtocol,
UIAlertViewDelegate>


@property NSString* _groupName;
@property int currentPage;
@property int panelCounter;

@property NSURL* url;

@property MainScrollSelector *comicScrollView;
@property MainScrollSelector *thumbnailScrollView;

@property NSMutableArray *panelArray;

- (IBAction)deletePanel:(id*)sender;


@end