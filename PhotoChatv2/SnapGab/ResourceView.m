//
//  ResourceView.m
//  PhotoChat
//
//  Created by Umar Rashid on 17/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "ResourceView.h"

@interface ResourceView()
{
@private
    CGRect _safeArea;
    UIImageView* _imageView;
    int _styleId;
}
 
@end

@implementation ResourceView

@synthesize styleId = _styleId;
@synthesize imageView = _imageView;
float lastScale = 1.0;
float firstX;
float firstY;
BOOL started = false;

CGFloat _scale = 1.0;
CGFloat _previousScale = 1.0;
float MAX_SCALE = 1.05;
float MIN_SCALE = 0.90;

- (id)initWithFrame:(CGRect)frame andStyle:(int)styleId
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"resource%d.png",styleId]]];
        _imageView.userInteractionEnabled = NO;
        [self addSubview:_imageView];
        
        
        _styleId = styleId;
 /*

       UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
       [self addGestureRecognizer:tap];
        
 */ 
 
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
        [self addGestureRecognizer:pinchGesture];
     
        /*
        UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
        [self addGestureRecognizer:rotateGesture];
        */
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:panRecognizer];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        longPressGesture.minimumPressDuration = 0.30; //seconds
        [self addGestureRecognizer:longPressGesture];

    }//end if self
    return self;
}


- (void)handleLongPress:(id)gestureRecognizer
{
    
    UIView *piece = [(UITapGestureRecognizer*)gestureRecognizer view];
    [piece removeFromSuperview];

}

