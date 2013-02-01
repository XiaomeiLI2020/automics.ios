//
//  PanelEditViewController.m
//  PhotoChat
//
//  Created by horizon on 30/01/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "PanelEditViewController.h"
#import "ImageScaleCatagory.h"

@interface PanelEditViewController ()
@property UIImageView* resourceImageView;
@end

@implementation PanelEditViewController

#define PADDING_LEFT 5.0
#define PADDING_TOP 5.0

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[_backgroundPhotoView setImage:[_photo scaleToSize:CGSizeMake(640.0, 640.0)]];
    [_backgroundPhotoView setImage:[self squareImageWithImage:_photo scaledToSize:CGSizeMake(640.0, 640.0)]];
    [self addResourceImageView];
    
}

-(void)addResourceImageView
{
    UIImage* scaleHandleImage = [UIImage imageNamed:@"scaleHandle"];
    UIImage* backgroundImage = [UIImage imageNamed:@"hat"];
    
    //main view
    self.resourceImageView = [[UIImageView alloc] init];
    CGSize resourceViewSize = [self calculateViewSizeWithBackgroundImage:backgroundImage scaleHandleImage:scaleHandleImage];
    self.resourceImageView.frame = CGRectMake(0.0, 0.0, resourceViewSize.width, resourceViewSize.height);
    
    //background view.
    UIImageView* backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    CGRect frame = backgroundView.frame;
    frame.origin = [self calculateBackgroundViewOriginWithImage:backgroundImage scaleHandleImage:scaleHandleImage];
    backgroundView.frame = frame;
    
    //scaleoverlay view.
    //top right handle.
    UIImageView* scaleHandle1 = [[UIImageView alloc] initWithImage:scaleHandleImage];
    frame = scaleHandle1.frame;
    frame.origin.x = backgroundImage.size.width - scaleHandleImage.size.width/2;
    frame.origin.y = 0.0;
    scaleHandle1.frame = frame;
    //bottom left handle
    UIImageView* scaleHandle2 = [[UIImageView alloc] initWithImage:scaleHandleImage];
    frame = scaleHandle2.frame;
    frame.origin.x = 0.0;
    frame.origin.y = backgroundImage.size.height - scaleHandleImage.size.height/2;
    scaleHandle2.frame = frame;
    //bottom right handle.
    UIImageView* scaleHandle3 = [[UIImageView alloc] initWithImage:scaleHandleImage];
    frame = scaleHandle3.frame;
    frame.origin.x = backgroundImage.size.width - scaleHandleImage.size.width/2;
    frame.origin.y = backgroundImage.size.height - scaleHandleImage.size.height/2;
    scaleHandle3.frame = frame;
    
    //add sub views to resourceImage.
    [self.resourceImageView addSubview:backgroundView];
    //add resource view on top of photo.
    [self.resourceImageView addSubview:scaleHandle1];
    [self.resourceImageView addSubview:scaleHandle2];
    [self.resourceImageView addSubview:scaleHandle3];
    //add on top of background photo view.
    [self.backgroundPhotoView addSubview:self.resourceImageView];
}

-(CGSize)calculateViewSizeWithBackgroundImage:(UIImage*)backgroundImage scaleHandleImage:(UIImage*)scaleHandle{
    CGSize resourceViewSize = CGSizeMake(scaleHandle.size.width + backgroundImage.size.width, scaleHandle.size.height + backgroundImage.size.height);
    return resourceViewSize;
}



-(CGPoint)calculateBackgroundViewOriginWithImage:(UIImage*)backgroundImage scaleHandleImage:(UIImage*)scaleHandle
{
    CGPoint origin = CGPointMake(scaleHandle.size.width/2, scaleHandle.size.height/2);
    return origin;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
