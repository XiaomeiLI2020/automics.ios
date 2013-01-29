//
//  CameraViewController.m
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "PhotoPosterViewController.h"
#import "UIImageView+WebCache.h"
#import "SpeechBubbleView.h"
#import "ResourceView.h"


@interface CameraViewController ()

@end

@implementation CameraViewController

@synthesize imagePicker;
@synthesize imageView;
@synthesize url;
@synthesize startWithCamera;


@synthesize scrollView;
@synthesize keyboardIsShown;
@synthesize imageSize;



#define kTabBarHeight 2
#define kKeyboardAnimationDuration 0.3

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
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
    
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.imageView.image) return; //If image already loaded - do not reload it (since load moved from viewDidLoad)
    
    //self.imageView.image = [self squareImageWithImage:self.imageView.image scaledToSize:imageSize];
    
    [self.imageView setImageWithURL:self.url
                   placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]
                            success:^(UIImage *image) {
                                for (UIView *subview in self.view.subviews)
                                {
                                    if([subview isMemberOfClass:[SpeechBubbleView class]])
                                    {
                                        SpeechBubbleView* sbv =(SpeechBubbleView*)subview;
                                        sbv.alpha = 1;
                                    }
                                    
                                    if([subview isMemberOfClass:[ResourceView class]])
                                    {
                                        ResourceView* sbv =(ResourceView*)subview;
                                        sbv.alpha = 1;
                                    }
                                }
                            }
                            failure:^(NSError *error) {
                                UIAlertView *alert = [[UIAlertView alloc]
                                                      initWithTitle: @"Load failed"
                                                      message: @"Failed to load image"
                                                      delegate: nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                                [alert show];
                            }];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //if(self.startWithCamera) [self useCameraPressed];
    if(self.startWithCamera) [self takeSnap:0];
    self.startWithCamera = NO;
}


- (void)loadImage:(UIImage*) image
{
    self.imageView.image = image;

    //self.imageView.image = [self squareImageWithImage:image scaledToSize:imageSize];
}


- (void)addBubbleWithStyle:(int)styleId
{
    SpeechBubbleView *sbv = [[SpeechBubbleView alloc] initWithFrame:CGRectMake(100, 100, 0, 0) andText:@"  TAP TO EDIT\nDRAG TO MOVE" andStyle:styleId];
    [self.view addSubview:sbv];
}

- (void)addResourceWithStyle:(int)styleId
{

    ResourceView *rv = [[ResourceView alloc] initWithFrame:CGRectMake(100, 100, 200, 200) andStyle:styleId];
    [self.view addSubview:rv];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];

    keyboardIsShown = NO;
    
    imageSize = CGSizeMake(640, 640);
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self unregisterForKeyboardNotifications];
}

- (void)dealloc {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self unregisterForKeyboardNotifications];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    //NSLog(@"keyboard was shown");
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the UIScrollView if the keyboard is already shown.  This can happen if the user, after fixing editing a UITextField, scrolls the resized UIScrollView to another UITextField and attempts to edit the next UITextField.  If we were to resize the UIScrollView again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (keyboardIsShown) {
        return;
    }
    
    
    //Get the size of the keyboard
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
   
    
    subviewId = 0;
    //Step 3: Find the target subview
    //Step 3.1 Get the subviews of the view
    NSArray *subviews = [self.view subviews];
    
    //Step 3.2: Find the subsubview that is first responder
    for (UIView *subview in subviews)
    {
        
        if([subview isKindOfClass:[SpeechBubbleView class]])
        {
            subviewId++;
            
            NSArray *subsubviews = [subview subviews];
            
            for (UIView *subsubview in subsubviews)
            {
                if([subsubview isKindOfClass:[BubbleTextView class]])
                {
                    if([subsubview isFirstResponder])
                    {
                        //Save the original frame of subview
                        originalFrame = [subview frame];
                        /*
                        NSLog(@"self.scrollView.frame.origin.y is %f", self.scrollView.frame.origin.y);
                        NSLog(@"subview.frame.origin.y is %f", subview.frame.origin.y);
                        NSLog(@"subview.frame.size.height is %f", subview.frame.size.height);
                        NSLog(@"subsubview.frame.origin.y is %f", subsubview.frame.origin.y);
                        NSLog(@"subsubview.frame.size.height is %f", subsubview.frame.size.height);
                        NSLog(@"keyboardSize.height is %f", keyboardSize.height);
                       */
                        
                        //If the keyboard is obscuring the SpeechBubble, move speech bubble upwars
                        if(subview.frame.origin.y + subsubview.frame.size.height > keyboardSize.height)
                        {

                            float difference = subview.frame.origin.y + subsubview.frame.size.height - keyboardSize.height;

                            //Specify the new frame of subview
                            CGRect aRect = originalFrame;
                            aRect.origin.y -= (difference + 10);
                            subview.frame = aRect;
                            
                            break;

                        }//end if(subview.frame.origin.y + subsubview.frame.size.height > keyboardSize.height)
                        
                    }//end if subsubview first responder
                }//end if subsubview isKindOfClass:[BubbleTextView class
                
            }//end for looping across all subviews
        } //end if SpeechBubbleView class
        
        
    } //end for list all subViews in main view
    

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:kKeyboardAnimationDuration];
    [UIView commitAnimations];
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
    int index = 0;
    //Step 3.1 Get the subviews of the view
    NSArray *subviews = [self.view subviews];
    
    //Step 3.2: Find the subsubview that was moved upward due to keyboard obscuration
    for (UIView *subview in subviews)
    {
        if([subview isKindOfClass:[SpeechBubbleView class]])
        {
            index++;
            //NSLog(@"index is %i, and subviewId is %i", index, subviewId);
            //NSLog(@"subview.frame.origin.y is %f", subview.frame.origin.y);
            
            if(index==subviewId)
            {
                subview.frame = originalFrame;
                subviewId = 0;
                break;
            }
        } //end if SpeechBubbleView class
    } //end for list all subViews in main view
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    // The kKeyboardAnimationDuration I am using is 0.3
    [UIView setAnimationDuration:kKeyboardAnimationDuration];
    //[self.scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

