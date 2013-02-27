//
//  PanelViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 11/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollSelector.h"
#import "Panel.h"

@interface PanelViewController : UIViewController

<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *editButton;

@property MainScrollSelector *panelScrollView;
@property MainScrollSelector *thumbnailScrollView;


@property NSString* _groupName;
@property int currentPage;
@property NSArray* panels;
@property int currentPanelId;
@property Panel* currentPanel;


@end