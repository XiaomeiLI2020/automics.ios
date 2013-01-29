//
//  BubbleTextView.m
//  SnapGab
//
//  Created by Umar Rashid on 28/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"started editing");
    if(![self isFirstResponder])
    [self becomeFirstResponder];
    //editing = TRUE;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    //editing = FALSE;
}


@end
