//
//  ResourceView.h
//  PhotoChat
//
//  Created by Umar Rashid on 17/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResourceView : UIView 

@property int styleId;
@property UIImageView* imageView;


- (id)initWithFrame:(CGRect)frame andStyle:(int)styleId;

@end

