//
//  PanelEditViewControllerII.m
//  PhotoChat
//
//  Created by Umar Rashid on 06/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//


#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImageView+WebCache.h"
#import "PhotoPosterViewController.h"
#import "SpeechBubbleView.h"
#import "ResourceView.h"
#import "PanelEditViewController.h"
#import "PanelViewController.h"
#import "ResourceImageView.h"
#import "GUIConstant.h"
#import "Resource.h"
#import "Annotation.h"
#import <QuartzCore/QuartzCore.h>

@interface PanelEditViewController ()

@end

@implementation PanelEditViewController


@synthesize imageView;
@synthesize url;

@synthesize keyboardIsShown;
@synthesize imageSize;
@synthesize thumbnailScrollView;
@synthesize panelScrollView;

@synthesize resourceList;
@synthesize currentPanel;
@synthesize panelId;
@synthesize currentPage;
@synthesize subviewId;
@synthesize originalFrame;
@synthesize imageLabel;
@synthesize imagesButton;


BOOL alertShown;

ResourceLoader *resourceLoader;

int resourceCounter;
NSString* resourceImageURL;
CGRect thumbFrame;


int numResources;

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
    //NSLog(@"viewWillAppear.");
    [super viewWillAppear:animated];
    
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
    
    alertShown = NO;

    if(self.imageView.image) return; //If image already loaded - do not reload it (since load moved from viewDidLoad)
    
    self.imageLabel.text= [NSString stringWithFormat: @"Image %i", currentPage+1];
    self.imageLabel.numberOfLines = 0; //will wrap text in new line
    [self.imageLabel sizeToFit];
    [self.imageLabel setFont:[UIFont fontWithName: @"Transit Display" size:28]];
    self.imageLabel.frame = CGRectMake(120.0, 2.0, 100.0, 34.0);

    imageView.frame = CGRectMake(0.0, 0.0, panelWidth, panelHeight);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);
    
    [self.imageView setImageWithURL:self.url
                   placeholderImage:nil
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
                                }//end for
                                 
                                 
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
    

    
    [thumbnailScrollView layoutAssets];

}

-(void)loadAnnotations
{
    
    if(currentPanel!=nil)
    {
        if(currentPanel.annotations!=nil)
        {
            for(Annotation* annotation in currentPanel.annotations)
            {
                if(annotation!=nil)
                {
                    CGRect xywh = CGRectMake(annotation.xOffset,
                                             annotation.yOffset,0,0);
                    
                    NSString* text = annotation.text;
                    int styleId = annotation.bubbleStyle;
                    
                    //NSLog(@"loadAnnotations.text=%@", text);
                    
                    SpeechBubbleView* sbv = [[SpeechBubbleView alloc] initWithFrame:xywh andText:text andStyle:styleId];
                    sbv.userInteractionEnabled = YES;
                    sbv.alpha = 0.0f;
                    [self.view addSubview:sbv];
                    [UIView transitionWithView:self.view
                                      duration:0.25
                                       options:UIViewAnimationOptionLayoutSubviews
                                    animations:^ { sbv.alpha = 1.0f; }
                                    completion:nil];
                }//end if(annotation!=nil)
            }//end for
            
        }//end if(currentPanel.annotations!=nil)
    }//end if(currentPanel!=nil)

}

