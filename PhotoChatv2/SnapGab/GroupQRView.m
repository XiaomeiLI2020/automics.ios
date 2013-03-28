//
//  GroupQRView.m
//  scaleView
//
//  Created by horizon on 28/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "GroupQRView.h"

@implementation GroupQRView

@synthesize qrImageView;
@synthesize closeView;
@synthesize label;


-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setupDeleteGesture];
    }
    return self;
}

-(void)setupDeleteGesture
{
    UITapGestureRecognizer *closeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTap:)];
    [self addGestureRecognizer:closeGesture];
}

-(void)closeTap:(UITapGestureRecognizer*)recognizer{
    [self removeFromSuperview];
}

@end
