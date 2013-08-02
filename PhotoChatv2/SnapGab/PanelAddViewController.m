//
//  PanelAddViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 11/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "PanelAddViewController.h"
#import "PhotoPosterViewController.h"
#import "UIImageView+WebCache.h"
#import "SpeechBubbleView.h"
#import "ResourceView.h"
#import "PanelEditViewController.h"
#import "GUIConstant.h"
#import "APIWrapper.h"
#import "Resource.h"
#import <QuartzCore/QuartzCore.h>

@interface PanelAddViewController ()

@end

@implementation PanelAddViewController

@synthesize imagePicker;
@synthesize imageView;
@synthesize url;
@synthesize startWithCamera;
@synthesize resourceList;

@synthesize keyboardIsShown;
@synthesize thumbnailScrollView;
@synthesize panelScrollView;
@synthesize initialized;
@synthesize postButton;
@synthesize imagesButton;


ResourceLoader *resourceLoader;
PanelPopupWindow *panelPopupWindow;

int resourceCounter;
NSString* resourceImageURL;
CGRect thumbFrame;

#define kTabBarHeight 2
#define kKeyboardAnimationDuration 0.3


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
    NSLog(@"PanelAddViewControlelr.viewWillAppear.");
    [super viewWillAppear:animated];
    
    //[MTPopupWindow showWindowWithHTMLFile:@"info.html"];
    
    if(!self.initialized)
    {
        panelPopupWindow= [PanelPopupWindow showWindow];
        panelPopupWindow.delegate = self;
        self.initialized = YES;
    }

    
    
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

    [imagesButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    imagesButton.layer.borderWidth=4.0f;
    imagesButton.clipsToBounds = YES;
    imagesButton.layer.cornerRadius = 10;//half of the width
    [imagesButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    imagesButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    if(self.imageView.image)
    {
       
        postButton.enabled = YES;
        postButton.alpha = 1.0;
        
        return; //If image already loaded - do not reload it (since load moved from viewDidLoad)
    }
    else if(!self.imageView.image)
    {

        postButton.enabled = NO;
        postButton.alpha = 0.4;
    }
//        NSLog(@"No image selected.");

    /*
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
*/

    [thumbnailScrollView layoutAssets];

}


- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"viewDidAppear.");
    [super viewDidAppear:animated];
    //if(self.startWithCamera) [self useCameraPressed];
    if(self.startWithCamera) [self takeSnap:0];
    self.startWithCamera = NO;
    
    //NSLog(@"thumbnail.numItems=%i", [thumbnailScrollView numItems]);
    [thumbnailScrollView layoutAssets];
}

/*
- (void)loadImage:(UIImage*) image
{
    NSLog(@"LoadImage.");
    self.imageView.image = image;
    
    self.imageView.frame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelWidth, panelHeight);
    //self.imageView.image = [self squareImageWithImage:image scaledToSize:imageSize];
}
 */

- (void)addBubbleWithId:(id)sender
{
    UIButton *clicked = (UIButton *) sender;
    int styleId = clicked.tag;
    
    SpeechBubbleView *sbv = [[SpeechBubbleView alloc] initWithFrame:CGRectMake(100, 100, 0, 0) andText:@"  TAP TO EDIT\nDRAG TO MOVE" andStyle:styleId];
    [self.view addSubview:sbv];

}


- (void)addResourceWithId:(id)sender
{
    UIButton *clicked = (UIButton *) sender;
    //int resourceId = clicked.tag;
    int resourceIndex = clicked.tag;
    
    if([resourceList count]>0 && [resourceList count]>resourceIndex)
    {
        Resource* resource = [resourceList objectAtIndex:(resourceIndex)];
        if(resource!=nil)
        {
            NSString* type = resource.type;
            
            CGRect resourceFrame;// = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
            if([type isEqual:@"d"])
            {
                resourceFrame = CGRectMake(100.0, 100.0, decoratorWidth, decoratorHeight);
                
            }
            if([type isEqual:@"f"])
            {
                resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                //resourceFrame = CGRectMake(0.0, 20.0, frameWidth, frameHeight);
            }
            
            //NSLog(@"addResourceWithId.resourceFrame=%@", NSStringFromCGRect(resourceFrame));
            //ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andURL:resource.imageURL andType:type andId:resource.resourceId];
            ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andResource:resource andScale:1.0 andAngle:0.0];
            
            [self.view addSubview:rv];
        }//end if resource!=nil
    }//end if
    
}

