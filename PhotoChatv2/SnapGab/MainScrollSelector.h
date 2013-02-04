//
//  MainScrollSelector.h
//  PhotoChat
//
//  Created by Umar Rashid on 01/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainScrollSelector : UIScrollView //<UIScrollViewDelegate>


@property int numItems;
@property CGRect scrollFrame;
@property CGFloat scrollObjWidth;
@property CGFloat scrollObjHeight;
@property CGFloat itemWidth;
@property CGFloat itemHeight;

- (id)initWithFrame:(CGRect)frame andNumItems:(int)numItems;
- (id)initWithFrame:(CGRect)frame andItemSize:(CGSize)itemSize andNumItems:(int)numItems;
- (void)layoutItems;
- (void)scrollItemToVisible:(int)sender;

@end
