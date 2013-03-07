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
    NSString* boundary = @"0cfOXe12Fj";
    
    //uploading on Automics I server
    NSURL* requestURL = [NSURL URLWithString:@"http://www.automics.net/automics/uploadcomic.php"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
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
    
    
    //Make json
    NSError *writeError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:comicContents options:NSJSONWritingPrettyPrinted error:&writeError];
    
    if (jsonData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"bubble_file\"; filename=\"bubble.bub\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
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