//Remove Speech Bubbles
-(void)removeAllBubbles
{
    for (UIView *subview in self.view.subviews)
    {
        if([subview isMemberOfClass:[SpeechBubbleView class]])
        {
            [subview removeFromSuperview];
        }
    } //end for
} //end removeAllBubbles

//Remove Resources
-(void)removeAllResources
{
    for (UIView *subview in self.view.subviews)
    {
        if([subview isMemberOfClass:[ResourceView class]])
        {
            [subview removeFromSuperview];
        }
    } //end for
} //end removeAllResources

// Responding to after the user accepts a newly-captured picture
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    
   // NSString *mediaType = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    
    //Handle a picture capture
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
       
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        [self loadImage:image];
        [self removeAllBubbles];
        [self removeAllResources];
        
        imageView.image = image;
        
        //If newMedia, then save the new image to camera roll
        if (newMedia)
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
		// Code here to support video if enabled
	}
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    if([[segue identifier] isEqualToString:@"startPhotoPosterView"]){
        PhotoPosterViewController *ppvc = (PhotoPosterViewController *)[segue destinationViewController];
        ppvc.image = self.imageView.image;
        
        for (UIView *subview in self.view.subviews)
        {
            //upload speech bubbles with the photo
            if([subview isMemberOfClass:[SpeechBubbleView class]])
            {
                SpeechBubbleView* sbv =(SpeechBubbleView*)subview;
                SpeechBubbleView *new_sbv = [[SpeechBubbleView alloc] initWithFrame:sbv.frame andText:sbv.textView.text andStyle:sbv.styleId];
                new_sbv.userInteractionEnabled = NO;
                [ppvc.view addSubview:new_sbv];
            }
            
            //upload resources with the photo
            if([subview isMemberOfClass:[ResourceView class]])
            {
                ResourceView* sbv =(ResourceView*)subview;
                
                //NSLog(@"before posting: sbv.frame.origin (%f,%f)",sbv.frame.origin.x, sbv.frame.origin.y);
                //NSLog(@"before posting: sbv.frame.size (%f,%f)",sbv.frame.size.width, sbv.frame.size.height);
                

                ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andStyle:sbv.styleId];
                new_sbv.userInteractionEnabled = NO;
                [ppvc.view addSubview:new_sbv];
            }
        }//end for
    } //end if
    
    
    if([[segue identifier] isEqualToString:@"startSelectBubbleStyleView"]){
        SelectBubbleStyleViewController *sbsvc = (SelectBubbleStyleViewController *)[segue destinationViewController];
        sbsvc.delegate = self;
    }//end if
    
    if([[segue identifier] isEqualToString:@"startResourceView"]){
       ResourceViewController *rvc = (ResourceViewController *)[segue destinationViewController];
       rvc.delegate = self;
        
    }//end if
}

- (IBAction)takeSnap:(id)sender {
    
    //Check if device's camera is available to use
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        
        //Instantiate ImagePickerController
        imagePicker = [[UIImagePickerController alloc] init];
        
        //Configure the ImagePickerController for media capture
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        //Set mediaTypes to images
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        //imagePicker.toolbarHidden = YES;

        
        //Assign delegate object to ImagePickerController's delegate property
        imagePicker.delegate = self;
        
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
        newMedia = YES;
        
    }//end if
}

//Show photos from camera roll
- (IBAction)showPhotos:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
    
    //Instantiate ImagePickerController
    imagePicker = [[UIImagePickerController alloc] init];
    
    //Configure the ImagePickerController to show photo library
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
 
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    //imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum ];
    
    //Assign delegate object to ImagePickerController's delegate property
    imagePicker.delegate = self;

    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
    newMedia = NO;
    }//end if
}

- (IBAction)closePressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