-(void)loadSpeechBubbles
{
    
    int i;
    for (i=0; i <numSpeechBubbles; i++)
    {
        NSString* imageString = [NSString stringWithFormat: @"bubble-style%i.png",i];
        UIImage *image = [UIImage imageNamed:imageString];
        
        UIButton *styleButton = [[UIButton alloc] initWithFrame:thumbFrame];
        [styleButton setBackgroundImage:image forState:UIControlStateNormal];
        [styleButton setImage:image forState:UIControlStateNormal];
        
        
        CGRect rect1 = styleButton.frame;
        rect1.size.height = assetHeight;
        rect1.size.width = assetWidth;
        styleButton.frame = rect1;
        styleButton.tag = i;	// tag our images for later use when we place them in serial fashion
        
        [styleButton addTarget:self action:@selector(addBubbleWithId:) forControlEvents:UIControlEventTouchDown];
        
        // add images to the thumbnail scrollview
        [thumbnailScrollView addSubview:styleButton];
    }
    
}

- (void)viewDidLoad
{
    //NSLog(@"viewDidLoad.");
    [super viewDidLoad];
    
    resourceCounter = 0;
    resourceList = [[NSMutableArray alloc] init];
    resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate = self;
    
    //Initiate thumbnail scrollview
    [self initiateScrollViews];
    
    //Add speechbubbles to thumbnail scrollview
    [self loadSpeechBubbles];
    
    [resourceLoader submitRequestGetResourcesForTheme:1];
    
    [self registerForKeyboardNotifications];
    
    keyboardIsShown = NO;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    singleTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTap];
    
    //imageSize = CGSizeMake(320, 320);
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

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    //NSLog(@"singleTapcaptured.");
    
    for (UIView *subview in self.view.subviews)
    {
        if([subview isKindOfClass:[ResourceView class]])
        {
            
            ResourceView* sbv =(ResourceView*)subview;
            [sbv disappearControls];
            
        }//end if
    }//end for
    
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
    //NSLog(@"didFinishPickingMediaWithInfo");
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    
    // NSString *mediaType = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    
    //Handle a picture capture
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *imageEdited = [info objectForKey:UIImagePickerControllerEditedImage];
        //UIImage *imagePicked = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        /*
        CGRect cropRect;
        cropRect = [[info valueForKey:@"UIImagePickerControllerCropRect"] CGRectValue];
        
        NSLog(@"Original width = %f height= %f ",imagePicked.size.width, imagePicked.size.height);
        //Original width = 1440.000000 height= 1920.000000
        
        NSLog(@"imageEdited width = %f height = %f",imageEdited.size.width, imageEdited.size.height);
        //imageEdited width = 640.000000 height = 640.000000
        
        NSLog(@"corpRect %@", NSStringFromCGRect(cropRect));
        */
        
        //[self loadImage:image];
        [self removeAllBubbles];
        [self removeAllResources];
        
        //imageView.frame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelWidth, panelHeight);
        imageView.frame = CGRectMake(panelScrollXOrigin, 0, panelWidth, panelHeight);
        image= [self imageWithImage:image scaledToSize:CGSizeMake(panelWidth, panelHeight)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);
        
        image = imageEdited;
        imageView.image = image;
        [imageView setBackgroundColor:[UIColor grayColor]];
        
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

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(newSize);
        }
    } else {
        UIGraphicsBeginImageContext(newSize);
    }
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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


