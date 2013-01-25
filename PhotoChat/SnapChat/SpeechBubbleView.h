//
//  SpeechBubbleView.h
//  PhotoChat
//
//  Created by Duncan Rowland on 29/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BubbleTextView.h"

@interface SpeechBubbleView : UIView <UITextViewDelegate>

@property BubbleTextView* textView;
@property int styleId;

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text andStyle:(int)styleId;

@end
