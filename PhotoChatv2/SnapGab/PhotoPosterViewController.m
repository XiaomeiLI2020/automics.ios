//
//  PhotoPosterViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 11/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "PhotoPosterViewController.h"
#import "SpeechBubbleView.h"
#import "ResourceView.h"
#import "ImageScaleCatagory.h"
#import "NSData+Base64.h"
#import "Base64.h"
#import "User.h"
#import "Photo.h"
#import "Annotation.h"


@interface PhotoPosterViewController ()

@end

@implementation PhotoPosterViewController

@synthesize imageView;
@synthesize progressView;
@synthesize connection;
@synthesize image;
@synthesize imageURL;
@synthesize panelsLoader;
@synthesize photoLoader;

@synthesize placementsArray;
@synthesize annotationsArray;

BOOL panelUploaded;

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
	// Do any additional setup after loading the view.
    self.imageView.frame = CGRectMake(0.0, 40.0, 320.0, 320);
    self.imageView.image = self.image;
    
    panelsLoader = [[PanelLoader alloc] init];
    panelsLoader.delegate = self;
    
    photoLoader = [[PhotoLoader alloc] init];
    photoLoader.delegate = self;
    
    annotationsArray = [[NSMutableArray alloc] init];
    placementsArray = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [self startUpload];
}


- (void)startUpload
{
    panelUploaded = NO;
    
    if (self.connection) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Already Sending"
                              message: @"Upload one image at a time"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!self.imageView.image) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"No Image Available"
                              message: nil
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    // add image data
    UIImage* scaledImage;
  
    if( imageView.image.size.width > imageView.image.size.height )
        scaledImage = [imageView.image scaleProportionalToSize:CGSizeMake(960, 640)];
    else
        scaledImage = [imageView.image scaleProportionalToSize:CGSizeMake(640, 960)];

    Photo *photo = [[Photo alloc] init];
    photo.description = @"Photo description";
    photo.image = scaledImage;
    photo.name = @"phototype.png";
    photo.width = 320;
    photo.height = 320;
    
    for (UIView *subview in self.view.subviews)
    {
        // add bubble data
        if([subview isMemberOfClass:[SpeechBubbleView class]])
        {
            SpeechBubbleView* sbv =(SpeechBubbleView*)subview;
            
            Annotation *annotation = [[Annotation alloc] init];
            annotation.bubbleStyle = sbv.styleId;
            annotation.text = sbv.textView.text;
            annotation.xOffset = sbv.frame.origin.x;
            annotation.yOffset = sbv.frame.origin.y;
            
            [annotationsArray addObject:annotation];
            
        }//end add bubble data
        
      
        // add resource data
        if([subview isMemberOfClass:[ResourceView class]])
        {

            ResourceView* sbv =(ResourceView*)subview;
            
            Placement *placement = [[Placement alloc] init];
            placement.resourceId = sbv.resourceId;
            placement.xOffset = sbv.frame.origin.x;
            placement.yOffset = sbv.frame.origin.y;
            placement.scale = 1.0;
            placement.zIndex = 1;
            
            [placementsArray addObject:placement];
        }//end add resource data
       
    }//end for
    
    [photoLoader submitRequestPostPhoto:photo];
    
    self.progressView.progress = 0.0f;
    self.progressView.alpha = 1.0f;

}//end startUpload


- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    self.progressView.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
}

- (IBAction)cancelPressed:(id)sender {
    
    //if(self.connection) [self.connection cancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.progressView.alpha = 0.0f;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader *)loader didSavePanel:(NSString*)response{
    //NSLog(@"Panel saved: %@", response);
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Successful"
                          message: nil
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PhotoLoader functions.
-(void)PhotoLoader:(PhotoLoader *)photoLoader didUploadPhoto:(Photo*)photo{
    //NSLog(@"Photo uploaded %@", photo);
    
    if(photo!=nil)
    {
        int photoId = photo.photoId;
        
        //NSLog(@"Photo uploaded.photoId=%i", photoId);
        if(photoId > 0)
        {
            Panel *panel = [[Panel alloc] init];
            panel.photo = photo;
            panel.photo.photoId = photo.photoId;
            panel.photo.imageURL = NULL;
            
            panel.placements = [[NSArray alloc] initWithArray:placementsArray];
            panel.annotations = [[NSArray alloc] initWithArray:annotationsArray];
            
            [panelsLoader submitRequestPostPanel:panel];
        }//end if
    }//end if
}


@end
