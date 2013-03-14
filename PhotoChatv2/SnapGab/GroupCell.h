//
//  GroupCell.h
//  scaleView
//
//  Created by horizon on 13/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface GroupCell : UICollectionViewCell{
    Group *group;
}

-(void)setGroup:(Group *)newGroup;
-(Group*)getGroup;
@end
