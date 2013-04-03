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
    }
    return self;
}

+(NSString*)kind{
    return (NSString*)kViewKind;
}

@end