-(void)initiateScrollViews
{
  
    // Add panels scrollview
    CGRect panelFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
    CGSize panelSize = CGSizeMake(panelWidth, panelHeight);
    //panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize andNumItems:numPanels];
    panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize andNumItems:1];
    panelScrollView.tag=0;
    panelScrollView.delegate=self;
    [self.view addSubview:panelScrollView];
    [panelScrollView layoutItems];
    [panelScrollView addSubview:imageView];
    
    // Add thumbnails scrollview
    CGRect thumbFrame = CGRectMake(assetScrollXOrigin, assetScrollYOrigin, assetScrollObjWidth, assetScrollObjHeight);
    CGSize thumbnailSize = CGSizeMake(assetScrollObjWidth, assetScrollObjHeight);
    thumbnailScrollView = [[MainScrollSelector alloc] initWithFrame:thumbFrame andItemSize:thumbnailSize andNumItems:numSpeechBubbles];
    thumbnailScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:thumbnailScrollView];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if(panelPopupWindow!=nil)
    {
        [panelPopupWindow closePopupWindow];
    }
    
    if(!self.imageView.image) return;
    
    if([[segue identifier] isEqualToString:@"postNewPanel"]){
        PhotoPosterViewController *ppvc = (PhotoPosterViewController *)[segue destinationViewController];
        ppvc.image = self.imageView.image;
        ppvc.editMode = NO;
        //ppvc.editedPhoto=currentPanel.photo;
        
        for (UIView *subview in self.view.subviews)
        {
            //upload speech bubbles with the photo
            if([subview isMemberOfClass:[SpeechBubbleView class]])
            {
                SpeechBubbleView* sbv =(SpeechBubbleView*)subview;
                SpeechBubbleView *new_sbv = [[SpeechBubbleView alloc] initWithFrame:sbv.frame andText:sbv.textView.text andStyle:sbv.styleId];
                new_sbv.userInteractionEnabled = NO;
                [ppvc.view addSubview:new_sbv];
            }//end if
            
            //upload resources with the photo
            if([subview isMemberOfClass:[ResourceView class]])
            {
                /*
                ResourceView* sbv =(ResourceView*)subview;

                //ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andURL:sbv.urlImageString andType:sbv.type andId:sbv.resourceId];
                ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andResource:sbv.resource andScale:sbv.scale andAngle:sbv.angle];
                new_sbv.userInteractionEnabled = NO;
                [ppvc.view addSubview:new_sbv];
                */
                
                ResourceView* sbv =(ResourceView*)subview;
                if(sbv.angle!=0.00)
                    sbv.transform = CGAffineTransformMakeRotation(0.00);
                
                //NSLog(@"added pre-rotation resource.frame=%@", NSStringFromCGRect(sbv.frame));
                //NSLog(@"added pre-rotation sbv.angle=%f", sbv.angle);
                //CGRect originalRect = CGRectMake(sbv.originalOrigin.x, sbv.originalOrigin.y, sbv.bounds.size.width, sbv.bounds.size.height);
                //ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:originalRect andResource:sbv.resource andScale:sbv.scale andAngle:sbv.angle];
                ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andResource:sbv.resource andScale:sbv.scale andAngle:sbv.angle];
                //new_sbv.originalFrame = sbv.frame;
                new_sbv.originalFrame = CGRectMake(sbv.frame.origin.x, sbv.frame.origin.y, sbv.frame.size.width, sbv.frame.size.height);
                
                if(sbv.angle!=0.00)
                    sbv.transform = CGAffineTransformMakeRotation(sbv.angle);
                //new_sbv.transform = CGAffineTransformMakeRotation(0.0);
                //NSLog(@"added post-rotation newresource.frame=%@", NSStringFromCGRect(new_sbv.frame));
                //NSLog(@"added post-rotation newresource.bounds%@", NSStringFromCGRect(new_sbv.bounds));
                
                new_sbv.userInteractionEnabled = NO;
                //new_sbv.alpha = 0;
                [ppvc.view addSubview:new_sbv];
            }//end if
        }//end for
    } //end if

}

