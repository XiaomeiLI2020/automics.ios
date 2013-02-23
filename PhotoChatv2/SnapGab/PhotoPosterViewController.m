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
    
    NSString* boundary = @"0cfOXe12Fj";
    
    //uploading on Automics I server
    NSURL* requestURL = [NSURL URLWithString:@"http://www.automics.net/automics/upload.php"];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSString* groupname = @"d1";
    NSString* groupname = [prefs objectForKey:@"groupname"];
    NSDictionary* _params = [NSDictionary dictionaryWithObject:groupname forKey:@"group_name"];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    

    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    UIImage* scaledImage;
  
    if( imageView.image.size.width > imageView.image.size.height )
        scaledImage = [imageView.image scaleProportionalToSize:CGSizeMake(960, 640)];
    else
        scaledImage = [imageView.image scaleProportionalToSize:CGSizeMake(640, 960)];

    NSData *imageData = UIImageJPEGRepresentation(scaledImage, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"image_file\"; filename=\"image.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //Make json
    NSMutableArray* panelArray = [[NSMutableArray alloc] init];
    
    NSMutableArray* placementsArray = [[NSMutableArray alloc] init];
    NSMutableArray* annotationsArray = [[NSMutableArray alloc] init];
    
    for (UIView *subview in self.view.subviews)
    {
        // add bubble data
        if([subview isMemberOfClass:[SpeechBubbleView class]])
        {
            SpeechBubbleView* sbv =(SpeechBubbleView*)subview;
            NSDictionary* bubble =
            [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
              @"bubble",
              [NSNumber numberWithFloat:sbv.frame.origin.x],
              [NSNumber numberWithFloat:sbv.frame.origin.y],
              [NSNumber numberWithFloat:sbv.frame.size.width],
              [NSNumber numberWithFloat:sbv.frame.size.height],
              sbv.textView.text,
              [NSNumber numberWithInt:sbv.styleId],
              nil]
                                        forKeys:
             [NSArray arrayWithObjects:@"c",@"x",@"y",@"w",@"h",@"t",@"s", nil]];
            [panelArray addObject:bubble];
            
            
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
                                    @"resource",
                                    [NSNumber numberWithFloat:sbv.frame.origin.x],
                                    [NSNumber numberWithFloat:sbv.frame.origin.y],
                                    [NSNumber numberWithFloat:sbv.frame.size.width],
                                    [NSNumber numberWithFloat:sbv.frame.size.height],
                                    [NSNumber numberWithInt:sbv.styleId],
                                    nil]
                                                                             forKeys:
            [NSArray arrayWithObjects:@"c",@"x",@"y",@"w",@"h", @"s", nil]];
            [panelArray addObject:resource];
            
            resource = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                            [NSNumber numberWithFloat:sbv.frame.origin.x],
                                                            [NSNumber numberWithFloat:sbv.frame.origin.y],
                                                            @"1.0",
                                                            @"null",
                                                            nil]
                                                   forKeys:
                        [NSArray arrayWithObjects:@"xoff",@"yoff",@"scale",@"z_index", nil]];
            [placementsArray addObject:resource];
        }//end add resource data
       
    }//end for
    
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:panelArray options:NSJSONWritingPrettyPrinted error:&writeError];
    
    if (jsonData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"bubble_file\"; filename=\"bubble.bub\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //[body appendData:[@"Content-Disposition: form-data; name=\"panel_file\"; filename=\"panel.bub\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: text/html\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:jsonData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    // set URL
    [request setURL:requestURL];
    
    //self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    

    //Uploading on Automics II server
   
    NSString *imageString = [imageData base64EncodedString];
    NSData *d = [NSData dataFromBase64String:imageString];
    

    NSString*   myURLString = [NSString stringWithFormat:@"http://automicsapi.wp.horizon.ac.uk/v1/photo"];
    
    NSError *writeErrorNew;
    
    
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

    self.progressView.progress = 0.0f;
    self.progressView.alpha = 1.0f;
    
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

        NSURLResponse *responseURL;
        NSError *err;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:requestNew returningResponse:&responseURL error:&err];
        if(responseData)
        {

            //NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            //NSLog(@"responseData: %@", responseString);
            
            NSError *parseError = nil;
            
            id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&parseError];
            
            imageURL = [jsonObject objectForKey:@"id"];
            NSLog(@"imageURL=%@", imageURL);


            //uploading panel
            myURLString = [NSString stringWithFormat:@"http://automicsapi.wp.horizon.ac.uk/v1/panel"];
            //NSString* image_url = [NSString stringWithFormat:@"http://automicsapi.wp.horizon.ac.uk%@", imageURL];
            
            //NSDictionary *placementsDict = [NSDictionary dictionaryWithObject:placementsArray forKey:@"placements"];
            //NSDictionary *annotationsDict = [NSDictionary dictionaryWithObject:annotationsArray forKey:@"annotations"];
            
            
            objects = [NSArray arrayWithObjects:imageURL, placementsArray, annotationsArray, nil];
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
                NSString *requestString = [[NSString alloc] initWithData:jsonRequestData encoding:NSUTF8StringEncoding];
                //NSLog(@"requestData: %@", requestString);
                NSURLResponse *response;
                NSError *err;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:requestNew returningResponse:&response error:&err];
                NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                //NSLog(@"responseData: %@", responseString);
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
 
    if(panelUploaded)
    {
        //panelUploaded=NO;
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