- (void)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
    
}
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    //[self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    UIView *piece = [(UITapGestureRecognizer*)gestureRecognizer view];
    
    /*
     NSLog(@"scale.[piece superview].frame.origin (%f,%f) ", [piece superview].frame.origin.x, [piece superview].frame.origin.x);
     NSLog(@"scale. piece.frame.origin (%f,%f)", piece.frame.origin.x, piece.frame.origin.x);
     NSLog(@"scale. piece.frame.size (%f,%f)", piece.frame.size.width, piece.frame.size.height);
     NSLog(@"scale. _imageView.frame.origin (%f,%f) ", _imageView.frame.origin.x, _imageView.frame.origin.x);
     NSLog(@"scale. _imageView.frame.size (%f,%f) ", _imageView.frame.size.width, _imageView.frame.size.height);
     */
    /*
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        //[gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        
        piece.transform = CGAffineTransformScale([piece transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        

        
        lastScale = [gestureRecognizer scale];
        
        //[gestureRecognizer setScale:1];
    }
     */
    
    //NSLog(@"Scale: %f", [gestureRecognizer scale]);
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        
        //lastScale = [gestureRecognizer scale];
        _previousScale = _scale;
    }
    
    CGFloat currentScale = [gestureRecognizer scale];
    //currentScale = MAX(MIN ([gesture scale]*_scale, MAX_SCALE), MIN_SCALE);
    //CGFloat scaleStep = currentScale /_previousScale;
    
    //[self.view setTransform: CGAffineTransformScale(self.view.transform, scaleStep, scaleStep)];
    
    /*
    if(currentScale < MIN_SCALE)
        currentScale = MIN_SCALE;
    if(currentScale >MAX_SCALE)
        currentScale = MAX_SCALE;
    */
    /*
    NSLog(@"scale. self.frame.origin (%f,%f)", self.frame.origin.x, self.frame.origin.x);
    NSLog(@"scale. self.frame.size (%f,%f)", self.frame.size.width, self.frame.size.height);
    NSLog(@"scale. piece.frame.origin (%f,%f)", piece.frame.origin.x, piece.frame.origin.x);
    NSLog(@"scale. piece.frame.size (%f,%f)", piece.frame.size.width, piece.frame.size.height);
    NSLog(@"scale. _imageView.frame.origin (%f,%f) ", _imageView.frame.origin.x, _imageView.frame.origin.x);
    NSLog(@"scale. _imageView.frame.size (%f,%f) ", _imageView.frame.size.width, _imageView.frame.size.height);
    
*/
    
    //NSLog(@"Final scale: %f", currentScale);
    /*
    if(piece.frame.size.width*currentScale > 80 && piece.frame.size.height*currentScale > 80
       && piece.frame.size.width*currentScale < 500 && piece.frame.size.height*currentScale < 500
       )
     */
    {
            piece.transform = CGAffineTransformScale([piece transform], currentScale, currentScale);
    }
    
  
    //piece.transform = CGAffineTransformScale([piece transform], currentScale, currentScale);
    
    /*
    if(piece.frame.size.width < 80)
    {
        
        CGRect imageFrame;
        //imageFrame = self.frame;
        imageFrame.origin = CGPointMake(piece.frame.origin.x, piece.frame.origin.y);
        imageFrame.size = CGSizeMake(80.1, piece.frame.size.height);
        piece.frame = imageFrame;

    }
    if(piece.frame.size.height < 80)
    {
        
        CGRect imageFrame;
        //imageFrame = self.frame;
        imageFrame.origin = CGPointMake(piece.frame.origin.x, piece.frame.origin.y);
        imageFrame.size = CGSizeMake(piece.frame.size.width, 80.1);
        piece.frame = imageFrame;
        
    }
    
    if(piece.frame.size.width > 500)
    {
        
        CGRect imageFrame;
        //imageFrame = self.frame;
        imageFrame.origin = CGPointMake(piece.frame.origin.x, piece.frame.origin.y);
        imageFrame.size = CGSizeMake(500.1, piece.frame.size.height);
        piece.frame = imageFrame;
        
    }
    if(piece.frame.size.height > 500)
    {
        
        CGRect imageFrame;
        //imageFrame = self.frame;
        imageFrame.origin = CGPointMake(piece.frame.origin.x, piece.frame.origin.y);
        imageFrame.size = CGSizeMake(piece.frame.size.width, 500.1);
        piece.frame = imageFrame;
        
    }
    */
    /*
    if(imageFrame.size.width > 500)
    {
        imageFrame.size = CGSizeMake(500, 500);
    }
     */
    
  /*
    NSLog(@"Finalscale. self.frame.origin (%f,%f)", self.frame.origin.x, self.frame.origin.x);
    NSLog(@"Finalscale. self.frame.size (%f,%f)", self.frame.size.width, self.frame.size.height);
    NSLog(@"Finalscale. piece.frame.origin (%f,%f)", piece.frame.origin.x, piece.frame.origin.x);
    NSLog(@"Finalscale. piece.frame.size (%f,%f)", piece.frame.size.width, piece.frame.size.height);
    NSLog(@"Finalscale. _imageView.frame.origin (%f,%f) ", _imageView.frame.origin.x, _imageView.frame.origin.x);
    NSLog(@"Finalscale. _imageView.frame.size (%f,%f) ", _imageView.frame.size.width, _imageView.frame.size.height);
    */
    _previousScale = currentScale;
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
        [gestureRecognizer state] == UIGestureRecognizerStateCancelled ||
        [gestureRecognizer state] == UIGestureRecognizerStateFailed)
    {
        // Gesture can fail (or cancelled?) when the notification and the object is dragged simultaneously
        _scale = currentScale;

    }
}

- (void)handlePinchGesture:(id)sender
{
  	//[_imageview bringSubviewToFront:[(UIPinchGestureRecognizer*)sender view]];
    
	if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
		lastScale = 1.0;
		return;
	}
    
	CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    
	CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
	CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
	[[(UIPinchGestureRecognizer*)sender view] setTransform:newTransform];
    
	lastScale = [(UIPinchGestureRecognizer*)sender scale];
    
    //return;
}