- (void)addSpeechBubblesToScrollView
{
    /*
    CGRect thumbFrame = CGRectMake(assetScrollXOrigin, assetScrollYOrigin, assetScrollObjWidth, assetScrollObjHeight);
    */
    
    NSUInteger i;
    for (i=0; i <numSpeechBubbles; i++)
    {
        NSString* imageString = [NSString stringWithFormat: @"bubble-style%i.png",i];
        UIImage *image = [UIImage imageNamed:imageString];
        
        
        //UIImageView *sbView = [[UIImageView alloc] initWithImage:image];
        //UIButton *styleButton = [[UIButton alloc] initWithFrame:thumbFrame];
        UIButton *styleButton = [[UIButton alloc] initWithFrame:CGRectMake(i*assetScrollXOrigin, assetScrollYOrigin, assetWidth, assetHeight)];
        [styleButton setBackgroundImage:image forState:UIControlStateNormal];
        
        /*
        CGRect rect1 = styleButton.frame;
        rect1.size.height = assetHeight;
        rect1.size.width = assetWidth;
        //styleButton.frame = rect1;
        styleButton.frame = CGRectMake(i*assetScrollXOrigin, assetScrollYOrigin, assetWidth, assetHeight);
        */
        
        styleButton.tag = i;	// tag our images for later use when we place them in serial fashion
        
        [styleButton addTarget:self action:@selector(addBubbleWithId:) forControlEvents:UIControlEventTouchDown];
        
        // add images to the thumbnail scrollview
        [thumbnailScrollView addSubview:styleButton];

    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.thumbnailScrollView.delegate=self;
    [thumbnailScrollView layoutAssets];
}

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
    
    if([resourceList count]>0 && [resourceList count]> resourceIndex)
    {
        Resource* resource = [resourceList objectAtIndex:(resourceIndex)];
        if(resource!=nil)
        {
            NSString* type = resource.type;
            
            CGRect resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
            if([type isEqual:@"d"])
            {
                //resourceFrame = CGRectMake(100, 100, decoratorWidth, decoratorHeight);
                resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, decoratorWidth, decoratorHeight);
                
            }
            if([type isEqual:@"f"])
            {
                resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                //resourceFrame = CGRectMake(0.0, 20.0, frameWidth, frameHeight);
            }
            
            //ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andURL:resource.imageURL andType:type andId:resource.resourceId];
            //ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andURL:resource.imageURL andType:type andId:resource.resourceId andScale:1.0];
            ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andResource:resource andScale:1.0 andAngle:0.0];
            
            rv.center = self.imageView.center;
            [self.view addSubview:rv];
        }//end if resource!=nil
    }//end if
    
}


- (void)viewDidLoad
{

    [super viewDidLoad];
    //NSLog(@"Edit.viewDidLoad");
    
    resourceCounter = 0;
    resourceList = [[NSMutableArray alloc] init];
    resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate = self;
    
    //Initiate thumbnail scrollview
    [self initiateScrollViews];
    
    //Add speechbubbles to thumbnail scrollview
    [self addSpeechBubblesToScrollView];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int currentThemeId= [[prefs objectForKey:@"current_theme_id"] integerValue];
    //NSLog(@"current_theme_id=%i", currentThemeId);
    //Add resources to thumbnail scrollview
    [resourceLoader submitRequestGetResourcesForTheme:currentThemeId];
    
    [self registerForKeyboardNotifications];
    
    keyboardIsShown = NO;
    
    imageSize = CGSizeMake(panelWidth, panelHeight);
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    singleTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTap];
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


-(void)initiateScrollViews
{
    
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
    
    
    if([[segue identifier] isEqualToString:@"panelPosterView"]){
        PhotoPosterViewController *ppvc = (PhotoPosterViewController *)[segue destinationViewController];
        
        ppvc.image = self.imageView.image;
        /*
         imageView.contentMode = UIViewContentModeScaleAspectFill;
         imageView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);
         */
        ppvc.editMode = YES;
        ppvc.editedPhoto=currentPanel.photo;
        //NSLog(@"currentPanel.photo.photoId=%i", currentPanel.photo.photoId);
        
        for (UIView *subview in self.view.subviews)
        {
            //upload resources with the photo
            if([subview isMemberOfClass:[ResourceView class]])
            {
                ResourceView* sbv =(ResourceView*)subview;
                //NSLog(@"posted pre-rotation.sbv.angle=%f", sbv.angle);
                if(sbv.angle!=0.00)
                {
                    sbv.transform = CGAffineTransformMakeRotation(0.00);
                }

                //[sbv removeFromSuperview];
                
                /*
                NSLog(@"posted pre-rotation.sbv.frame=%@", NSStringFromCGRect(sbv.frame));
                NSLog(@"posted pre-rotation.sbv.bounds%@", NSStringFromCGRect(sbv.bounds));
                */
                
                ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andResource:sbv.resource andScale:sbv.scale andAngle:sbv.angle];
                //ResourceView *new_sbv = [[ResourceView alloc] initWithResourceView:sbv];
                new_sbv.originalFrame = sbv.frame;
                
                if(sbv.angle!=0.00)
                {
                    sbv.transform = CGAffineTransformMakeRotation(sbv.angle);
                }
                /*
                NSLog(@"posted new_sbv.originalFrame=%@", NSStringFromCGRect(new_sbv.originalFrame));
                NSLog(@"posted after-rotation new_sbv.frame=%@", NSStringFromCGRect(new_sbv.frame));
                NSLog(@"posted after-rotation new_sbv.bounds%@", NSStringFromCGRect(new_sbv.bounds));
                NSLog(@"new_sbv.scale=%f", new_sbv.scale);
                */
                
                new_sbv.userInteractionEnabled = NO;
                [ppvc.view addSubview:new_sbv];
                //NSLog(@"resource added for posting.");
            }
        }//end for
        
        for (UIView *subview in self.view.subviews)
        {
            //upload speech bubbles with the photo
            if([subview isMemberOfClass:[SpeechBubbleView class]])
            {
                SpeechBubbleView* sbv =(SpeechBubbleView*)subview;
                SpeechBubbleView *new_sbv = [[SpeechBubbleView alloc] initWithFrame:sbv.frame andText:sbv.textView.text andStyle:sbv.styleId];
                new_sbv.userInteractionEnabled = NO;
                [ppvc.view addSubview:new_sbv];
                
                //NSLog(@"speechbubble added for posting.");
            }
        }//end for
        
    } //end if
    
    if([[segue identifier] isEqualToString:@"panelView"])
    {

    }

}

