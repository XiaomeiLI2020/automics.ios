//
//  ComicPosterViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 13/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ComicPosterViewController.h"

@interface ComicPosterViewController ()

@end

@implementation ComicPosterViewController

@synthesize imageView;
@synthesize progressView;
@synthesize connection;
@synthesize image;

@synthesize comicContents;

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
    //self.imageView.image = self.image;
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

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error
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
    /*
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
    */
    
    //uploading on Automics I server
    NSURL* requestURL = [NSURL URLWithString:@"http://automicsapi.wp.horizon.ac.uk/v1/comic"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* token = [prefs objectForKey:@"session"];
    
    NSError* writeErrorNew;
    
    NSString* panelIds;
    
    for(int i=0; i<[comicContents count]; i++)
    {
        if(panelIds==NULL)
        {
            panelIds= [NSString stringWithFormat:@"%i",[[comicContents objectAtIndex:i] integerValue]];
        }
        else
            panelIds= [NSString stringWithFormat:@"%@,%i", panelIds, [[comicContents objectAtIndex:i] integerValue]];
    }
    
    NSLog(@"panelIds=%@", panelIds);
    
    NSArray *objects = [NSArray arrayWithObjects:@"description", @"name", panelIds, token, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"description",@"name", @"panels", @"session", nil];
    
    //objects = [NSArray arrayWithObjects:@"description", @"type.png", imageString, nil];
    //keys = [NSArray arrayWithObjects:@"description",@"name", @"blob", nil];
    
    NSDictionary *questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"data"];
    //Create JSON object
    NSData *jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&writeErrorNew];

    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setURL:requestURL];
    
    
      //Make json
    //NSError *writeError = nil;
    //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:comicContents options:NSJSONWritingPrettyPrinted error:&writeError];

    
    // setting the body of the post to the reqeust
    [request setHTTPBody:jsonRequestData];

    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
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
        /*
         NSString *requestString = [[NSString alloc] initWithData:jsonRequestData encoding:NSUTF8StringEncoding];
         NSLog(@"requestData: %@", requestString);
         NSURLResponse *response;
         NSError *err;
         NSData *responseData = [NSURLConnection sendSynchronousRequest:requestNew returningResponse:&response error:&err];
         NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
         NSLog(@"responseData: %@", responseString);
         */
    }
    
    self.progressView.progress = 0.0f;
    self.progressView.alpha = 1.0f;
}

- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    self.progressView.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Successful"
                          message: nil
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    //NSLog(@"photo uploaded");
    [alert show];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)connection:(NSURLConnection*) connection didFailWithError:(NSError *)error
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
