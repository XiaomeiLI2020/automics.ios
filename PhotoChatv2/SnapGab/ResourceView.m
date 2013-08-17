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
@synthesize MAX_SCALE;
@synthesize MIN_SCALE;
@synthesize MAX_SIZE;
@synthesize MIN_SIZE;
@synthesize alertShown;

CGFloat originalDiagonal;
CGFloat originalWidth;
CGFloat originalHeight;
CGRect originalBounds;

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
CGFloat _previousScale;
/*
float MAX_SCALE = 1.05;
float MIN_SCALE = 0.70;
float MAX_SIZE = 600.0;
float MIN_SIZE = 90.0;
BOOL alertShown;

CGFloat originalDiagonal;
CGFloat originalWidth;
CGFloat originalHeight;
CGRect originalBounds;
*/                                 

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
        
        MAX_SIZE = 320.0;
        MIN_SIZE = 80.0;
        
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
            

            _imageView = [[UIImageView alloc] init];
            __weak UIImageView *imageView_ = _imageView;
            
            __weak ResourceView *self_ = self;

            NSFileManager* fileMgr = [NSFileManager defaultManager];
            //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            //NSString* imageName = [NSString stringWithFormat:@"%i.png", page];
            NSString* imageName = [NSString stringWithFormat:@"resourcePhoto%i.png", resource.resourceId];
            NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
            BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
            //NSLog(@"ResourceView. File %@ exists=%d", currentFile, fileExists);
            //NSLog(@"resource.imageURL=%@", resource.imageURL);
        
            
            if(!fileExists)
            {
                
                [_imageView setImageWithURL:[NSURL URLWithString:[resource.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                           placeholderImage:nil
                                    success:^(UIImage *imageDownloaded) {
                                        //NSLog(@"%@ successfully downloaded.", imageName);
                                        

                                        NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                        [data1 writeToFile:currentFile atomically:YES];

                                        imageView_.userInteractionEnabled = NO;
                                        //NSLog(@"original _imageView.image.size=%@", NSStringFromCGSize(imageDownloaded.size));
                                        //originalImageSize = imageDownloaded.size;
                                        //originalBounds = CGRectMake(0.0, 0.0,imageDownloaded.size.width,imageDownloaded.size.height);
                                        originalBounds = CGRectMake(0.0, 0.0,imageDownloaded.size.width/2.0,imageDownloaded.size.height/2.0);
                                        originalWidth = CGRectGetWidth(originalBounds);
                                        originalHeight = CGRectGetHeight(originalBounds);
                                        originalDiagonal = sqrtf(CGRectGetHeight(originalBounds)*CGRectGetHeight(originalBounds) +
                                                                 CGRectGetWidth(originalBounds)*CGRectGetWidth(originalBounds) );
                                        
                                        //NSLog(@"imageView_.originalBounds=%@", NSStringFromCGRect(originalBounds));
                                        //NSLog(@"imageView_.frame=%@", NSStringFromCGRect(imageView_.frame));
                                        //NSLog(@"originalHeight=%f, originalWidth=%f", originalHeight, originalWidth);
                                        //NSLog(@"self_.originalBounds=%@", NSStringFromCGRect(self_.bounds));
                                        //NSLog(@"self_.frame=%@", NSStringFromCGRect(self_.frame));
                                        
                                        if(originalHeight<=originalWidth)
                                        {
                                            self_.MAX_SCALE = self_.MAX_SIZE/originalHeight;
                                            self_.MIN_SCALE = self_.MIN_SIZE/originalHeight;
                                        }
                                        else{
                                            self_.MAX_SCALE = self_.MAX_SIZE/originalWidth;
                                            self_.MIN_SCALE = self_.MIN_SIZE/originalWidth;
                                        }
                                        

                                        //[imageView_ setFrame:CGRectMake(0.0,0.0,imageDownloaded.size.width*self_.scale, imageDownloaded.size.height*self_.scale)];
                                        [imageView_ setFrame:CGRectMake(0.0,0.0,originalWidth*self_.scale, originalHeight*self_.scale)];
                                        [self_ addSubview:imageView_];
                                        
                                        
                                        
                                        if([self_.resource.type isEqual:@"d"])
                                        {
                                            
                                            CGRect selfFrame = self_.frame;
                                            selfFrame.size = imageView_.frame.size;
                                            self_.frame = selfFrame;
                                            
                                            //NSLog(@"before rotation,imageView_.imageView_.Bounds=%@", NSStringFromCGRect(imageView_.bounds));
                                            //NSLog(@"before rotation,imageView_.frame=%@", NSStringFromCGRect(imageView_.frame));
                                            //NSLog(@"before rotation,self_.originalBounds=%@", NSStringFromCGRect(self_.bounds));
                                            //NSLog(@"before rotation,self_.frame=%@", NSStringFromCGRect(self_.frame));
                                            
                                            self_.transform = CGAffineTransformMakeRotation(self_.angle);
                                            
                                            //NSLog(@"after rotation,imageView_.bounds=%@", NSStringFromCGRect(imageView_.bounds));
                                            //NSLog(@"after rotation,imageView_.frame=%@", NSStringFromCGRect(imageView_.frame));
                                            //NSLog(@"after rotation,self_.originalBounds=%@", NSStringFromCGRect(self_.bounds));
                                            //NSLog(@"after rotation,self_.frame=%@", NSStringFromCGRect(self_.frame));
                                            
                                        }
                                        
                                        else if([self_.type isEqual:@"f"])
                                        {
                                            
                                            [imageView_ setFrame:CGRectMake(0.0,0.0,self_.frame.size.width, self_.frame.size.height)];
                                            //_imageView.frame = self.frame;
                                        }
                                        
                                        
                                        self_.alertShown = NO;
                                        self_.longPressed = NO;
                                        self_.actionPerformed = NO;
                                        
                                        
                                        resourceTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self_ action:@selector(handleTapGesture:)];
                                        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
                                        resourceTapRecognizer.cancelsTouchesInView = NO;
                                        [self_ addGestureRecognizer:resourceTapRecognizer];
                                        
                                    }
                                    failure:^(NSError *error) {
                                        NSLog(@"Failed to load resource image.");
                                    }];

            }//end if(!fileExists)

            else if(fileExists)
            {
                UIImage* image= [UIImage imageWithContentsOfFile:currentFile];
                //UIImage* image= [UIImage imageNamed:currentFile];
                [_imageView setImage:image];
                //_imageView.userInteractionEnabled = NO;
                _imageView.userInteractionEnabled = NO;
                //NSLog(@"original _imageView.image.size=%@", NSStringFromCGSize(imageDownloaded.size));
                //originalImageSize = imageDownloaded.size;
                //originalBounds = CGRectMake(0.0, 0.0,image.size.width,image.size.height);
                originalBounds = CGRectMake(0.0, 0.0,image.size.width/2.0,image.size.height/2.0);
                originalWidth = CGRectGetWidth(originalBounds);
                originalHeight = CGRectGetHeight(originalBounds);
                originalDiagonal = sqrtf(CGRectGetHeight(originalBounds)*CGRectGetHeight(originalBounds) +
                                         CGRectGetWidth(originalBounds)*CGRectGetWidth(originalBounds) );
                
                //NSLog(@"imageView_.originalBounds=%@", NSStringFromCGRect(originalBounds));
                //NSLog(@"imageView_.frame=%@", NSStringFromCGRect(imageView_.frame));
                //NSLog(@"self_.originalBounds=%@", NSStringFromCGRect(self_.bounds));
                //NSLog(@"self_.frame=%@", NSStringFromCGRect(self_.frame));
                
                if(originalHeight<=originalWidth)
                {
                    self_.MAX_SCALE = self_.MAX_SIZE/originalHeight;
                    self_.MIN_SCALE = self_.MIN_SIZE/originalHeight;
                }
                else{
                    self_.MAX_SCALE = self_.MAX_SIZE/originalWidth;
                    self_.MIN_SCALE = self_.MIN_SIZE/originalWidth;
                }
                
                //[_imageView setFrame:CGRectMake(0.0,0.0,image.size.width*self_.scale, image.size.height*self_.scale)];
                [_imageView setFrame:CGRectMake(0.0,0.0,originalWidth*self_.scale, originalHeight*self_.scale)];
                [self_ addSubview:_imageView];
                
                
                
                if([self_.resource.type isEqual:@"d"])
                {
                    
                    CGRect selfFrame = self_.frame;
                    selfFrame.size = imageView_.frame.size;
                    self_.frame = selfFrame;
                    
                    //NSLog(@"before rotation,imageView_.imageView_.Bounds=%@", NSStringFromCGRect(imageView_.bounds));
                    //NSLog(@"before rotation,imageView_.frame=%@", NSStringFromCGRect(imageView_.frame));
                    //NSLog(@"before rotation,self_.originalBounds=%@", NSStringFromCGRect(self_.bounds));
                    //NSLog(@"before rotation,self_.frame=%@", NSStringFromCGRect(self_.frame));
                    
                    self_.transform = CGAffineTransformMakeRotation(self_.angle);
                    
                    //NSLog(@"after rotation,imageView_.bounds=%@", NSStringFromCGRect(imageView_.bounds));
                    //NSLog(@"after rotation,imageView_.frame=%@", NSStringFromCGRect(imageView_.frame));
                    //NSLog(@"after rotation,self_.originalBounds=%@", NSStringFromCGRect(self_.bounds));
                    //NSLog(@"after rotation,self_.frame=%@", NSStringFromCGRect(self_.frame));
                    
                }
                
                else if([self_.type isEqual:@"f"])
                {
                    
                    [imageView_ setFrame:CGRectMake(0.0,0.0,self_.frame.size.width, self_.frame.size.height)];
                    //_imageView.frame = self.frame;
                }
                
                
                self_.alertShown = NO;
                self_.longPressed = NO;
                self_.actionPerformed = NO;
                
                
                resourceTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self_ action:@selector(handleTapGesture:)];
                //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
                resourceTapRecognizer.cancelsTouchesInView = NO;
                [self_ addGestureRecognizer:resourceTapRecognizer];

            }//end if(fileExists)


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
        
        //[self setupScaleView];
        [self setupDeleteView];
        //[self setupRotateView];
        
        [self setupDeleteGesture];
        [self setUpPinchGesture];
        [self setupPanGesture];
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


