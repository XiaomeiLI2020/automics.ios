//
//  ComicTableCell.m
//  PhotoChat
//
//  Created by Umar Rashid on 16/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ComicTableCell.h"

@implementation ComicTableCell

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
