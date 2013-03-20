//
//  ResourceView.m
//  PhotoChat
//
//  Created by Umar Rashid on 17/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "ResourceView.h"
#import <QuartzCore/QuartzCore.h>
#import "GUIConstant.h"

@interface ResourceView()
{
@private
    CGRect _safeArea;
    UIImageView* _imageView;
    int _styleId;
}

@property UIImageView* deleteView;
@property UIImageView* scaleView;
@property UIImageView* rotateView;
@property CGPoint prevPoint;
@property BOOL isScaling;
@property CGAffineTransform rotateTransform;
@property float deltaAngle;
@property int gestureAction;

@end

@implementation ResourceView
@synthesize scale;
@synthesize resourceId;
@synthesize urlImageString;
@synthesize type;
@synthesize styleId = _styleId;
@synthesize imageView = _imageView;
@synthesize longPressed;
@synthesize actionPerformed;
@synthesize angle;
@synthesize resource;

UITapGestureRecognizer *resourceTapRecognizer;
UITapGestureRecognizer *deleteGesture;
UIPanGestureRecognizer *panGesture;
UIRotationGestureRecognizer* rotationGesture;
UIPinchGestureRecognizer *pinchGesture;

CGPoint initiallocPoint;
CGPoint initialCentrePoint;

CGFloat lastScale = 1.0;
float firstX;
float firstY;
BOOL started = false;

CGFloat _scale = 1.0;
CGFloat _previousScale = 1.0;
float MAX_SCALE = 1.05;
float MIN_SCALE = 0.90;
BOOL alertShown;

CGFloat originalDiagonal;
CGFloat originalWidth;
CGRect originalBounds;
                                 

#define PADDING 25.0
#define kNONE 0
#define kSCALE 1
#define kROTATE 2
#define kTRANSLATE 3

#define DISTANCE_FROM_CONTROL 30.0
#define MAXWIDTH 1400
#define MINWIDTH 115



- (id)initWithFrame:(CGRect)frame andResource:(Resource*)resourceSent andScale:(float)scaleSent andAngle:(float)angleSent
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        if(resourceSent!=nil)
        {
            self.frame = frame;
            
            self.resource = resourceSent;
            self.urlImageString = resource.imageURL;
            self.type = resource.type;
            self.resourceId = resource.resourceId;
            self.scale = scaleSent;
            self.angle = angleSent;
            
            
            NSData *imageURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:resource.imageURL]];
            UIImage *image = [UIImage imageWithData:imageURL];
            
            _imageView = [[UIImageView alloc] initWithImage:image];
            _imageView.userInteractionEnabled = NO;
            /*
            NSLog(@"original imageview.frame=%@", NSStringFromCGRect(_imageView.frame));
            NSLog(@"original imageview.bounds%@", NSStringFromCGRect(_imageView.bounds));
            NSLog(@"original self.scale%f", self.scale);
            NSLog(@"original self.angle%f", self.angle);
            */
            originalBounds = _imageView.frame;
            originalWidth = CGRectGetWidth(originalBounds);
            originalDiagonal = sqrtf(CGRectGetHeight(originalBounds)*CGRectGetHeight(originalBounds) +
                                     CGRectGetWidth(originalBounds)*CGRectGetWidth(originalBounds) );
            [_imageView setFrame:CGRectMake(0.0,0.0,_imageView.frame.size.width*self.scale, _imageView.frame.size.height*self.scale)];
            [self addSubview:_imageView];
            
            //[self.imageView setFrame:CGRectMake(0.0,0.0,self.imageView.frame.size.width*self.scale, self.imageView.frame.size.height*self.scale)];
            //[self addSubview:self.imageView];
            
            
            
            
            if([resource.type isEqual:@"d"])
            {
                    
                    CGRect selfFrame = self.frame;
                    selfFrame.size = _imageView.frame.size;
                    self.frame = selfFrame;
                    
                    //self.transform = CGAffineTransformScale(self.transform, self.scale, self.scale);
                    //NSLog(@"self.angle=%f", self.angle);
                    self.transform = CGAffineTransformMakeRotation(self.angle);
                
                //NSLog(@"original self.frame=%@", NSStringFromCGRect(self.frame));
                //NSLog(@"original self.bounds%@", NSStringFromCGRect(self.bounds));
            }
            
            else if([self.type isEqual:@"f"])
            {
                
                [_imageView setFrame:CGRectMake(0.0,0.0,self.frame.size.width, self.frame.size.height)];
                //_imageView.frame = self.frame;
                
            }
            
            
            alertShown = NO;
            longPressed = NO;
            actionPerformed = NO;

            
            
            resourceTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
            resourceTapRecognizer.cancelsTouchesInView = NO;
            [self addGestureRecognizer:resourceTapRecognizer];
            
        }//end if resource!=nil
    }//end if self
    return self;    
}


