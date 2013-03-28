//
//  GroupCollectionViewCell.m
//  scaleView
//
//  Created by horizon on 22/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "GroupCollectionViewCell.h"

@implementation GroupCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
