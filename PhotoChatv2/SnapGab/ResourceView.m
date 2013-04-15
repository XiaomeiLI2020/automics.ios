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
#import "UIImageView+WebCache.h"


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
@synthesize imageView =_imageView;
@synthesize longPressed;
@synthesize actionPerformed;
@synthesize angle;
@synthesize resource;
@synthesize originalOrigin;
@synthesize originalImageSize;
@synthesize originalFrame;

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
CGFloat originalHeight;
CGRect originalBounds;
                                 

#define PADDING 25.0
#define kNONE 0
#define kSCALE 1
#define kROTATE 2
#define kTRANSLATE 3

#define DISTANCE_FROM_CONTROL 30.0
#define MAXWIDTH 1400
#define MINWIDTH 115


- (id)initWithResourceView:(ResourceView *)resourceView{
    self= resourceView;
    return self;
}

- (id)initWithFrame:(CGRect)frame andResource:(Resource*)resourceSent andScale:(float)scaleSent andAngle:(float)angleSent
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        if(resourceSent!=nil)
        {
            //self.frame = frame;
            
            //self.originalFrame = frame;
            
            //__weak ResourceView *self_ = self;
            
            self.resource = resourceSent;
            self.urlImageString = resource.imageURL;
            self.type = resource.type;
            self.resourceId = resource.resourceId;
            self.scale = scaleSent;
            self.angle = angleSent;
            
            //NSLog(@"original self.frame=%@", NSStringFromCGRect(self.frame));
            //NSLog(@"original self.bounds%@", NSStringFromCGRect(self.bounds));
            originalOrigin = frame.origin;
            
            
            //NSData *imageURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:resource.imageURL]];
            //UIImage *image = [UIImage imageWithData:imageURL];
            
            /*
             UIImageView *imageView = [[UIImageView alloc] init];
             [imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
             */
            
            /*
             NSLog(@"original imageview.frame=%@", NSStringFromCGRect(_imageView.frame));
             NSLog(@"original imageview.bounds%@", NSStringFromCGRect(_imageView.bounds));
             NSLog(@"original self.scale=%f", self.scale);
             NSLog(@"original self.angle=%f", self.angle);
             */
            
            //_imageView = [[UIImageView alloc] initWithImage:image];
            _imageView = [[UIImageView alloc] init];
            __weak UIImageView *imageView_ = _imageView;
            
            __weak ResourceView *self_ = self;
            //[_imageView setImageWithURL:[NSURL URLWithString:resource.imageURL]
            //           placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
            
            [_imageView setImageWithURL:[NSURL URLWithString:resource.imageURL]
                           placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]
                                    success:^(UIImage *imageDownloaded) {
                                        //NSLog(@"image successfully downloaded.");
                                        //_imageView.image = imageDownloaded;
                                        
                                        //NSLog(@"imageDownloaded.size=%@", NSStringFromCGSize(imageDownloaded.size));
                                        //NSLog(@"self_.scale=%f", self_.scale);
                                        
                                        //_imageView.userInteractionEnabled = NO;
                                        imageView_.userInteractionEnabled = NO;
                                        
                                        //NSLog(@"original _imageView.image.size=%@", NSStringFromCGSize(imageDownloaded.size));
                                        //originalImageSize = imageDownloaded.size;
                                        originalBounds = CGRectMake(0.0, 0.0,imageDownloaded.size.width,imageDownloaded.size.height);
                                        
                                        /*
                                        if(imageDownloaded.size.width>=imageDownloaded.size.height)
                                        {
                                            //NSLog(@"wider than taller");
                                            if(imageDownloaded.size.width>panelScrollObjWidth)
                                            {
                                                CGFloat scaleReversed = panelScrollObjWidth/imageDownloaded.size.width;
                                                originalBounds = CGRectMake(0.0, 0.0,panelScrollObjWidth,imageDownloaded.size.height*scaleReversed);
                                            }
                                            
                                        }
                                        

                                        
                                        else if(imageDownloaded.size.height>imageDownloaded.size.width)
                                        {
                                            //NSLog(@"taller than wider");
                                            if(imageDownloaded.size.height>panelScrollObjHeight)
                                            {
                                                CGFloat scaleReversed = panelScrollObjHeight/imageDownloaded.size.height;
                                                originalBounds = CGRectMake(0.0, 0.0,imageDownloaded.size.width*scaleReversed,panelScrollObjHeight);
                                            }
                                            
                                        }
                                        */
                                        
                                        originalWidth = CGRectGetWidth(originalBounds);
                                        originalHeight = CGRectGetHeight(originalBounds);
                                        originalDiagonal = sqrtf(CGRectGetHeight(originalBounds)*CGRectGetHeight(originalBounds) +
                                                                 CGRectGetWidth(originalBounds)*CGRectGetWidth(originalBounds) );
                                        
                                        [imageView_ setFrame:CGRectMake(0.0,0.0,originalWidth*self_.scale, originalHeight*self_.scale)];
                                        //[imageView_ setFrame:CGRectMake(0.0,0.0,imageDownloaded.size.width*self_.scale, imageDownloaded.size.height*self_.scale)];
                                        [self_ addSubview:imageView_];
                                        
                                        
                                        
                                        if([self_.resource.type isEqual:@"d"])
                                        {
                                            /*
                                            NSLog(@"original _imageView.image.size=%@", NSStringFromCGSize(_imageView.image.size));
                                            NSLog(@"original self.scale=%f", self.scale);
                                            NSLog(@"original self.angle=%f", self.angle);
                                            */
                                            //NSLog(@"original _imageView.frame=%@", NSStringFromCGRect(_imageView.frame));
                                            //NSLog(@"original imageview.bounds%@", NSStringFromCGRect(_imageView.bounds));
                                           
                                             //[_imageView setFrame:CGRectMake(0.0,0.0,200, 200)];
                                            
                                            CGRect selfFrame = self_.frame;
                                            selfFrame.size = imageView_.frame.size;
                                            self_.frame = selfFrame;
                                            
                                            //NSLog(@"after imageAdd, original self.frame=%@", NSStringFromCGRect(self_.frame));
                                            //NSLog(@"after imageAdd, self.bounds%@", NSStringFromCGRect(self_.bounds));
                                           // [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.x,_imageView.image.size.width*self.scale, _imageView.image.size.height*self.scale)];
                                            
                                            //self.transform = CGAffineTransformScale(self.transform, self.scale, self.scale);
                                            //NSLog(@"self.angle=%f", self.angle);
                                            self_.transform = CGAffineTransformMakeRotation(self_.angle);
                                            
                                            //NSLog(@"after rotation, self.frame=%@", NSStringFromCGRect(self.frame));
                                            //NSLog(@"after rotation, original self.bounds%@", NSStringFromCGRect(self.bounds));
                                        }
                                        
                                        else if([self_.type isEqual:@"f"])
                                            
                                        {
                                            
                                            [imageView_ setFrame:CGRectMake(0.0,0.0,self_.frame.size.width, self_.frame.size.height)];
                                            //_imageView.frame = self.frame;
                                            
                                        }
                                        
                                        
                                        alertShown = NO;
                                        self_.longPressed = NO;
                                        self_.actionPerformed = NO;
                                        
                                        resourceTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self_ action:@selector(handleTapGesture:)];
                                        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
                                        resourceTapRecognizer.cancelsTouchesInView = NO;
                                        [self_ addGestureRecognizer:resourceTapRecognizer];
                                        
                                        
                                    }
                                    failure:^(NSError *error) {
                                        UIAlertView *alert = [[UIAlertView alloc]
                                                              initWithTitle: @"Load failed"
                                                              message: @"Failed to load image"
                                                              delegate: nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                                        [alert show];
                                    }];
            /*
            _imageView.userInteractionEnabled = NO;

            NSLog(@"original _imageView.image.size=%@", NSStringFromCGSize(_imageView.image.size));
            originalBounds = CGRectMake(0.0, 0.0,_imageView.image.size.width,_imageView.image.size.height);
            originalWidth = CGRectGetWidth(originalBounds);
            originalDiagonal = sqrtf(CGRectGetHeight(originalBounds)*CGRectGetHeight(originalBounds) +
                                     CGRectGetWidth(originalBounds)*CGRectGetWidth(originalBounds) );
            [_imageView setFrame:CGRectMake(0.0,0.0,_imageView.image.size.width*self.scale, _imageView.image.size.height*self.scale)];
            //[_imageView setFrame:CGRectMake(0.0,0.0,_imageView.frame.size.width*self.scale, _imageView.frame.size.height*self.scale)];
            [self addSubview:_imageView];
            
            
            
            if([resource.type isEqual:@"d"])
            {
                NSLog(@"original _imageView.image.size=%@", NSStringFromCGSize(_imageView.image.size));
                NSLog(@"original self.scale=%f", self.scale);
                NSLog(@"original self.angle=%f", self.angle);
                NSLog(@"original _imageView.frame=%@", NSStringFromCGRect(_imageView.frame));
                NSLog(@"original imageview.bounds%@", NSStringFromCGRect(_imageView.bounds));
                //[_imageView setFrame:CGRectMake(0.0,0.0,200, 200)];
                
                    CGRect selfFrame = self.frame;
                    selfFrame.size = _imageView.frame.size;
                    self.frame = selfFrame;
                
                [self setFrame:CGRectMake(self.frame.origin.x,self.frame.origin.x,_imageView.image.size.width*self.scale, _imageView.image.size.height*self.scale)];
                
                    self.transform = CGAffineTransformScale(self.transform, self.scale, self.scale);
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
             */
            
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
        
        //NSLog(@"self.frame.origin=(%f,%f)", self.frame.origin.x, self.frame.origin.y);
        //NSLog(@"[mainView center]=(%f,%f)", [mainView center].x, [mainView center].y);

        //if(self.frame.origin.y+translation.y>=panelScrollYOrigin) //&& self.frame.origin.x+translation.x>=panelScrollXOrigin)
        {
            [mainView setCenter:CGPointMake([mainView center].x + translation.x, [mainView center].y + translation.y)];
            //NSLog(@"self.frame.origin changed=(%f,%f)", self.frame.origin.x, self.frame.origin.y);
            //NSLog(@"[mainView center] changed=(%f,%f)", [mainView center].x, [mainView center].y);
            [gestureRecognizer setTranslation:CGPointZero inView:[mainView superview]];
        }
        /*
        NSLog(@"self.frame.origin changed=(%f,%f)", self.frame.origin.x, self.frame.origin.y);
        NSLog(@"[mainView center] changed=(%f,%f)", [mainView center].x, [mainView center].y);
        [gestureRecognizer setTranslation:CGPointZero inView:[mainView superview]];
        //originalOrigin = self.frame.origin;
       */
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
        CGFloat scaleX = (self.bounds.size.width+deltaW)/self.bounds.size.width;
        CGFloat scaleY = (self.bounds.size.width+deltaH)/self.bounds.size.height;
        //NSLog(@"deltaW=%f, delateH=%f", deltaW, deltaH);
        //CGFloat deltaNet = MAX(deltaH, deltaW);
        CGFloat scaleNet = MAX(scaleX, scaleY);
        if(self.bounds.size.width > self.bounds.size.height)
            scaleNet = MIN(scaleX, scaleY);
        
        if(scaleNet>1.2)
            scaleNet = 1.2;
        if(scaleNet<0.8)
            scaleNet = 0.8;
        /*
        if(scaleX==1.00)
        {
            scaleNet=scaleY;
        }
        if(scaleY==1.00)
        {
            scaleNet=scaleX;
        }
         */
        //CGFloat deltaNet = MAX(deltaH, deltaW);
        //deltaNet = MAX(sqrtf(deltaH*deltaH), sqrt(deltaW*deltaW));

        //self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width + deltaW, self.bounds.size.height + deltaH);
        //NSLog(@"scaleX=%f, scaleY=%f, scaleNet=%f", scaleX, scaleY, scaleNet);

        //NSLog(@"pre-scaling self.frame=%@", NSStringFromCGRect(self.frame));
        //NSLog(@"pre-scaling new self.bounds%@", NSStringFromCGRect(self.bounds));
        
        self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width*scaleNet, self.bounds.size.height*scaleNet);
        /*
        if(self.frame.origin.y<panelScrollYOrigin)
        {
            self.frame = CGRectMake(self.frame.origin.x, panelScrollYOrigin, self.frame.size.width, self.frame.size.height);
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.frame.size.width, self.frame.size.height);
            //_imageView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
        }
         */
        _imageView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
        
        //NSLog(@"post-scaling self.frame=%@", NSStringFromCGRect(self.frame));
        //NSLog(@"post-scaling new self.bounds%@", NSStringFromCGRect(self.bounds));
        /*if(self.frame.origin.y<panelScrollYOrigin)
        {
            self.frame = CGRectMake(self.frame.origin.x, panelScrollYOrigin, self.frame.size.width,
                                    self.frame.size.height);
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
            //_imageView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
        }
         */
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
        CGFloat newDiagonal = sqrtf(CGRectGetHeight(_imageView.bounds)*CGRectGetHeight(_imageView.bounds) +
                                 CGRectGetWidth(_imageView.bounds)*CGRectGetWidth(_imageView.bounds) );
        
        //self.scale = _imageView.bounds.size.width/originalWidth;
        self.scale = newDiagonal/originalDiagonal;
        //NSLog(@"self.scaleX=%f, self.scaleY=%f, self.scaleDiagonal=%f", _imageView.bounds.size.width/originalWidth, _imageView.bounds.size.height/originalHeight, newDiagonal/originalDiagonal);
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
        /*
        if(self.frame.origin.y<panelScrollYOrigin)
        {
            self.angle=0.0;
            self.transform = CGAffineTransformMakeRotation(self.angle);
            [self setNeedsDisplay];
        }
        else
        */
        {
            [self setNeedsDisplay];
            self.angle = -angleDiff;
        }
        //[self setNeedsDisplay];
        //self.angle = -angleDiff;
        
        /*
        if(self.frame.origin.y<panelScrollYOrigin)
        {
            self.frame = CGRectMake(self.frame.origin.x, panelScrollYOrigin, self.frame.size.width,
                                    self.frame.size.height);
        }
        */
        
        //NSLog(@"changed.angleDiff=%f", -angleDiff);
        //NSLog(@"changed.locPoint=%f,%f", locPoint.x, locPoint.y);
        //NSLog(@"changed.centrePoint=%f,%f", centrePoint.x, centrePoint.y);
    }
    else if ([gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        self.rotateTransform = self.transform;
        [self setNeedsDisplay];
        self.gestureAction = kNONE;
        
        /*
        NSLog(@"new imageview.frame=%@", NSStringFromCGRect(_imageView.frame));
        NSLog(@"new imageview.bounds%@", NSStringFromCGRect(_imageView.bounds));
        NSLog(@"new self.frame=%@", NSStringFromCGRect(self.frame));
        NSLog(@"new self.bounds%@", NSStringFromCGRect(self.bounds));
 
 
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width,
                                      self.bounds.size.height);
        */
         //self.frame.size = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
        
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
