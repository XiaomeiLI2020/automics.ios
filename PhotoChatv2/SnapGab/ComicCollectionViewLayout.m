//
//  ComicCollectionViewLayout.m
//  PhotoChat
//
//  Created by horizon on 05/04/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ComicCollectionViewLayout.h"

#define COMIC_ITEM_WIDTH 129
#define COMIC_ITEM_HEIGHT 148


@implementation ComicCollectionViewLayout


-(id)init{

    self = [super init];
    if (self)
    {

        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.itemSize = (CGSize) {COMIC_ITEM_WIDTH, COMIC_ITEM_HEIGHT};
        self.sectionInset = UIEdgeInsetsMake(4,10, 14, 10);
        self.minimumInteritemSpacing = 10;
        self.minimumLineSpacing = 10;
     
    }
    return self;
}





@end
