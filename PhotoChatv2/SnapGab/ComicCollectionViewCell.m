//
//  ComicCollectionViewCell.m
//  PhotoChat
//
//  Created by horizon on 04/04/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ComicCollectionViewCell.h"

@implementation ComicCollectionViewCell

-(void)setComic:(Comic*)newComic{
    comic = newComic;
    _label.text = newComic.name;
}

-(Comic*)getComic{
    return comic;
}

@end
