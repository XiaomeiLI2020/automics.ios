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
    
    //_label.numberOfLines = 0; //will wrap text in new line
    //[_label sizeToFit];
    
}

-(Comic*)getComic{
    return comic;
}

-(void)prepareForReuse{
    [super prepareForReuse];
}

@end
