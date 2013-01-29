//
//  SpeechBubbleView.h
//  SnapGab
//
//  Created by Umar Rashid on 28/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BubbleTextView.h"

@interface SpeechBubbleView : UIView <UITextViewDelegate>

@property BubbleTextView* textView;
@property int styleId;

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text andStyle:(int)styleId;

@end
