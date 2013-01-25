//
//  BubbleTextView.m
//  PhotoChat
//
//  Created by Duncan Rowland on 25/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BubbleTextView.h"

@implementation BubbleTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.scrollEnabled = NO;
        self.bounces = NO;
        self.userInteractionEnabled = NO;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return self;      
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    //NSLog(@"%s\n",sel_getName(action));
    if (action == @selector(paste:)  ||
        action == @selector(cut:)    ||
        action == @selector(copy:)   ||
        action == @selector(_define:)   ||
        action == @selector(_promptForReplace:)   ||
        action == @selector(_replace:)   ||
        action == @selector(select:) ||
        action == @selector(selectAll:) )
        return NO;
    return [super canPerformAction:action withSender:sender];
}

@end
