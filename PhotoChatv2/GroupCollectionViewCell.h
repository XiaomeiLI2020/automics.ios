//
//  GroupCollectionViewCell.h
//  scaleView
//
//  Created by horizon on 22/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "Theme.h"
#import "Resource.h"

@interface GroupCollectionViewCell : UICollectionViewCell{
    Group *group;
    Theme* theme;
    Resource* resource;
}
@property IBOutlet UIImageView *imageView;
@property IBOutlet UILabel *label;
@property IBOutlet UIActivityIndicatorView *activityIndicator;

-(void)setGroup:(Group*)newGroup;
-(Group*)getGroup;

-(void)setTheme:(Theme*)newTheme;
-(Theme*)getTheme;

-(void)setResource:(Resource*)newResource;
-(Resource*)getResource;


@end