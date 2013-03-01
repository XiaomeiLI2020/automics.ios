//
//  ResourceView.h
//  PhotoChat
//
//  Created by Umar Rashid on 17/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResourceView : UIView <UIAlertViewDelegate>

@property NSString* type;
@property int styleId;
@property int resourceId;
@property UIImageView* imageView;
@property NSString* urlImageString;


- (id)initWithFrame:(CGRect)frame andStyle:(int)styleId;
- (id)initWithFrame:(CGRect)frame andURL:(NSString*)imageURL;
- (id)initWithFrame:(CGRect)frame andURL:(NSString*)imageURL andType:(NSString*)type;
- (id)initWithFrame:(CGRect)frame andURL:(NSString*)imageURL andType:(NSString*)type andId:(int)resourceId;

@end

