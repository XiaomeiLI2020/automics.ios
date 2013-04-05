//
//  ComicCollectionViewCell.h
//  PhotoChat
//
//  Created by horizon on 04/04/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comic.h"

@interface ComicCollectionViewCell : UICollectionViewCell{
    Comic *comic;
}
@property IBOutlet UIImageView* imageView;
@property IBOutlet UILabel* label;
@property IBOutlet UIActivityIndicatorView* activityView;

-(void)setComic:(Comic*)newComic;
-(Comic*)getComic;
@end
