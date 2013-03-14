//
//  GroupCell.m
//  scaleView
//
//  Created by horizon on 13/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GroupCell.h"

@interface GroupCell ()
@property UILabel *label;
@end

@implementation GroupCell

#define LABEL_HEIGHT 30.0

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = 35.0f;
        self.contentView.layer.borderWidth = 1.0f;
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.contentView.backgroundColor = [UIColor underPageBackgroundColor];
        _label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, frame.size.height/2 - LABEL_HEIGHT/2 , frame.size.width - 10.0, LABEL_HEIGHT)];
        _label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_label];
    }
    return self;
}

-(void)setGroup:(Group *)newGroup{
    group = newGroup;
    _label.text = group.name;
}

-(Group*)getGroup{
    return group;
}

@end