- (IBAction)postPanel:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    PhotoPosterViewController *ppvc = [storyboard instantiateViewControllerWithIdentifier:@"PhotoPosterViewController"];
    ppvc.image = self.imageView.image;
    ppvc.editMode = NO;
    //ppvc.editedPhoto=currentPanel.photo;
    
    for (UIView *subview in self.view.subviews)
    {
        //upload speech bubbles with the photo
        if([subview isMemberOfClass:[SpeechBubbleView class]])
        {
            SpeechBubbleView* sbv =(SpeechBubbleView*)subview;
            SpeechBubbleView *new_sbv = [[SpeechBubbleView alloc] initWithFrame:sbv.frame andText:sbv.textView.text andStyle:sbv.styleId];
            new_sbv.userInteractionEnabled = NO;
            [ppvc.view addSubview:new_sbv];
        }//end if
        
        //upload resources with the photo
        if([subview isMemberOfClass:[ResourceView class]])
        {
            
            ResourceView* sbv =(ResourceView*)subview;
            if(sbv.angle!=0.00)
                sbv.transform = CGAffineTransformMakeRotation(0.00);
            
            //NSLog(@"added pre-rotation resource.frame=%@", NSStringFromCGRect(sbv.frame));
            //NSLog(@"added pre-rotation sbv.angle=%f", sbv.angle);
            //CGRect originalRect = CGRectMake(sbv.originalOrigin.x, sbv.originalOrigin.y, sbv.bounds.size.width, sbv.bounds.size.height);
            //ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:originalRect andResource:sbv.resource andScale:sbv.scale andAngle:sbv.angle];
            ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andResource:sbv.resource andScale:sbv.scale andAngle:sbv.angle];
            //new_sbv.originalFrame = sbv.frame;
            new_sbv.originalFrame = CGRectMake(sbv.frame.origin.x, sbv.frame.origin.y, sbv.frame.size.width, sbv.frame.size.height);
            
            if(sbv.angle!=0.00)
                sbv.transform = CGAffineTransformMakeRotation(sbv.angle);
            //new_sbv.transform = CGAffineTransformMakeRotation(0.0);
            //NSLog(@"added post-rotation newresource.frame=%@", NSStringFromCGRect(new_sbv.frame));
            //NSLog(@"added post-rotation newresource.bounds%@", NSStringFromCGRect(new_sbv.bounds));
            
            new_sbv.userInteractionEnabled = NO;
            //new_sbv.alpha = 0;
            [ppvc.view addSubview:new_sbv];
        }//end if
    }//end for
    
     [self.navigationController pushViewController:ppvc animated:YES];
}

- (IBAction)takeSnap:(id)sender {
    
    //NSLog(@"takesnap called.");
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
        
        imagePicker.allowsEditing = YES;
        //imagePicker.allowsEditing = NO;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
        newMedia = YES;
        
    }//end if
}

//Show photos from camera roll
- (IBAction)showPhotos:(id)sender {
    
    //NSLog(@"showphotos called.");
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
        
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
        newMedia = NO;
    }//end if
}


