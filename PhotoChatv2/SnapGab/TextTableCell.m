//
//  TextTableCell.m
//  PhotoChat
//
//  Created by Umar Rashid on 19/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "TextTableCell.h"

@implementation TextTableCell
@synthesize label;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
