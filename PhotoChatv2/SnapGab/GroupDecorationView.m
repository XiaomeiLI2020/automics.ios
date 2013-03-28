//
//  GroupDecorationView.m
//  scaleView
//
//  Created by horizon on 26/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "GroupDecorationView.h"
#import <QuartzCore/QuartzCore.h>

const NSString *kViewKind = @"GroupDecorationView";

@implementation GroupDecorationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"groupDecoration"]]];
        //self.layer.shadowOpacity = 0.5;
        //self.layer.shadowOffset = CGSizeMake(0, 5);
    }
    return self;
}

-(void)layoutSubviews{
    //CGRect shadowBounds = CGRectMake(0, -5, self.bounds.size.width, self.bounds.size.height + 5);
    //self.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowBounds].CGPath;
}

+(NSString*)kind{
    return (NSString*)kViewKind;
}

@end