-(void)addResourceToScrollViews:(Resource*)resource
{
    if(resource!=nil)
    {
        if([resource.type isEqualToString:@"f"])
        {
            return;
        }
        
        /*
        //int resourceId = resource.resourceId;
        NSString* thumb_url = resource.thumbURL;
        
        //UIImage *image = [UIImage imageNamed:resource.thumbURL];
        
        NSData *imageURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumb_url]];
         UIImage *image = [UIImage imageWithData:imageURL];
        
        UIButton *styleButton = [[UIButton alloc] initWithFrame:thumbFrame];
        [styleButton setImage:image forState:UIControlStateNormal];
        */
        
        
        
        //UIButton *styleButton = [[UIButton alloc] initWithFrame:thumbFrame];
        UIButton *styleButton = [[UIButton alloc] initWithFrame:CGRectMake((numSpeechBubbles+resourceCounter)*assetScrollXOrigin, assetScrollYOrigin, assetWidth, assetHeight)];
        
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
            
            [resourceImageView setImageWithURL:[NSURL URLWithString:[resource.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil
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

        
        /*
        CGRect rect1 = styleButton.frame;
        rect1.size.height = assetHeight;
        rect1.size.width = assetWidth;
        //styleButton.frame = rect1;
        styleButton.frame = CGRectMake((numSpeechBubbles+resourceCounter)*assetScrollXOrigin, assetScrollYOrigin, assetWidth, assetHeight);
        //styleButton.tag = resource.resourceId;	// tag our images for later use when we place them in serial fashion
        */
        
        styleButton.tag = resourceCounter;	// tag our images for later use when we place them in serial fashion
        
        [styleButton addTarget:self action:@selector(addResourceWithId:) forControlEvents:UIControlEventTouchDown];
        // add images to the thumbnail scrollview
        [thumbnailScrollView addSubview:styleButton];
        
        [resourceList addObject:resource];
        resourceCounter++;
        
        if(resourceCounter==[resourceList count])
        {
            [thumbnailScrollView layoutAssets];
        }
        
    }
    
}

-(NSArray*)arrayByRemovingObject:(NSArray*)array andResource:(Resource*)resource
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray removeObject:resource];
    return [NSArray arrayWithArray:newArray];
}

#pragma mark ResourceLoader functions.
-(void)ResourceLoader:(ResourceLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"resource failed to load.");
    
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResources:(NSArray*)resources{
    //NSLog(@"resources loaded. %i", [resources count]);

    if(resources!=nil)
    {
        
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



- (IBAction)imagesButtonPressed:(id)sender {
    
    if(!alertShown)
    {
        alertShown = YES;
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Lose changes?"
                                                          message:@"You will lose all changes."
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Confirm", nil];
        [message show];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Confirm"])
    {
        alertShown = NO;
        [self.navigationController popViewControllerAnimated:YES];
        //[self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if([title isEqualToString:@"Cancel"])
    {
        //NSLog(@"Button 2 was selected.");
        alertShown = NO;
        return;
    }
}



@end
