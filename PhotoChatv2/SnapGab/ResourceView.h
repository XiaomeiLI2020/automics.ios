//
//  ResourceView.h
//  PhotoChat
//
//  Created by Umar Rashid on 17/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Resource.h"


@interface ResourceView : UIView <UIAlertViewDelegate>

@property NSString* type;
@property int styleId;
@property int resourceId;
@property UIImageView* imageView;
@property NSString* urlImageString;
@property CGFloat scale;
@property CGFloat angle;
@property BOOL longPressed;
@property BOOL actionPerformed;
@property Resource* resource;
@property CGPoint originalOrigin;
@property CGSize originalImageSize;
@property CGRect originalFrame;

@property float MAX_SCALE;
@property float MIN_SCALE;
@property float MAX_SIZE;
@property float MIN_SIZE;
@property BOOL alertShown;

@property CGFloat originalDiagonal;
@property CGFloat originalWidth;
@property CGFloat originalHeight;
@property CGRect originalBounds;


- (id)initWithFrame:(CGRect)frame andResource:(Resource*)resource andScale:(float)scale andAngle:(float)angle;
- (id)initWithResourceView:(ResourceView*)resourceView;

-(void)disappearControls;
@end

