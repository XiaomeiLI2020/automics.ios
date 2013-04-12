//
//  ComicPosterViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 13/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ComicPosterViewController.h"
#import "MKNetworkEngine.h"
#import "AppDelegate.h"

@interface ComicPosterViewController ()

@end

@implementation ComicPosterViewController

@synthesize imageView;
@synthesize progressView;
@synthesize connection;
@synthesize image;

@synthesize comicContents;
@synthesize comicLoader;

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
    
    comicLoader = [[ComicLoader alloc] init];
    comicLoader.delegate = self;
    
    //MKNetworkOperation* operation = [[MKNetworkOperation alloc] init];
    //operation.delegate = self;
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
    if(comicContents!=nil)
    {
        [self startUpload];
    }

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

    Comic* comic = [[Comic alloc] init];
    comic.name = @"new comic";
    comic.description = @"description of comic";
    comic.panels = [[NSArray alloc] initWithArray:comicContents];
    

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //appDelegate.automicsEngine.delegate = self;
    NSURLRequest* urlRequest = [comicLoader prepareComicRequestForPostComic:comic];
    MKNetworkOperation *operation = [appDelegate.automicsEngine postData:urlRequest
                                                       completionHandler:^(id twitPicURL) {
                                                           //DLog(@"complete.");
                                                       }
                                                        errorHandler:^(NSError* error)
                                                        {
                                                            //DLog(@"error.");
                                                        }
                                     ];

    operation.postDataRequestType = 2;
    operation.delegate = self;
    [appDelegate.automicsEngine enqueueOperation:operation];
    //self.dataFeedConnection = [operation urlConnection];
    
    [operation onUploadProgressChanged:^(double progress) {
        
        //DLog(@"onUploadProgressChanged=%.2f", progress*100.0);
        
    }];

    
    //[comicLoader submitRequestPostComic:comic];
    
    self.progressView.progress = 0.0f;
    self.progressView.alpha = 1.0f;
}

/*
-(void)MKNetworkEngine:(MKNetworkEngine*)automicsEngine didFreezeOperation:(NSString*)responseString{
    UIAlertView *message = [[UIAlertView alloc]
                            initWithTitle:@"Network Not Available."
                            message:@"Your content will be uploaded when network is available."
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
    [message show];
}
*/
- (void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    self.progressView.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    UIAlertView *message = [[UIAlertView alloc]
                            initWithTitle:@"Upload Successful"
                            message:nil
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
    [message show];
    //[self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"OK"])
    {
        [self performSegueWithIdentifier:@"postToComic" sender:self];
        //[self dismissViewControllerAnimated:YES completion:nil];
    }//end if
}//end alertView

- (void)connection:(NSURLConnection*) connection didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Failure"
                          message: @"Lost Connection"
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    self.progressView.alpha = 0.0f;
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

#pragma mark ComicLoader functions.
-(void)ComicLoader:(ComicLoader*)loader didSaveComic:(NSString*)response{
    //NSLog(@"Comic saved. %@", response);
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Successful"
                          message: nil
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    //NSLog(@"photo uploaded");
    [alert show];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MKNetworkOperation functions.
-(void)MKNetworkOperation:(MKNetworkOperation*)operation didUploadComic:(NSString*)response {
    
    UIAlertView *message = [[UIAlertView alloc]
                            initWithTitle:@"Upload Successful"
                            message:nil
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
    [message show];
}

-(void)MKNetworkOperation:(MKNetworkOperation*)operation operationFailedWithError:(NSString*)responseString{
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Failure"
                          message: @"Upload will resume when network connection is available."
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

@end