-(void)rotateView:(UIRotationGestureRecognizer*)gestureRecognizer
{
    //NSLog(@"rotateView.");
    // current value is past rotations + current rotation
	float rotation = self.angle + gestureRecognizer.rotation;
	self.transform = CGAffineTransformMakeRotation(rotation);
	
	// once the user has finsihed the rotate, save the new angle
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
		self.angle = rotation;
        self.rotateTransform = self.transform;
	}
    //NSLog(@"gestureRecognizer.rotation+self.deltaAngle=%f", self.angle);

}

- (void)scalePiece:(UIPinchGestureRecognizer*)gestureRecognizer
{
    NSLog(@"scalePiece");
    //NSLog(@"Scale: %f", [gestureRecognizer scale]);
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        //_previousScale = _scale;
        _previousScale = self.scale;
    }
    
    //CGFloat currentScale = MAX(MIN([gestureRecognizer scale] * _scale, MAX_SCALE), MIN_SCALE);
    CGFloat currentScale = MAX(MIN([gestureRecognizer scale] * self.scale, MAX_SCALE), MIN_SCALE);
    //currentScale = [gestureRecognizer scale] * _scale;
    CGFloat scaleStep = currentScale / _previousScale;
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        
        //NSLog(@"MAX_SCALE=%f, MIN_SCALE=%f, _previousScale=%f, currentScale=%g, scaleStep=%f", MAX_SCALE, MIN_SCALE, _previousScale, currentScale, scaleStep);
        
        self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width*scaleStep, self.bounds.size.height*scaleStep);
        _imageView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
        
        
        //self.imageView.frame = [self calculateImageViewFrame];
        self.deleteView.frame = [self calculateDeleteViewFrame];
        //self.scaleView.frame = [self calculateScaleViewFrame];
        //self.rotateView.frame = [self calculateRotateViewFrame];
        [self setNeedsDisplay];
        _previousScale = currentScale;
        //_previousScale = scaleStep;

    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
        [gestureRecognizer state] == UIGestureRecognizerStateCancelled ||
        [gestureRecognizer state] == UIGestureRecognizerStateFailed) {
        // Gesture can fail (or cancelled?) when the notification and the object is dragged simultaneously
        //_scale = currentScale;
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
        
        //NSLog(@"MAX_SCALE=%f, MIN_SCALE=%f, _previousScale=%f, currentScale=%g, scaleStep=%f, self.scale=%f", MAX_SCALE, MIN_SCALE, _previousScale, currentScale, scaleStep, self.scale);

    }
    
}