-(void)addResourceToScrollViews:(Resource*)resource
{
    if(resource!=nil)
    {
        
        //NSLog(@"addResoruceToscrolView.");
        //int resourceId = resource.resourceId;
        //NSString* thumb_url = resource.thumbURL;
        UIButton *styleButton = [[UIButton alloc] initWithFrame:thumbFrame];

        //UIImage *image = [UIImage imageNamed:resource.thumbURL];
        /*
        NSData *imageURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumb_url]];
        UIImage *image = [UIImage imageWithData:imageURL];
        
        UIButton *styleButton = [[UIButton alloc] initWithFrame:thumbFrame];
        [styleButton setImage:image forState:UIControlStateNormal];
        */
        
        
        
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //NSString* imageName = [NSString stringWithFormat:@"%i.png", page];
        NSString* imageName = [NSString stringWithFormat:@"resourcePhoto%i.png", resource.resourceId];
        NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
        BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
        
        if(!fileExists)
        {
            UIImageView *resourceImageView = [[UIImageView alloc] init];
            //[imageView setImageWithURL:[NSURL URLWithString:resource.thumbURL] placeholderImage:nil];
            
            [resourceImageView setImageWithURL:[NSURL URLWithString:resource.imageURL]
                       placeholderImage:nil
                                success:^(UIImage *imageDownloaded) {
                                    //NSLog(@"image successfully downloaded.");
                                    
                                    [styleButton setImage:imageDownloaded forState:UIControlStateNormal];
                                    
                                    NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                    [data1 writeToFile:currentFile atomically:YES];
                                    
                                }
                                failure:^(NSError *error) {
                                    NSLog(@"Failed to load resource image.");
                                }];
            
        }//end if(!fileExists)
        
        else if(fileExists)
        {
            UIImage* image= [UIImage imageWithContentsOfFile:currentFile];
            [styleButton setImage:image forState:UIControlStateNormal];
        }

        
        
        
        CGRect rect1 = styleButton.frame;
        rect1.size.height = assetHeight;
        rect1.size.width = assetWidth;
        styleButton.frame = rect1;
        //styleButton.tag = resourceId;	// tag our images for later use when we place them in serial fashion
        styleButton.tag = resourceCounter;	// tag our images for later use when we place them in serial fashion
        
        [styleButton addTarget:self action:@selector(addResourceWithId:) forControlEvents:UIControlEventTouchDown];
        // add images to the thumbnail scrollview
        [thumbnailScrollView addSubview:styleButton];
        
        [resourceList addObject:resource];
        resourceCounter++;

        /*
        if(resourceCounter==[resourceList count])
        {
            [thumbnailScrollView layoutAssets];
        }
         */
    }

}


-(NSArray*)arrayByRemovingObject:(NSArray*)array andResource:(Resource*)resource
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray removeObject:resource];
    return [NSArray arrayWithArray:newArray];
}

- (void)openGallery {
    
    //NSLog(@"showphotos called.");
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
        
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
        newMedia = NO;
    }//end if
}

-(void)openCamera
{
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
        
        imagePicker.allowsEditing = YES;
        //imagePicker.allowsEditing = NO;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
        newMedia = YES;
        
    }//end if
}


#pragma mark ResourceLoader functions.
-(void)ResourceLoader:(ResourceLoader*)loader didFailWithError:(NSError*)error{
    //NSLog(@"resource failed to load.");
    
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResources:(NSArray*)resources{
    //NSLog(@"resources loaded.");
    
    if(resources!=nil)
    {
        NSLog(@"didLoadResources.[resources count]=%i", [resources count]);
        
        if([resources count]>0)
        {
            for(Resource* resource in resources)
            {
                if(resource!=nil)
                {
                    if([resource.type isEqualToString:@"f"])
                    {
                        resources = [self arrayByRemovingObject:resources andResource:resource];
                    }
                }//end if
            }//end for
        }//end if
        
        numResources = [resources count];
        thumbnailScrollView.numItems = numSpeechBubbles + numResources;
        [thumbnailScrollView layoutAssets];
        //[self loadSpeechBubbles];
        
        if([resources count]>0)
        {
            for(Resource* resource in resources)
            {
                if(resource!=nil)
                {
                    if (resource.resourceId > 0)
                    {
                        //resourceImageURL = resource.imageURL;
                        [self addResourceToScrollViews:resource];
                        
                    }//end if
                }//end if resource!=nil

            }//end for
            
        }//end if
    }//end if resources!=nil

}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResource:(Resource*)resource
{
    //NSLog(@"Resource downloaded");
}

#pragma mark PanelPopupWindow functions.
-(void)didSelectSource:(int)sourceId{
    //NSLog(@"resource failed to load.");
    NSLog(@"PanelAddViewController.didSelectSource.sourceId=%i", sourceId);
    if(sourceId==0)
    {
        [self openGallery];
    }
    if(sourceId==1)
    {
        [self openCamera];
    }
    
}


@end