- (void)handleTapGesture:(UITapGestureRecognizer*)sender
{
    //NSLog(@"handleTapGesture.self.type=%@", self.type);
    if([self.type isEqual:@"d"])
    {
        
        for (UIView *subview in self.superview.subviews)
        {
            if([subview isKindOfClass:[ResourceView class]])
            {
                
                ResourceView* sbv =(ResourceView*)subview;
                [sbv disappearControls];
                
            }//end if
        }//end for
        
        
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.layer.borderColor = [[UIColor blackColor] CGColor];
        self.imageView.layer.borderWidth = 2.0;
        [self setupScaleView];
        [self setupDeleteView];
        [self setupDeleteGesture];
        [self setupPanGesture];
        //[self setUpPinchGesture];
        [self setupDeleteGesture];
        [self setupRotateView];
        [self setupRotationGesture];
    }
    else if([self.type isEqual:@"f"])
    {
        
        if(!alertShown)
        {
            alertShown = YES;
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Delete Resource"
                                                              message:@"Delete resource from the image."
                                                             delegate:self
                                                    cancelButtonTitle:@"Delete"
                                                    otherButtonTitles:@"Cancel", nil];
            [message show];
            
        }
    }
    

}

-(void)disappearControls{
    
    //NSLog(@"disappearControls.");
    self.imageView.layer.borderColor = [[UIColor clearColor] CGColor];
    self.imageView.layer.borderWidth = 2.0;
    //NSLog(@"self.subviews.count=%i", self.subviews.count);
    [self.deleteView removeGestureRecognizer:deleteGesture];
    [self.rotateView removeGestureRecognizer:rotationGesture];
    [self removeGestureRecognizer:panGesture];
    //[self removeGestureRecognizer:pinchGesture];
    
    //Remove scale, rotate and delete subivews
    for(UIView* subview in self.subviews)
    {
        if(subview.tag==1 || subview.tag==2 || subview.tag==3)
        {
            [subview removeFromSuperview];
        }
        
    }
    
}
//- (void)handleLongPress:(id)gestureRecognizer
- (void)handleLongPress:(UILongPressGestureRecognizer*)sender
{
    
    if(!alertShown)
    {
        alertShown = YES;
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Delete Resource"
                                                          message:@"Delete resource from the image."
                                                         delegate:self
                                                cancelButtonTitle:@"Delete"
                                                otherButtonTitles:@"Cancel", nil];
        [message show];
        
    }

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Delete"])
    {

        if([self.type isEqualToString:@"d"])
        {
            for(UIView* subview in self.subviews)
            {
                [subview removeFromSuperview];
            }
        }//end if

        [self removeFromSuperview];
        alertShown = NO;
    }
    if([title isEqualToString:@"Cancel"])
    {
        alertShown = NO;
        return;
    }
}


-(void)setupScaleView{
    self.scaleView = [[UIImageView alloc] initWithFrame:[self calculateScaleViewFrame]];
    self.scaleView.image = [UIImage imageNamed:@"scale"];
    self.scaleView.userInteractionEnabled = YES;
    self.scaleView.tag = 1;
    [self addSubview:self.scaleView];
}


-(void)setupDeleteView{
    self.deleteView = [[UIImageView alloc] initWithFrame:[self calculateDeleteViewFrame]];
    self.deleteView.image = [UIImage imageNamed:@"close_gold"];
    self.deleteView.userInteractionEnabled = YES;
    self.deleteView.tag = 2;
    [self addSubview:self.deleteView];
}

-(CGRect)calculateDeleteViewFrame{
    return CGRectMake(0.0, 0.0, PADDING, PADDING);
}

-(CGRect)calculateScaleViewFrame{
    return CGRectMake(self.bounds.size.width - PADDING, self.bounds.size.height - PADDING, PADDING, PADDING);
}

-(void)setupDeleteGesture
{
    deleteGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTap:)];
    [self.deleteView addGestureRecognizer:deleteGesture];
    
}