-(void)move:(id)sender {
    
    UIView *piece = [(UITapGestureRecognizer*)sender view];
    
    //[self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged)
    {
        /*
        NSLog(@"move. piece.frame.origin (%f,%f)", piece.frame.origin.x, piece.frame.origin.x);
        NSLog(@"move. piece.frame.size (%f,%f)", piece.frame.size.width, piece.frame.size.height);
        NSLog(@"move. _imageView.frame.origin (%f,%f) ", _imageView.frame.origin.x, _imageView.frame.origin.x);
        NSLog(@"move. _imageView.frame.size (%f,%f) ", _imageView.frame.size.width, _imageView.frame.size.height);
        */
        CGPoint translation = [sender translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [sender setTranslation:CGPointZero inView:[piece superview]];
        /*
        NSLog(@"move. final. piece.frame.origin (%f,%f)", piece.frame.origin.x, piece.frame.origin.x);
        NSLog(@"move. final. piece.frame.size (%f,%f)", piece.frame.size.width, piece.frame.size.height);
        NSLog(@"move. final. _imageView.frame.origin (%f,%f) ", _imageView.frame.origin.x, _imageView.frame.origin.x);
        NSLog(@"move. final. _imageView.frame.size (%f,%f) ", _imageView.frame.size.width, _imageView.frame.size.height);
         */
    }
    
    /*
	//[[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
	//[self.view bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        
		firstX = [self center].x;
		firstY = [self  center].y;
	}
    
	translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
	[[sender view] setCenter:translatedPoint];
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
		CGFloat finalX = translatedPoint.x + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self].x);
		CGFloat finalY = translatedPoint.y + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self].y);
        
		if(UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            
			if(finalX < 0)
            {
                finalX = 0;
            }
            else if(finalX > 768)
            {
                
				finalX = 768;
			}
            
			if(finalY < 0)
            {
                finalY = 0;
            }
            else if(finalY > 1024) {
                
				finalY = 1024;
			}
		}
        
		else {
            
			if(finalX < 0) {
                finalX = 0;
            }
            else if(finalX > 1024) {
                
				finalX = 768;
			}
            
			if(finalY < 0)
            {
                finalY = 0;
            }
            else if(finalY > 768)
            {
                finalY = 1024;
			}
		}
        
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.35];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[[sender view] setCenter:CGPointMake(finalX, finalY)];
		[UIView commitAnimations];
	}
     */
}


/*
 UIButton* _invisibleButton;
 - (void)pressedInvisibleButton:(id)button
 {
 [_imageView resignFirstResponder];
 _imageView.userInteractionEnabled = NO;
 [_invisibleButton removeFromSuperview];
 _invisibleButton=nil;
 
 }
*/

- (void)tapped:(id)sender
{
    /*
    _imageView.userInteractionEnabled = !_imageView.userInteractionEnabled;
    if(_imageView.userInteractionEnabled)
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
        [_imageView becomeFirstResponder];
    }
     */

}


- (void)layoutSubviews
{
  
    /*
    NSLog(@"layoutSubviews called");
    NSLog(@"layoutSubiew. initial  self.frame.origin = (/%f,%f)",self.frame.origin.x,self.frame.origin.y);
    NSLog(@"layoutSubiew. initial self.frame.size = (/%f,%f)",self.frame.size.width,self.frame.size.height);
    
    
    NSLog(@"layoutSubiew. initial  _imageView.frame.origin = (/%f,%f)",_imageView.frame.origin.x,_imageView.frame.origin.y);
    NSLog(@"layoutSubiew. initial _imageView.frame.size = (/%f,%f)",_imageView.frame.size.width,_imageView.frame.size.height);
    */
    
    
    //Find new size of image
    CGRect imageFrame;
    //imageFrame = self.frame;
    imageFrame.origin = CGPointMake(0.0f, 0.0f);
    //imageFrame.origin = self.frame.origin;
    //imageFrame.origin = CGPointMake(self.frame.origin.x, self.frame.origin.y);
    
    if(!started)
    {
        imageFrame.size = CGSizeMake(_imageView.frame.size.width, _imageView.frame.size.height);
        started = true;
    }
    else{
        imageFrame.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }

  
    //Make this view and the image the same size
    CGRect selfFrame = self.frame;
    selfFrame.size = imageFrame.size;
    self.frame = selfFrame;

    _imageView.frame = imageFrame;

    /*
    NSLog(@"layoutSubiew. final  self.frame.origin = (/%f,%f)",self.frame.origin.x,self.frame.origin.y);
    NSLog(@"layoutSubiew. final  self.frame.size = (/%f,%f)",self.frame.size.width,self.frame.size.height);
    NSLog(@"layoutSubiew. final  _imageView.frame.origin = (/%f,%f)",_imageView.frame.origin.x,_imageView.frame.origin.y);
    NSLog(@"layoutSubiew. final _imageView.frame.size = (/%f,%f)",_imageView.frame.size.width,_imageView.frame.size.height);
*/

}


/*
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
*/

@end
