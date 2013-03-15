//
//  QRView.m
//  PhotoChat
//
//  Created by Shakir Ali on 14/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "QRView.h"

@interface QRView ()

@property UIImageView* imageView;
@property UIImageView* deleteView;

@end

@implementation QRView

#define PADDING 30.0

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupImageViewWithImage:image];
        [self setupDeleteView];
        [self setupDeleteGesture];
    }
    return self;
}

-(void)setupImageViewWithImage:(UIImage*)image
{
    self.imageView = [[UIImageView alloc] initWithFrame:[self calculateImageViewFrame]];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.imageView.layer.borderWidth = 2.0;
    self.imageView.image = image;
    [self addSubview:self.imageView];
}

-(CGRect)calculateImageViewFrame{
    return CGRectMake(PADDING/2, PADDING/2, self.bounds.size.width - PADDING, self.bounds.size.height - PADDING);
}

-(CGRect)calculateDeleteViewFrame{
    return CGRectMake(0.0, 0.0, PADDING, PADDING);
}

-(void)setupDeleteView{
    self.deleteView = [[UIImageView alloc] initWithFrame:[self calculateDeleteViewFrame]];
    self.deleteView.image = [UIImage imageNamed:@"close_gold"];
    self.deleteView.userInteractionEnabled = YES;
    [self addSubview:self.deleteView];
}

-(void)setupDeleteGesture
{
    UITapGestureRecognizer *deleteGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTap:)];
    [self.deleteView addGestureRecognizer:deleteGesture];
}

-(void)deleteTap:(UITapGestureRecognizer*)recognizer{
    UIView * delete = (UIView *)[recognizer view];
    [delete.superview removeFromSuperview];
}

@end
