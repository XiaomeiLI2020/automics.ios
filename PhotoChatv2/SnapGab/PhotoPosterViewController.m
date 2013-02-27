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

@interface PhotoPosterViewController ()

@end

@implementation PhotoPosterViewController

@synthesize imageView;
@synthesize progressView;
@synthesize connection;
@synthesize image;
@synthesize imageURL;

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

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
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

    
    NSData *imageData = UIImageJPEGRepresentation(scaledImage, 1.0);
    NSString *imageString = [imageData base64EncodedString];
    //NSData *d = [NSData dataFromBase64String:imageString];
    
    NSMutableArray* placementsArray = [[NSMutableArray alloc] init];
    NSMutableArray* annotationsArray = [[NSMutableArray alloc] init];
    
    
    for (UIView *subview in self.view.subviews)
    {
        // add bubble data
        if([subview isMemberOfClass:[SpeechBubbleView class]])
        {
            SpeechBubbleView* sbv =(SpeechBubbleView*)subview;

            NSDictionary* annotation =
            [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                 
                                                 [NSNumber numberWithFloat:sbv.frame.origin.x],
                                                 [NSNumber numberWithFloat:sbv.frame.origin.y],
                                                 @"null",
                                                 sbv.textView.text,
                                                 [NSNumber numberWithInt:sbv.styleId],
                                                 nil]
                                        forKeys:
             [NSArray arrayWithObjects:@"xoff",@"yoff",@"foptions",@"text",@"bubble_style", nil]];
             [annotationsArray addObject:annotation];
            
        }//end add bubble data
        
      
        // add resource data
        if([subview isMemberOfClass:[ResourceView class]])
        {

            ResourceView* sbv =(ResourceView*)subview;

            NSDictionary* resource = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                            [NSNumber numberWithInt:sbv.resourceId],
                                                            [NSNumber numberWithFloat:sbv.frame.origin.x],
                                                            [NSNumber numberWithFloat:sbv.frame.origin.y],
                                                            [NSNumber numberWithFloat:1.0],
                                                            [NSNumber numberWithInt:1],
                                                            nil]
                                                   forKeys:
                        [NSArray arrayWithObjects:@"resource_id",@"xoff",@"yoff",@"scale",@"z_index", nil]];
            [placementsArray addObject:resource];
        }//end add resource data
       
    }//end for
    


    NSString*   myURLString = [NSString stringWithFormat:@"http://automicsapi.wp.horizon.ac.uk/v1/photo"];    
    NSError *writeErrorNew = nil;
    
    
    NSArray *objects = [NSArray arrayWithObjects:@"description", @"type.png", @"320", @"320", imageString, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"description",@"name", @"width", @"height", @"blob", nil];
    NSDictionary *questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"data"];
    //Create JSON object
    NSData *jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&writeErrorNew];

    NSURL *requestURLNew = [NSURL URLWithString:myURLString];
    NSMutableURLRequest *requestNew = [[NSMutableURLRequest alloc] init];
    [requestNew setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    //[requestNew setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    [requestNew setHTTPShouldHandleCookies:NO];
    [requestNew setTimeoutInterval:60];
    [requestNew setHTTPMethod:@"POST"];
    [requestNew setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestNew setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestNew setURL:requestURLNew];
   
    // setting the body of the post to the reqeust
    [requestNew setHTTPBody:jsonRequestData];


    // initiate connection request with the server
    self.connection = [[NSURLConnection alloc] initWithRequest:requestNew delegate:self];

    //self.progressView.progress = 0.0f;
    //self.progressView.alpha = 1.0f;
    
    if (!self.connection) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Upload Failure"
                              message: @"No Internet"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    else
    {
        self.connection = nil;

        NSURLResponse *responseURL;
        NSError *err;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:requestNew returningResponse:&responseURL error:&err];
        if(responseData)
        {

            //NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            //NSLog(@"responseData: %@", responseString);
            
            NSError *parseError = nil;
            
            id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&parseError];
            
            NSString* imageId = [jsonObject objectForKey:@"id"];
            NSLog(@"imageId=%@", imageId);


            //uploading panel
            myURLString = [NSString stringWithFormat:@"http://automicsapi.wp.horizon.ac.uk/v1/panel"];
                        
            objects = [NSArray arrayWithObjects:imageId, placementsArray, annotationsArray, nil];
            keys = [NSArray arrayWithObjects:@"photo_id", @"placements", @"annotations", nil];
            
            questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
            jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"data"];
            
            //Create JSON object
            jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&writeErrorNew];
            
            requestURLNew = [NSURL URLWithString:myURLString];
            requestNew = [[NSMutableURLRequest alloc] init];
            [requestNew setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            //[requestNew setCachePolicy:NSURLRequestUseProtocolCachePolicy];
            [requestNew setHTTPShouldHandleCookies:NO];
            [requestNew setTimeoutInterval:60];
            [requestNew setHTTPMethod:@"POST"];
            [requestNew setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [requestNew setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [requestNew setURL:requestURLNew];
            
            // setting the body of the post to the reqeust
            [requestNew setHTTPBody:jsonRequestData];
 
            
            // initiate connection request with the server
            self.connection = [[NSURLConnection alloc] initWithRequest:requestNew delegate:self];
            
            if(self.connection)
            {
                /*
                NSString *requestString = [[NSString alloc] initWithData:jsonRequestData encoding:NSUTF8StringEncoding];
                NSLog(@"requestData: %@", requestString);
                NSURLResponse *response;
                NSError *err;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:requestNew returningResponse:&response error:&err];
                NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSLog(@"responseData: %@", responseString);
                 */
                panelUploaded = YES;
            }
            
            
        }//end if response
        //NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        //NSLog(@"responseData: %@", responseString);
        
    }//end else

    //self.progressView.progress = 0.0f;
    //self.progressView.alpha = 1.0f;


}//end startUpload

- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    self.progressView.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
 
    NSLog(@"connectionDidFinishLoading. panelUploaded=%d", panelUploaded);
    if(panelUploaded)
    {
        panelUploaded=NO;
        UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Successful"
                          message: nil
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)connection:(NSURLConnection *) didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Failure"
                          message: @"Lost Connection"
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    self.progressView.alpha = 0.0f;
}

- (IBAction)cancelPressed:(id)sender {
    
    if(self.connection) [self.connection cancel];
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
@end
