//
//  GroupLayout.m
//  PhotoChat
//
//  Created by Shakir Ali on 13/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "GroupLayout.h"

#define ITEM_SIZE 80

@implementation GroupLayout

-(void)prepareLayout
{
    [super prepareLayout];
    CGSize size = self.collectionView.frame.size;
    _cellCount = [[self collectionView] numberOfItemsInSection:0];
    _center = CGPointMake(size.width/2.0, size.height/2.0);
    _radius = MIN(size.width, size.height) / 4.0;
}

-(CGSize)collectionViewContentSize
{
    return [self collectionView].frame.size;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
    attributes.center = CGPointMake(_center.x + _radius * cosf(2 * indexPath.item * M_PI / _cellCount),
                                    _center.y + _radius * sinf(2 * indexPath.item * M_PI / _cellCount));
    return attributes;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger i=0; i < self.cellCount; i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}


@end
