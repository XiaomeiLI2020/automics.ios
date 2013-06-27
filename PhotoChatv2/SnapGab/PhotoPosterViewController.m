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
#import "GUIConstant.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

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
@synthesize editMode;
@synthesize placementsArray;
@synthesize annotationsArray;
@synthesize editedPhoto;
@synthesize panelScrollView;

BOOL panelUploaded;
bool alertShown;

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
    //NSLog(@"Post.viewDidLoad.");
    
    // Add panels scrollview
    CGRect panelFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
    CGSize panelSize = CGSizeMake(panelWidth, panelHeight);
    //panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize andNumItems:numPanels];
    panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize andNumItems:1];
    panelScrollView.tag=0;
    panelScrollView.delegate=self;
    [self.view addSubview:panelScrollView];
    [panelScrollView layoutItems];

    
    self.imageView.frame = CGRectMake(0.0, 0.0, panelWidth, panelHeight);
    self.imageView.image = self.image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);
    [panelScrollView addSubview:imageView];
    
    panelsLoader = [[PanelLoader alloc] init];
    panelsLoader.delegate = self;
    
    photoLoader = [[PhotoLoader alloc] init];
    photoLoader.delegate = self;
    
    annotationsArray = [[NSMutableArray alloc] init];
    placementsArray = [[NSMutableArray alloc] init];
    
    alertShown= false;

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
    photo.image = imageView.image;
    //photo.image = [self imageFromView:self.view];
    photo.name = @"phototype.png";
    photo.width = 320.0;
    photo.height = 320.0;
    
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
            if(sbv.resource!=nil)
            {
                if(sbv.resource.resourceId>0)
                {
                    placement.resourceId = sbv.resource.resourceId;
                }
                
            }

            placement.xOffset = sbv.originalFrame.origin.x;
            placement.yOffset = sbv.originalFrame.origin.y;
            //sbv.transform = CGAffineTransformMakeRotation(sbv.angle);
            placement.scale = sbv.scale;
            placement.angle = sbv.angle;
            placement.zIndex = 1;
            [placementsArray addObject:placement];
            //sbv.transform = CGAffineTransformMakeRotation(sbv.angle);
            
            /*
            NSLog(@"PhotoPostView.posted sbv.originalFrame=%@", NSStringFromCGRect(sbv.originalFrame));
            NSLog(@"PhotoPostView.posted placement:(xOffSet, yOffSet)=(%f, %f)", placement.xOffset, placement.yOffset);
            NSLog(@"PhotoPostView.posted sbv.frame=%@", NSStringFromCGRect(sbv.frame));
            NSLog(@"PhotoPostView.posted sbv.bounds%@", NSStringFromCGRect(sbv.bounds));
            */
        }//end add resource data
       
    }//end for
    
    //NSLog(@"editMode=%d", editMode);
 
    if(editMode)
    {
        //Don't upload a new photo if panel is being edited
        if(editedPhoto!=nil)
        {
            int photoId = editedPhoto.photoId;
            
            //NSLog(@"Photo editedPhoto.photoId=%i", photoId);
            if(photoId > 0)
            {
                Panel *panel = [[Panel alloc] init];
                panel.photo = editedPhoto;
                panel.photo.photoId = editedPhoto.photoId;
                panel.photo.imageURL = NULL;
                
                panel.placements = [[NSArray alloc] initWithArray:placementsArray];
                panel.annotations = [[NSArray alloc] initWithArray:annotationsArray];
                
                NSURLRequest* urlRequest = [panelsLoader preparePanelRequestForPostPanel:panel];
                [self startOperation:urlRequest postDataRequestType:1];
                //[self startPanelOperation:urlRequest panelPlacements:placementsArray panelAnnotations:annotationsArray postDataRequestType:1];
                
                //[panelsLoader submitRequestPostPanel:panel];
            }//end if
        }//end if
        
    }
    else
    {
        //Upload a new photo if a new panel is being added
        NSURLRequest* urlRequest = [photoLoader preparePhotoRequestForPostPhoto:photo];
        //[self startOperation:urlRequest postDataRequestType:0];
        [self startPanelOperation:urlRequest panelPlacements:placementsArray panelAnnotations:annotationsArray postDataRequestType:0];
        //[photoLoader submitRequestPostPhoto:photo];
    }
     
    self.progressView.progress = 0.0f;
    self.progressView.alpha = 1.0f;
}//end startUpload


-(void)startOperation:(NSURLRequest*)urlRequest postDataRequestType:(int)postDataRequestType {
    //NSLog(@"PhotoPosterView.startOperation. new photo+plus uploading");
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.automicsEngine.delegate = self;
    MKNetworkOperation *operation = [appDelegate.automicsEngine postData:urlRequest
                                                       completionHandler:^(id twitPicURL) {
                                                           DLog(@"complete.");
                                                       }
                                                            errorHandler:^(NSError* error)
                                                        {
                                         DLog(@"error.");
                                         
                                                        }
                                     ];
    
    operation.postDataRequestType = postDataRequestType;
    operation.delegate = self;
    [appDelegate.automicsEngine enqueueOperation:operation];
    //self.dataFeedConnection = [operation urlConnection];
    NSLog(@"PhotoPosterView. startOperation. reachable=%d", [panelsLoader isReachable]);
    
    if(![panelsLoader isReachable])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Upload Failure"
                              message: @"Please upload when network connection is available."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }//end if
    else if([panelsLoader isReachable])
    {
        [operation onUploadProgressChanged:^(double progress) {
            
            //DLog(@"onUploadProgressChanged=%.2f, progress=%f", progress*100.0, progress);
            self.progressView.progress = (float)progress;
            
        }];
    }//end else


  }//end startOperation