-(void)deleteTap:(UITapGestureRecognizer*)recognizer{
    //NSLog(@"deleteTap.");
    //UIView * delete = (UIView *)[recognizer view];
    //[delete.superview removeFromSuperview];
    
    if(!alertShown)
    {
        alertShown = YES;
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Delete Resource"
                                                          message:@"Delete resource from the image."
                                                         delegate:self
                                                cancelButtonTitle:@"Delete"
                                                otherButtonTitles:@"Cancel", nil];
        [message show];
        
    }
}

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *mainView = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:mainView];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:mainView.superview];
        
        mainView.layer.anchorPoint = CGPointMake(locationInView.x / mainView.bounds.size.width, locationInView.y / mainView.bounds.size.height);
        mainView.center = locationInSuperview;
    }
}

-(void)setupPanGesture
{
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
    
}

-(void)setUpPinchGesture
{
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [self addGestureRecognizer:pinchGesture];
}

-(int)detectActionUsingGesturePointLocation:(CGPoint)point{
    CGRect scaleViewRect = [self convertRect:self.scaleView.frame toView:self.superview];
    CGRect rotateViewRect = [self convertRect:self.rotateView.frame toView:self.superview];
    
    scaleViewRect = CGRectInset(scaleViewRect, -1 * DISTANCE_FROM_CONTROL, -1 * DISTANCE_FROM_CONTROL);
    rotateViewRect = CGRectInset(rotateViewRect, -1 * DISTANCE_FROM_CONTROL, -1 * DISTANCE_FROM_CONTROL);
    
    if (CGRectContainsPoint(scaleViewRect, point))
        return kSCALE;
    else
    if (CGRectContainsPoint(rotateViewRect, point))
        return kROTATE;
    else
        return kTRANSLATE;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"handlePanGesture.");

    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        
        CGPoint winGestureLoc = [gestureRecognizer locationInView:self.superview];
        self.gestureAction = [self detectActionUsingGesturePointLocation:winGestureLoc];
    }
    if (self.gestureAction == kSCALE){
        [self scaleView:gestureRecognizer];
    }else
    if (self.gestureAction == kROTATE){
        
        initiallocPoint = [gestureRecognizer locationInView:self.superview];
        initialCentrePoint = [self convertPoint:self.center toView:self.superview];
        
        [self rotateViewWithControl:gestureRecognizer];
    }else{
        [self translateView:gestureRecognizer];
    }
}


-(void)translateView:(UIPanGestureRecognizer *)gestureRecognizer{
    UIView *mainView = [gestureRecognizer view];
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:self.superview];
        
        [mainView setCenter:CGPointMake([mainView center].x + translation.x, [mainView center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[mainView superview]];
    }
}

-(void)scaleView:(UIPanGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"scaleView:gestureRecognizer.");
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        self.prevPoint = [gestureRecognizer locationInView:self.superview];
        [self setNeedsDisplay];
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        
        CGPoint changedPoint = [gestureRecognizer locationInView:self.superview];
        CGFloat deltaW = changedPoint.x - self.prevPoint.x;
        CGFloat deltaH = changedPoint.y - self.prevPoint.y;
        CGFloat deltaNet = MAX(deltaH, deltaW);
        //self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width + deltaW, self.bounds.size.height + deltaH);
        self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width + deltaNet,
                                 self.bounds.size.height + deltaNet);
        /*
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width,
                                 self.bounds.size.height);
        
        _imageView.frame = CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, self.bounds.size.width,
                                      self.bounds.size.height);
        _imageView.bounds = CGRectMake(_imageView.bounds.origin.x, _imageView.bounds.origin.y, self.bounds.size.width,
                                       self.bounds.size.height);
        */
        
        //_imageView.frame = CGRectMake(PADDING/2, PADDING/2, self.bounds.size.width - PADDING, self.bounds.size.height - PADDING);
        _imageView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
        
        /*
        CGRect selfFrame = self.frame;
        selfFrame.size = _imageView.frame.size;
        self.frame = selfFrame;
         */
        //self.imageView.frame = [self calculateImageViewFrame];
        
        
        
        self.deleteView.frame = [self calculateDeleteViewFrame];
        self.scaleView.frame = [self calculateScaleViewFrame];
        self.rotateView.frame = [self calculateRotateViewFrame];
        self.prevPoint = [gestureRecognizer locationInView:self.superview];
        [self setNeedsDisplay];
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        self.prevPoint = [gestureRecognizer locationInView:self.superview];
        [self setNeedsDisplay];
        self.gestureAction = kNONE;
        
        /*
        NSLog(@"new self.frame=%@", NSStringFromCGRect(self.frame));
        NSLog(@"new self.bounds%@", NSStringFromCGRect(self.bounds));
        NSLog(@"new self.imageview.frame=%@", NSStringFromCGRect(self.imageView.frame));
        NSLog(@"new self.imageview.bounds%@", NSStringFromCGRect(self.imageView.bounds));
        */
        self.scale = _imageView.bounds.size.width/originalWidth;
        //CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        //NSLog(@"self.scale=%f", self.scale);
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateCancelled)
    {
        self.gestureAction = kNONE;
    }
}

