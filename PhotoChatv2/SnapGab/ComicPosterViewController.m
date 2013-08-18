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
#import "UserLoader.h"

@interface ComicPosterViewController ()

@end

@implementation ComicPosterViewController

@synthesize imageView;
@synthesize progressView;
@synthesize connection;
@synthesize image;
@synthesize comicContents;
@synthesize comicLoader;
@synthesize comicName;
BOOL alertShown;

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
    
    UIImageView *backgroundImage;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        //NSLog(@"This is iPhone 5");
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background@x5.png"]];
        [backgroundImage setFrame:CGRectMake(0, 0, 320, 568)];
    }
    else
    {
        //NSLog(@"This is iPhone 4");
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
        [backgroundImage setFrame:CGRectMake(0, 0, 320, 480)];
    }
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    comicLoader = [[ComicLoader alloc] init];
    comicLoader.delegate = self;
    
    alertShown = NO;
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
        if(!alertShown)
        {
            alertShown = YES;
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Already Sending"
                                  message: @"Upload one comic at a time"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }//end if(!alertShown)
        

        return;
    }

    Comic* comic = [[Comic alloc] init];
    //comic.name = @"new comic";
    if(comicName!=nil && ![comicName isEqualToString:@""])
        comic.name = comicName;
    //NSLog(@"ComicPosterViewController. comicName=%@", comicName);
    
    comic.description = @"description of comic";
    comic.panels = [[NSArray alloc] initWithArray:comicContents];
    
    NSLog(@"ComicPosterViewController. [comic.panels count]=%i", [comic.panels count]);
    
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
    //[appDelegate.automicsEngine enqueueOperation:operation];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //Call your function or whatever work that needs to be done
        //Code in this part is run on a background thread
        [appDelegate.automicsEngine enqueueOperation:operation];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            //Stop your activity indicator or anything else with the GUI
            //Code here is run on the main thread
            
        });
    });

    
    
    NSLog(@"ComicPosterView. startOperation. reachable=%d", [comicLoader isReachable]);
    
    if(!alertShown)
    {

        if(![comicLoader isReachable])
        {
            alertShown = YES;
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Upload Failure"
                                  message: @"Data will be uploaded when network connection is available."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }//end if(![comicLoader isReachable])
        else if([comicLoader isReachable])
        {
            /*
             [operation onUploadProgressChanged:^(double progress) {
             
             //DLog(@"onUploadProgressChanged=%.2f, progress=%f", progress*100.0, progress);
             self.progressView.progress = (float)progress;
             
             }];
             */
            alertShown = YES;
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Upload Request"
                                  message: @"Data is being uploaded."
                                  delegate: self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            
        }//end else if([comicLoader isReachable])

    }//end if(!alertShown)

    
    /*
    [operation onUploadProgressChanged:^(double progress) {
        
        //DLog(@"onUploadProgressChanged=%.2f", progress*100.0);
        
    }];
*/
    
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
        //NSDictionary *dataDict = [NSDictionary dictionaryWithObject:@"New comic uploaded" forKey:@"comicnotification"];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"newComicNotification" object:nil userInfo:dataDict];
        
        //UserLoader* userLoader = [[UserLoader alloc] init];
        //[userLoader submitRequestPostNotification:@"New comic uploaded."];
        
        NSArray* viewControllers = self.navigationController.viewControllers;
        [self.navigationController popToViewController:[viewControllers objectAtIndex:2] animated:YES];
        
        //[self.navigationController popViewControllerAnimated:YES];
        //[self performSegueWithIdentifier:@"postToComic" sender:self];
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
    
    //Post a notification when a panel has been successfully added.
    UserLoader* userLoader = [[UserLoader alloc] init];
    [userLoader submitRequestPostNotification:@"New comic uploaded."];
    
    UIAlertView *message = [[UIAlertView alloc]
                            initWithTitle:@"Upload Successful"
                            message:nil
                            delegate:self
                            cancelButtonTitle:@"OK"
                            otherButtonTitles:nil];
    [message show];
}

-(void)MKNetworkOperation:(MKNetworkOperation*)operation operationFailedWithError:(NSString*)responseString{
    /*
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Upload Failure"
                          message: @"Upload will resume when network connection is available."
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
     */
}

@end