-(void)startPanelOperation:(NSURLRequest*)urlRequest panelPlacements:(NSArray*)placements
          panelAnnotations:(NSArray*)annotations postDataRequestType:(int)postDataRequestType {
    //NSLog(@"PhotoPoster. startPanelOperation.");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.automicsEngine.delegate = self;
    MKNetworkOperation *operation = [appDelegate.automicsEngine postData:urlRequest
                                                       panelPlacements:placements panelAnnotations:annotations
                                                       completionHandler:^(id twitPicURL) {
                                                           //DLog(@"complete.");
                                                       }
                                                            errorHandler:^(NSError* error)
                                     {
                                         //DLog(@"error.");
                                         
                                     }
                                     ];
    
    operation.postDataRequestType = postDataRequestType;
    operation.delegate = self;
    [appDelegate.automicsEngine enqueueOperation:operation];
    //self.dataFeedConnection = [operation urlConnection];
    
    NSLog(@"PhotoPosterView. startPanelOperation. reachable=%d", [panelsLoader isReachable]);
    
    if(![panelsLoader isReachable])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Upload Failure"
                              message: @"Please upload when network connection is available."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }//end if
    else if([panelsLoader isReachable]){
        [operation onUploadProgressChanged:^(double progress) {
            
            //NSLog(@"PhotoPosterView. startPanelOperation. reachable=%d", [panelsLoader isReachable]);
            //DLog(@"onUploadProgressChanged=%.2f", progress*100.0);
            self.progressView.progress = (float)progress;
            /*
             if(progress==1.0)
             {
             UIAlertView *alert = [[UIAlertView alloc]
             initWithTitle: @"Upload Successful"
             message: nil
             delegate: self
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil];
             [alert show];
             }
             */
        }];

    }
    

}//end startOperation


- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    self.progressView.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
}

- (IBAction)cancelPressed:(id)sender {
    
    //if(self.connection) [self.connection cancel];
    //[self performSegueWithIdentifier:@"postToView" sender:self];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"OK"])
    {
        NSDictionary *dataDict = [NSDictionary dictionaryWithObject:@"New panel uploaded" forKey:@"panelnotification"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newPanelNotification" object:nil userInfo:dataDict];
        //alertShown = NO;
        [self performSegueWithIdentifier:@"postToView" sender:self];
        //[self dismissViewControllerAnimated:YES completion:nil];
    }//end if
}//end alertView

#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader *)loader didSavePanel:(NSString*)response{
    //NSLog(@"Panel saved: %@", response);
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Successful"
                          message: nil
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Failure"
                          message: @"Please upload when network connection is available."
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
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

-(void)PhotoLoader:(PhotoLoader*)photoLoader didFailWithError:(NSError*)error{
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Failure"
                          message: @"Please upload when network connection is available."
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark MKNetworkOperation functions.
-(void)MKNetworkOperation:(MKNetworkOperation *)operation didUploadPhoto:(Photo*)photo{
    NSLog(@"PhotoPosterView.MKNetworkOperation.didUploadPhotoPhoto uploaded %@", photo);
    
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
            
            NSURLRequest* urlRequest = [panelsLoader preparePanelRequestForPostPanel:panel];
            [self startOperation:urlRequest postDataRequestType:1];
            //[panelsLoader submitRequestPostPanel:panel];
        }//end if
    }//end if
}

-(void)MKNetworkOperation:(MKNetworkOperation *)loader didUploadPanel:(NSString*)response{
    NSLog(@"PhotoPosterView.MKNetworkOperation.didUploadPanel.Panel saved: %@", response);
    UIAlertView *message = [[UIAlertView alloc]
                            initWithTitle:@"Upload Successful"
                            message:nil
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
    [message show];
}

-(void)MKNetworkOperation:(MKNetworkOperation*)operation operationFailed:(NSString*)responseString{
    NSLog(@"PhotoPosterView.MKNetworkOperation.PhotoPosterViewController.operationFailedWithError: %@", responseString);
    /*
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Failure"
                          message: @"Upload will resume when network connection is available."
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    //if(!alertShown)
    {
        [alert show];
        //alertShown = YES;
    }
     */

}

/*
//-(void)MKNetworkEngine:(MKNetworkEngine*)automicsEngine didFreezeOperation:(NSString*)responseString;

//-(void)MKNetworkEngine:(MKNetworkEngine*)automicsEngine didFreezeOperation:(NSString*)responseString
-(void)MKNetworkEngine:(MKNetworkEngine*)automicsEngine didFreezeOperation:(NSString*)responseString
{
    NSLog(@"automicsEngine didFreezeOperation: %@", responseString);
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Failure"
                          message: @"Upload will resume when network connection is available."
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}
*/

#pragma rendering subviews into an image
- (UIImage*)imageFromView:(UIView*)view
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [view bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context
    CGContextSaveGState(context);
    // Center the context around the view's anchor point
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    // Apply the view's transform about the anchor point
    CGContextConcatCTM(context, [view transform]);
    // Offset by the portion of the bounds left of and above the anchor point
    CGContextTranslateCTM(context, -[view bounds].size.width * [[view layer] anchorPoint].x,
                          -[view bounds].size.height * [[view layer] anchorPoint].y);
    
    // Render the layer hierarchy to the current context
    [[view layer] renderInContext:context];
    
    // Restore the context
    CGContextRestoreGState(context);
    
    // Retrieve the screenshot image
    UIImage *imageWhole = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageWhole;
}

@end
