//
//  PanelEditViewControllerII.m
//  PhotoChat
//
//  Created by Umar Rashid on 06/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "CameraViewController.h"
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

@interface PanelEditViewController ()

@end

@implementation PanelEditViewController


@synthesize imageView;
@synthesize url;

@synthesize keyboardIsShown;
@synthesize imageSize;
@synthesize thumbnailScrollView;

@synthesize resourceList;
@synthesize currentPanel;
@synthesize panelId;

@synthesize subviewId;
@synthesize originalFrame;

ResourceLoader *resourceLoader;
NSMutableArray *resourceList;

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
    [super viewWillAppear:animated];
    

    if(self.imageView.image) return; //If image already loaded - do not reload it (since load moved from viewDidLoad)
    
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
    //NSLog(@"loadAnnotations. currentPanel.panelId=%i", currentPanel.panelId);
    //NSLog(@"loadAnnotations. currentPanel.annotations=%i", [currentPanel.annotations count]);
    
    if(currentPanel!=nil)
    {

    if(currentPanel.annotations!=nil)
    {
        for(Annotation* annotation in currentPanel.annotations)
        {
            //NSLog(@"annotation=%@", annotation.text);
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
            
        }
         
     }
    }

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
        UIButton *styleButton = [[UIButton alloc] initWithFrame:thumbFrame];
        [styleButton setBackgroundImage:image forState:UIControlStateNormal];
        
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



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.thumbnailScrollView.delegate=self;
    //NSLog(@"viewDidAppear.thumbnail.numItems=%i", [thumbnailScrollView numItems]);
    [thumbnailScrollView layoutAssets];
    [self loadAnnotations];

}

/*
- (void)loadImage:(UIImage*) image
{
    self.imageView.frame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
    self.imageView.image = image;
    
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
    
    if([resourceList count]>0)
    {
        Resource* resource = [resourceList objectAtIndex:(resourceIndex)];
        NSString* type = resource.type;
        
        CGRect resourceFrame;
        if([type isEqual:@"d"])
        {
            resourceFrame = CGRectMake(100, 100, decoratorWidth, decoratorHeight);
        }
        if([type isEqual:@"f"])
        {
            resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
        }
        
        ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andURL:resource.imageURL andType:type andId:resource.resourceId];
        [self.view addSubview:rv];
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    resourceCounter = 0;
    
    //Initiate thumbnail scrollview
    [self initiateScrollViews];
    
    //Add speechbubbles to thumbnail scrollview
    [self addSpeechBubblesToScrollView];
    
    
    resourceList = [[NSMutableArray alloc] init];
    
    resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate = self;
    [resourceLoader submitRequestGetResourcesForTheme:1];
    
    [self registerForKeyboardNotifications];
    
    keyboardIsShown = NO;
    
    imageSize = CGSizeMake(panelWidth, panelHeight);
    
    [self loadAnnotations];
    
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

-(void)initiateScrollViews
{
    
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
        
        for (UIView *subview in self.view.subviews)
        {
            //upload speech bubbles with the photo
            if([subview isMemberOfClass:[SpeechBubbleView class]])
            {
                SpeechBubbleView* sbv =(SpeechBubbleView*)subview;
                SpeechBubbleView *new_sbv = [[SpeechBubbleView alloc] initWithFrame:sbv.frame andText:sbv.textView.text andStyle:sbv.styleId];
                new_sbv.userInteractionEnabled = NO;
                [ppvc.view addSubview:new_sbv];
                
                NSLog(@"speechbubble added for posting.");
            }
            
            //upload resources with the photo
            if([subview isMemberOfClass:[ResourceView class]])
            {
                ResourceView* sbv =(ResourceView*)subview;
                
                ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andURL:sbv.urlImageString andType:sbv.type andId:sbv.resourceId];
                new_sbv.userInteractionEnabled = NO;
                [ppvc.view addSubview:new_sbv];
                NSLog(@"resource added for posting.");
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
        //int resourceId = resource.resourceId;
        NSString* thumb_url = resource.thumbURL;
        
        UIImage *image = [UIImage imageNamed:resource.thumbURL];
        
        NSData *imageURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumb_url]];
        image = [UIImage imageWithData:imageURL];
        
        UIButton *styleButton = [[UIButton alloc] initWithFrame:thumbFrame];
        [styleButton setImage:image forState:UIControlStateNormal];
        
        CGRect rect1 = styleButton.frame;
        rect1.size.height = assetHeight;
        rect1.size.width = assetWidth;
        styleButton.frame = rect1;
        //styleButton.tag = resource.resourceId;	// tag our images for later use when we place them in serial fashion
        styleButton.tag = resourceCounter;	// tag our images for later use when we place them in serial fashion
        
        [styleButton addTarget:self action:@selector(addResourceWithId:) forControlEvents:UIControlEventTouchDown];
        // add images to the thumbnail scrollview
        [thumbnailScrollView addSubview:styleButton];
        
        [resourceList addObject:resource];
        resourceCounter++;
        
    }
    
}

#pragma mark ResourceLoader functions.
-(void)ResourceLoader:(ResourceLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"resource failed to load.");
    
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResources:(NSArray*)resources{
    NSLog(@"resources loaded. %i", [resources count]);

    numResources = [resources count];
    thumbnailScrollView.numItems = numSpeechBubbles + numResources;
    
    for(Resource* resource in resources)
    {
        if (resource.resourceId > 0)
        {
            [self addResourceToScrollViews:resource];
            
        }//end if
        
        
    }//end for
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResource:(Resource*)resource
{
    NSLog(@"Resource downloaded");
}



@end
