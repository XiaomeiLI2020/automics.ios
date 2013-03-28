//
//  GroupCollectionViewLayout.m
//  scaleView
//
//  Created by horizon on 26/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "GroupCollectionViewLayout.h"
#import "GroupDecorationView.h"

@interface GroupCollectionViewLayout()
@property (nonatomic, strong) NSDictionary *shelfRects;
@end

@implementation GroupCollectionViewLayout

-(id)init{
    self = [super init];
    if (self)
    {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.itemSize = (CGSize){135, 162};
        self.sectionInset = UIEdgeInsetsMake(4, 10, 14, 10);
        self.minimumInteritemSpacing = 10;
        self.minimumLineSpacing = 10;
        [self registerClass:[GroupDecorationView class] forDecorationViewOfKind:[GroupDecorationView kind]];
    }
    return self;
}

// Do all the calculations for determining where shelves go here
- (void)prepareLayout
{
    // call super so flow layout can do all the math for cells, headers, and footers
    [super prepareLayout];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical)
    {
        // Calculate where shelves go in a vertical layout
        int sectionCount = [self.collectionView numberOfSections];
        
        CGFloat y = 0;
        CGFloat availableWidth = self.collectionViewContentSize.width - (self.sectionInset.left + self.sectionInset.right);
        int itemsAcross = floorf((availableWidth + self.minimumInteritemSpacing) / (self.itemSize.width + self.minimumInteritemSpacing));
        
        for (int section = 0; section < sectionCount; section++)
        {
            y += self.sectionInset.top;
            int itemCount = [self.collectionView numberOfItemsInSection:section];
            int rows = ceilf(itemCount/(float)itemsAcross);
            for (int row = 0; row < rows; row++)
            {
                y += self.itemSize.height;
                dictionary[[NSIndexPath indexPathForItem:row inSection:section]] = [NSValue valueWithCGRect:CGRectMake(0, y - 32, self.collectionViewContentSize.width, 37)];
                
                if (row < rows - 1)
                    y += self.minimumLineSpacing;
            }
            y += self.sectionInset.bottom;
        }
    }
    else
    {
        // Calculate where shelves go in a horizontal layout
        CGFloat y = self.sectionInset.top;
        CGFloat availableHeight = self.collectionViewContentSize.height - (self.sectionInset.top + self.sectionInset.bottom);
        int itemsAcross = floorf((availableHeight + self.minimumInteritemSpacing) / (self.itemSize.height + self.minimumInteritemSpacing));
        CGFloat interval = ((availableHeight - self.itemSize.height) / (itemsAcross <= 1? 1 : itemsAcross - 1)) - self.itemSize.height;
        for (int row = 0; row < itemsAcross; row++)
        {
            y += self.itemSize.height;
            dictionary[[NSIndexPath indexPathForItem:row inSection:0]] = [NSValue valueWithCGRect:CGRectMake(0, roundf(y - 32), self.collectionViewContentSize.width, 37)];
            
            y += interval;
        }
    }

    self.shelfRects = [NSDictionary dictionaryWithDictionary:dictionary];
}

// Return attributes of all items (cells, supplementary views, decoration views) that appear within this rect
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // call super so flow layout can return default attributes for all cells, headers, and footers
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    // tweak the attributes slightly
    for (UICollectionViewLayoutAttributes *attributes in array)
    {
        attributes.zIndex = 1;
        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal && attributes.representedElementCategory == UICollectionElementCategorySupplementaryView)
        {
            // make label vertical if scrolling is horizontal
            attributes.transform3D = CATransform3DMakeRotation(-90 * M_PI / 180, 0, 0, 1);
            attributes.size = CGSizeMake(attributes.size.height, attributes.size.width);
        }
        
    }
    
    // Add our decoration views (shelves)
    NSMutableArray *newArray = [array mutableCopy];
    
    [self.shelfRects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (CGRectIntersectsRect([obj CGRectValue], rect))
        {
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[GroupDecorationView kind] withIndexPath:key];
            attributes.frame = [obj CGRectValue];
            attributes.zIndex = 0;
            [newArray addObject:attributes];
        }
    }];
    
    array = [NSArray arrayWithArray:newArray];
    
    return array;
}

// Layout attributes for a specific cell
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    attributes.zIndex = 1;
    return attributes;
}

// layout attributes for a specific decoration view
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    id shelfRect = self.shelfRects[indexPath];
    if (!shelfRect)
        return nil; // no shelf at this index (this is probably an error)
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[GroupDecorationView kind] withIndexPath:indexPath];
    attributes.frame = [shelfRect CGRectValue];
    attributes.zIndex = 0; // shelves go behind other views
    
    return attributes;
}

@end