-(void)rotateViewWithControl:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint locPoint = [gestureRecognizer locationInView:self.superview];
    CGPoint centrePoint = [self convertPoint:self.center toView:self.superview];
    /*
    NSLog(@"before start, initialLocPoint=%f,%f", initiallocPoint.x, initiallocPoint.y);
    NSLog(@"before start, initialCentrePoint=%f,%f", initialCentrePoint.x, initialCentrePoint.y);
    NSLog(@"before start, locPoint=%f,%f", locPoint.x, locPoint.y);
    NSLog(@"before start, centrePoint=%f,%f", centrePoint.x, centrePoint.y);
    */
    float angleDiff = 0.0;
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        self.rotateTransform = self.transform;
        self.deltaAngle = atan2(locPoint.y-centrePoint.y, locPoint.x- centrePoint.x);
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        float angleView = atan2(locPoint.y-centrePoint.y, locPoint.x- centrePoint.x);
        angleDiff = self.deltaAngle - angleView;
        self.transform = CGAffineTransformMakeRotation(-angleDiff);
        [self setNeedsDisplay];
        self.angle = -angleDiff;
        //NSLog(@"changed.angleDiff=%f", -angleDiff);
        //NSLog(@"changed.locPoint=%f,%f", locPoint.x, locPoint.y);
        //NSLog(@"changed.centrePoint=%f,%f", centrePoint.x, centrePoint.y);
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        self.rotateTransform = self.transform;
        [self setNeedsDisplay];
        self.gestureAction = kNONE;
        //self.angle = -angleDiff;
        //self.angle = atan2(locPoint.y-initialCentrePoint.y, locPoint.x- initialCentrePoint.x);
        //NSLog(@"ended.self.angle=%f", self.angle);
        //NSLog(@"ended.locPoint=%f,%f", locPoint.x, locPoint.y);
        //NSLog(@"ended.centrePoint=%f,%f", centrePoint.x, centrePoint.y);
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateCancelled)
    {
        self.rotateTransform = self.transform;
        self.gestureAction = kNONE;
        //self.angle = -angleDiff;
        /*
        NSLog(@"cancelled.self.angle =-angleDiff=%f", self.angle);
        NSLog(@"cancelled.locPoint=%f,%f", locPoint.x, locPoint.y);
        NSLog(@"cancelled.centrePoint=%f,%f", centrePoint.x, centrePoint.y);
         */
    }
}

-(void)rotateView:(UIRotationGestureRecognizer *)gestureRecognizer{
    //NSLog(@"rotateView:(UIRotationGestureRecognizer *)gestureRecognizer");
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
    }
}

-(CGRect)calculateImageViewFrame{
    return CGRectMake(PADDING/2, PADDING/2, self.bounds.size.width - PADDING, self.bounds.size.height - PADDING);
    //return CGRectMake(PADDING/2, PADDING/2, self.imageView.bounds.size.width - PADDING, self.imageView.bounds.size.height - PADDING);
}


-(CGRect)calculateRotateViewFrame{
    return CGRectMake(0.0, self.bounds.size.height - PADDING, PADDING, PADDING);
}

-(void)setupRotateView{
    self.rotateView = [[UIImageView alloc] initWithFrame:[self calculateRotateViewFrame]];
    self.rotateView.image = [UIImage imageNamed:@"rotate"];
    self.rotateView.tag=3;
    self.rotateView.userInteractionEnabled = YES;
    [self addSubview:self.rotateView];
}

-(void)setupRotationGesture
{
    rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [self addGestureRecognizer:rotationGesture];
}


@end
