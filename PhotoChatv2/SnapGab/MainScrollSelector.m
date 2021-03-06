//
//  MainScrollSelector.m
//  PhotoChat
//
//  Created by Umar Rashid on 01/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "MainScrollSelector.h"
#import "SpeechBubbleView.h"
#import "ResourceView.h"

@interface MainScrollSelector ()

@end

@implementation MainScrollSelector

@synthesize numItems;
@synthesize scrollFrame;
@synthesize scrollObjWidth;
@synthesize scrollObjHeight;
@synthesize itemWidth;
@synthesize itemHeight;


//Init ScrollView with the scrollview's frame size, item size, and no. of items
- (id)initWithFrame:(CGRect)frame andItemSize:(CGSize)itemSize
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //self.scrollFrame = frame;
        self.scrollFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        self.scrollObjWidth = frame.size.width;
        self.scrollObjHeight = frame.size.height;
        
        self.itemWidth = itemSize.width;
        self.itemWidth = itemSize.height;
        
        self.numItems = 0;
        
        // setup the scrollview for items
        [self setCanCancelContentTouches:NO];
        self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        self.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
        self.scrollEnabled = YES;
        
        // pagingEnabled property default is NO, if set the scroller will stop or snap at each photo
        // if you want free-flowing scroll, don't set this property.
        self.pagingEnabled = YES;
        
        for (UIView *subview in self.subviews) {
            [subview removeFromSuperview];
        }
    }
    return self;
}


//Init ScrollView with the scrollview's frame size, item size, and no. of items
- (id)initWithFrame:(CGRect)frame andItemSize:(CGSize)itemSize
        andNumItems:(int)numOfItems
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.scrollFrame = frame;
        self.scrollObjWidth = frame.size.width;
        self.scrollObjHeight = frame.size.height;
        
        self.itemWidth = itemSize.width;
        self.itemWidth = itemSize.height;
        
        self.numItems = numOfItems;
        
        // setup the scrollview for items
        [self setCanCancelContentTouches:NO];
        self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        self.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
        self.scrollEnabled = YES;
        
        // pagingEnabled property default is NO, if set the scroller will stop or snap at each photo
        // if you want free-flowing scroll, don't set this property.
        self.pagingEnabled = YES;
        
        for (UIView *subview in self.subviews) {
            [subview removeFromSuperview];
        }
    }
    return self;
}


- (void)scrollItemToVisible:(int)pageNum
{
    //int itemPosition = sender;
    //if(sender==0)
    //    itemPosition = 1;
    // Scroll to the sepcified item in the scrollview
    CGRect scrollFrame1 = self.frame;
    scrollFrame1.origin.x = self.itemWidth * (pageNum);
    //NSLog(@"panelframe.origin.x = %f", panelFrame.origin.x);
    scrollFrame1.origin.y = 0;
    [self scrollRectToVisible:scrollFrame1 animated:YES];
}


- (void)layoutItems
{
    
	UIImageView *view = nil;
	NSArray *subviews = [self subviews];
    
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews)
	{
		//if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
        if ([view isKindOfClass:[UIImageView class]])
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += (self.itemWidth);
		}
	}
	
	// set the content size so it can be scrollable
	//[self setContentSize:CGSizeMake((self.numItems * self.scrollObjWidth), [self bounds].size.height)];
    //[self setContentSize:CGSizeMake((self.numItems * self.scrollObjWidth), self.frame.size.height)];
    //NSLog(@"self.numItems * self.itemWidth=%f", (self.numItems * self.itemWidth));
    //NSLog(@"self.numItems * self.scrollObjWidth=%f", (self.numItems * self.scrollObjWidth));
    [self setContentSize:CGSizeMake((self.numItems * self.itemWidth), self.frame.size.height)];
    //[self setContentOffset:CGPointMake(1, 0) animated:YES];
}

- (void)layoutAssets
{
    
	UIImageView *view = nil;
	NSArray *subviews = [self subviews];
    
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews)
	{
		if ([view isKindOfClass:[UIButton class]])
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += (self.itemWidth);
		}
	}
	
	// set the content size so it can be scrollable
	//[self setContentSize:CGSizeMake((self.numItems * self.scrollObjWidth), [self bounds].size.height)];
    //[self setContentSize:CGSizeMake((self.numItems * self.scrollObjWidth), self.frame.size.height)];
    [self setContentSize:CGSizeMake((self.numItems * self.itemWidth), self.frame.size.height)];
    //[self setContentOffset:CGPointMake(1, 0) animated:YES];
}

@end
