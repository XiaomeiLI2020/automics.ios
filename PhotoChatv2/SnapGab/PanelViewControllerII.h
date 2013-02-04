//
//  PanelViewControllerII.h
//  PhotoChat
//
//  Created by Umar Rashid on 01/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScrollSelector.h"

@interface PanelViewControllerII : UIViewController <UIScrollViewDelegate>

@property MainScrollSelector *panelScrollView;
@property MainScrollSelector *thumbnailScrollView;


@end
