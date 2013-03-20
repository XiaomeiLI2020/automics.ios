//
//  ResourceImageView.h
//  scaleView
//
//  Created by Shakir Ali on 11/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResourceImageView : UIView
- (id)initWithFrame:(CGRect)frame image:(UIImage*)image;
- (id)initWithFrame:(CGRect)frame imageURL:(NSString*)imageURLString;
@end
