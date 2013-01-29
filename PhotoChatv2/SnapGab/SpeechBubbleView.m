//
//  SpeechBubbleView.m
//  SnapGab
//
//  Created by Umar Rashid on 28/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "SpeechBubbleView.h"

@interface SpeechBubbleView()
{
@private
    BubbleTextView* _textView;
    CGRect _safeArea;
    UIImageView* _imageView;
    int _styleId;
}
@end

@implementation SpeechBubbleView

@synthesize textView=_textView;
@synthesize styleId=_styleId;

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text andStyle:(int)styleId
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"bubble-style%d.png",styleId]]];
        [self addSubview:_imageView];
        
        _styleId = styleId;
        switch(_styleId) {
            case 0: _safeArea = CGRectMake(60,34,151,79); break;
            case 1: _safeArea = CGRectMake(46,34,151,79); break;
            case 2: _safeArea = CGRectMake(60,116,151,79); break;
            case 3: _safeArea = CGRectMake(46,116,151,79); break;
            case 4: _safeArea = CGRectMake(59,31,143,77); break;
            case 5: _safeArea = CGRectMake(54,31,143,77); break;
            case 6: _safeArea = CGRectMake(59,83,143,77); break;
            case 7: _safeArea = CGRectMake(54,83,143,77); break;
            case 8: _safeArea = CGRectMake(24,18,192,115); break;
        }
        
        _textView = [[BubbleTextView alloc] initWithFrame:frame];
        _textView.delegate = self;
        _textView.text = text;
        _textView.userInteractionEnabled = NO;
        [self addSubview:_textView];
        
        UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

UIButton* _invisibleButton;
- (void)pressedInvisibleButton:(id)button
{
    [_textView resignFirstResponder];
    _textView.userInteractionEnabled = NO;
    [_invisibleButton removeFromSuperview];
    _invisibleButton=nil;
    if([_textView.text isEqualToString:@""]) [self removeFromSuperview];
}

- (void)tapped:(id)sender
{
    _textView.userInteractionEnabled = !_textView.userInteractionEnabled;
    if(_textView.userInteractionEnabled)
    {
        if(!_invisibleButton)
        {
            _invisibleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [_invisibleButton addTarget:self
                                 action:@selector(pressedInvisibleButton:)
                       forControlEvents:UIControlEventTouchDown];
            
            _invisibleButton.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.75];
            
            _invisibleButton.alpha = 0.5;
            _invisibleButton.frame = [[UIScreen mainScreen] bounds];
            [self.superview addSubview:_invisibleButton];
        }
        [self.superview bringSubviewToFront:_invisibleButton];
        [self.superview bringSubviewToFront:self];
        [_textView becomeFirstResponder];
    }
}

- (void)layoutSubviews
{
    
    //Find new size of text area
    
    
    CGRect textFrame;
    
    textFrame.size = [_textView.text sizeWithFont:_textView.font
                                constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)
                                    //lineBreakMode:UILineBreakModeWordWrap
                      ];
    
    textFrame.size.width  += 20; //<-- This is needed for odd linebreak reasons I don't understand
    
    if(textFrame.size.width  < 32) textFrame.size.width  = 32;
    if(textFrame.size.height < 16) textFrame.size.height = 16;
    

    
    //Find out how much we need to scale the image (make safe area size = text area size)
    
    CGPoint scaleImage = CGPointMake( textFrame.size.width  / _safeArea.size.width,
                                     textFrame.size.height / _safeArea.size.height);
    
    //Locate the text area so the top left corner is the safe area's origin
    
    CGPoint offsetText = CGPointMake( _safeArea.origin.x * scaleImage.x,
                                     _safeArea.origin.y * scaleImage.y);
    
    textFrame.origin = offsetText;
    
    
    //Size and position of text area is finished
    
    _textView.frame = textFrame;
    
    //Find new size of image
    
    CGRect imageFrame;
    
    imageFrame.origin = CGPointMake(0.0f, 0.0f);
    
    imageFrame.size = CGSizeMake( _imageView.image.size.width  * scaleImage.x,
                                 _imageView.image.size.height * scaleImage.y);
    
    //Make this view and the image the same size
    
    CGRect selfFrame = self.frame;
    selfFrame.size = imageFrame.size;
    self.frame = selfFrame;
    
    _imageView.frame = imageFrame;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self setNeedsLayout];
}

CGPoint _ptOffset;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* t = [touches anyObject];
    _ptOffset = [t locationInView: self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* t = [touches anyObject];
    CGPoint pt = [t locationInView: self.superview];
    pt.x -= _ptOffset.x;
    pt.y -= _ptOffset.y;
    
    CGRect r = self.frame;
    r.origin = pt;
    self.frame = r;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _ptOffset = CGPointMake(-1, -1);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