- (void)scalePiece1:(UIPinchGestureRecognizer*)gestureRecognizer
{
    //NSLog(@"scalePiece");
    //[self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    UIView *piece = [(UITapGestureRecognizer*)gestureRecognizer view];
    //NSLog(@"Scale: %f", [gestureRecognizer scale]);
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        
        //lastScale = [gestureRecognizer scale];
        _previousScale = _scale;
        
        self.deleteView.frame = [self calculateDeleteViewFrame];
        //self.scaleView.frame = [self calculateScaleViewFrame];
        //self.rotateView.frame = [self calculateRotateViewFrame];
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

    
    //NSLog(@"Final scale: %f", currentScale);
    /*
     if(piece.frame.size.width*currentScale > 80 && piece.frame.size.height*currentScale > 80
     && piece.frame.size.width*currentScale < 500 && piece.frame.size.height*currentScale < 500
     )
     */
    {
        piece.transform = CGAffineTransformScale([piece transform], currentScale, currentScale);
    }
    
    
       _previousScale = currentScale;
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
        [gestureRecognizer state] == UIGestureRecognizerStateCancelled ||
        [gestureRecognizer state] == UIGestureRecognizerStateFailed)
    {
        // Gesture can fail (or cancelled?) when the notification and the object is dragged simultaneously
        _scale = currentScale;
        
    }
}


-(void)disappearControls{
    
    //NSLog(@"disappearControls.");
    self.imageView.layer.borderColor = [[UIColor clearColor] CGColor];
    self.imageView.layer.borderWidth = 2.0;
    //NSLog(@"self.subviews.count=%i", self.subviews.count);
    [self.deleteView removeGestureRecognizer:deleteGesture];
    //[self.rotateView removeGestureRecognizer:rotationGesture];
    [self removeGestureRecognizer:panGesture];
    [self removeGestureRecognizer:pinchGesture];
    [self removeGestureRecognizer:rotationGesture];
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
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    
}

-(void)setUpPinchGesture
{
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [self addGestureRecognizer:pinchGesture];
}


- (void)handlePanGesture:(UIPanGestureRecognizer*)gestureRecognizer
{
    //NSLog(@"handlePanGesture.");
    UIView *mainView = [gestureRecognizer view];
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
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
    }//end if([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged)
    
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
