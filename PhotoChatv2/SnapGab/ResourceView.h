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


- (id)initWithFrame:(CGRect)frame andResource:(Resource*)resource andScale:(float)scale andAngle:(float)angle;

-(void)disappearControls;
@end

