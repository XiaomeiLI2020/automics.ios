//
//  ResourceImageView.m
//  scaleView
//
//  Created by Shakir Ali on 11/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ResourceImageView.h"

@interface ResourceImageView ()

@property UIImageView* imageView;
@property UIImageView* deleteView;
@property UIImageView* scaleView;
@property UIImageView* rotateView;
@property CGPoint prevPoint;
@property BOOL isScaling;
@property CGAffineTransform rotateTransform;
@property float deltaAngle;
@property int gestureAction;

@end

@implementation ResourceImageView

#define PADDING 25.0
#define kNONE 0
#define kSCALE 1
#define kROTATE 2
#define kTRANSLATE 3

#define DISTANCE_FROM_CONTROL 30.0

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isScaling = NO;
        self.backgroundColor = [UIColor clearColor];
        [self setupImageViewWithImage:image];
        [self setupScaleView];
        [self setupDeleteView];
        [self setupRotateView];
        [self setupPanGesture];
        [self setupDeleteGesture];
        [self setupRotationGesture];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame imageURL:(NSString*)imageURLString
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSData *imageURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]];
        UIImage *image = [UIImage imageWithData:imageURL];
        
        self.isScaling = NO;
        self.backgroundColor = [UIColor clearColor];
        [self setupImageViewWithImage:image];
        [self setupScaleView];
        [self setupDeleteView];
        [self setupRotateView];
        [self setupPanGesture];
        [self setupDeleteGesture];
        [self setupRotationGesture];
    }
    return self;
}

-(void)setupImageViewWithImage:(UIImage*)image
{
    self.imageView = [[UIImageView alloc] initWithFrame:[self calculateImageViewFrame]];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.imageView.layer.borderWidth = 2.0;
    self.imageView.image = image;
    [self addSubview:self.imageView];
}

-(CGRect)calculateImageViewFrame{
    return CGRectMake(PADDING/2, PADDING/2, self.bounds.size.width - PADDING, self.bounds.size.height - PADDING);
}

-(CGRect)calculateDeleteViewFrame{
    return CGRectMake(0.0, 0.0, PADDING, PADDING);
}

-(CGRect)calculateScaleViewFrame{
    return CGRectMake(self.bounds.size.width - PADDING, self.bounds.size.height - PADDING, PADDING, PADDING);
}

-(CGRect)calculateRotateViewFrame{
    return CGRectMake(0.0, self.bounds.size.height - PADDING, PADDING, PADDING);
}

-(void)setupScaleView{
    self.scaleView = [[UIImageView alloc] initWithFrame:[self calculateScaleViewFrame]];
    self.scaleView.image = [UIImage imageNamed:@"scale"];
    self.scaleView.userInteractionEnabled = YES;
    [self addSubview:self.scaleView];
}

-(void)setupDeleteView{
    self.deleteView = [[UIImageView alloc] initWithFrame:[self calculateDeleteViewFrame]];
    self.deleteView.image = [UIImage imageNamed:@"close_gold"];
    self.deleteView.userInteractionEnabled = YES;
    [self addSubview:self.deleteView];
}

-(void)setupRotateView{
    self.rotateView = [[UIImageView alloc] initWithFrame:[self calculateRotateViewFrame]];
    self.rotateView.image = [UIImage imageNamed:@"rotate"];
    self.rotateView.userInteractionEnabled = YES;
    [self addSubview:self.rotateView];
}

-(void)setupRotationGesture
{
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [self addGestureRecognizer:rotationGesture];
}

-(void)setupDeleteGesture
{
    UITapGestureRecognizer *deleteGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTap:)];
    [self.deleteView addGestureRecognizer:deleteGesture];

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
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
}

-(int)detectActionUsingGesturePointLocation:(CGPoint)point{
    CGRect scaleViewRect = [self convertRect:self.scaleView.frame toView:self.superview];
    CGRect rotateViewRect = [self convertRect:self.rotateView.frame toView:self.superview];
    
    scaleViewRect = CGRectInset(scaleViewRect, -1 * DISTANCE_FROM_CONTROL, -1 * DISTANCE_FROM_CONTROL);
    rotateViewRect = CGRectInset(rotateViewRect, -1 * DISTANCE_FROM_CONTROL, -1 * DISTANCE_FROM_CONTROL);
    
    if (CGRectContainsPoint(scaleViewRect, point))
        return kSCALE;
    else if (CGRectContainsPoint(rotateViewRect, point))
        return kROTATE;
    else
        return kTRANSLATE;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
  
        CGPoint winGestureLoc = [gestureRecognizer locationInView:self.superview];
        self.gestureAction = [self detectActionUsingGesturePointLocation:winGestureLoc];
    }
    if (self.gestureAction == kSCALE){
        [self scaleView:gestureRecognizer];
    }else if (self.gestureAction == kROTATE){
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
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        self.prevPoint = [gestureRecognizer locationInView:self.superview];
        [self setNeedsDisplay];
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateChanged){
        CGPoint changedPoint = [gestureRecognizer locationInView:self.superview];
        CGFloat deltaW = changedPoint.x - self.prevPoint.x;
        CGFloat deltaH = changedPoint.y - self.prevPoint.y;
        CGFloat deltaNet = MAX(deltaH, deltaW);
        //self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width + deltaW, self.bounds.size.height + deltaH);
        self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width + deltaNet,
                                 self.bounds.size.height + deltaNet);
        self.imageView.frame = [self calculateImageViewFrame];
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
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateCancelled)
    {
        self.gestureAction = kNONE;
    }
}

-(void)rotateViewWithControl:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint locPoint = [gestureRecognizer locationInView:self.superview];
    CGPoint centrePoint = [self convertPoint:self.center toView:self.superview];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        self.rotateTransform = self.transform;
        self.deltaAngle = atan2(locPoint.y-centrePoint.y, locPoint.x- centrePoint.x);
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        float angle = atan2(locPoint.y-centrePoint.y, locPoint.x- centrePoint.x);
        float angleDiff = self.deltaAngle - angle;
        self.transform = CGAffineTransformMakeRotation(-angleDiff);
        [self setNeedsDisplay];
        
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        self.rotateTransform = self.transform;
        [self setNeedsDisplay];
        self.gestureAction = kNONE;
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateCancelled)
    {
        self.rotateTransform = self.transform;
        self.gestureAction = kNONE;
    }
}

-(void)rotateView:(UIRotationGestureRecognizer *)gestureRecognizer{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
 
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
    }
}

-(void)deleteTap:(UITapGestureRecognizer*)recognizer{
    UIView * delete = (UIView *)[recognizer view];
    [delete.superview removeFromSuperview];
}

@end
