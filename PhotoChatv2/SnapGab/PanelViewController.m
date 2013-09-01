//
//  PanelViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 01/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "PanelEditViewController.h"
#import "PanelViewController.h"
#import "PanelAddViewController.h"
#import "UIImageView+WebCache.h"
#import "SpeechBubbleView.h"
#import "ResourceView.h"
#import "PanelLoader.h"
#import "PhotoLoader.h"
#import "ResourceLoader.h"
#import "ResourceImageView.h"
#import "ImageDownloader.h"
#import "GUIConstant.h"
#import "Annotation.h"


#import <QuartzCore/QuartzCore.h>
#import "ThumbnailView.h"

@interface PanelViewController ()

@end

@implementation PanelViewController

@synthesize panelScrollView;
@synthesize thumbnailScrollView;

@synthesize thumbPage;
@synthesize currentPage;
@synthesize currentPanel;
@synthesize currentPanelId;
@synthesize numPanels;

@synthesize panels;
@synthesize sessionToken;
//@synthesize activityIndicator;
@synthesize editButton;
@synthesize imagesLabel;
@synthesize menuButton;

BOOL _bubblesAdded;
BOOL _resourcesAdded;
BOOL initialized;
BOOL thumbMode;
BOOL singleTapped;

PhotoLoader *photoLoader;
PanelLoader *panelsLoader;
ResourceLoader *resourceLoader;

NSString* urlImageString;

int panelId;
int panelCounter;
int thumbnailIndex;
int numPlacements;
int placementCounter;

CGPoint lastContentOffSet;

Panel* currentPanel;
Placement* currentPlacement;

NSArray *resourceList;
NSArray *placementList;
NSMutableArray* downloadedPanels;
NSMutableArray* downloadedPhotos;
NSArray* photos;

NSFileManager* fileMgr;
NSString *documentsDirectory;

int thumbnailsCompleted;
UILabel* clickLabel;
UIActivityIndicatorView *activityIndicator;

- (void)updateScrollViews
{
    
    //NSLog(@"updateScrollViews.numPanels=%i", numPanels);
    if(self.panels!=nil)
    {
        if([self.panels count]>0)
        {
            panelScrollView.numItems = [panels count];
            thumbnailScrollView.numItems = [panels count];
            
            // place the panels in serial layout within the scrollview
            [panelScrollView layoutItems];
            
            // place the thumbnail in serial layout within the scrollview
            [thumbnailScrollView layoutItems];
            
            currentPage = [self.panels count]-1;
            //currentPage = 0;
            
            //NSLog(@"updateScrollViews.currentPage=%i", currentPage);
            
            currentPanel = [self.panels objectAtIndex:(currentPage)];
            //if(currentPanel!=nil)
            //    NSLog(@"updateScrollViews.currentPanel.panelId=%i", currentPanel.panelId);
            
            //Scroll to the last added panel in the serial layout within the scrollview
            [panelScrollView scrollItemToVisible:(currentPage)];
            
            //Add bubbles and resources to the current panel after scrolling
            [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
            
            //Scroll to the last added thumbnail in the serial layout within the scrollview
            [thumbnailScrollView scrollItemToVisible:(currentPage)];
            
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
            //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
            singleTap.cancelsTouchesInView = NO;
            [thumbnailScrollView addGestureRecognizer:singleTap];
        }//end if (self.panels count]>0

        
    }//end if(self.panels!=nil)
    
}//end updateScrollViews


- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    //UIButton *clicked = (UIButton *) sender;
    //int styleId = clicked.tag;
    // Determine the position of clicked thumbnail
    CGPoint touchPoint=[gesture locationInView:thumbnailScrollView];
    CGFloat pos = (CGFloat)touchPoint.x / thumbnailWidth;
    //CGFloat pos = (CGFloat)self.thumbnailScrollView.contentOffset.x / thumbnailWidth;
    
    int page = round(ceilf(pos));
    if(currentPage!=page-1)
    {
        currentPage = page - 1;
        //NSLog(@"currentPage=%i, page=%i", currentPage, page);
        if(currentPage>=0 && currentPage<[self.panels count])
        {
            //NSLog(@"singleTapcaptured.currentPage=%i", currentPage);
            currentPanel = [self.panels objectAtIndex:(currentPage)];

            //NSNumber* yesObj = [NSNumber numberWithBool:YES];
            //[downloadedPhotos replaceObjectAtIndex:currentPage withObject:yesObj];
            
            //NSLog(@"singleTap. touchPoint.x = %f", (CGFloat)touchPoint.x);
            //NSLog(@"singleTap. page= %i and currentPage=%i", page, currentPage);

            //Remove bubbles and resources from the current view
            [self removeAllBubbles];
            [self removeAllResources];
            
            // Scroll to the most rcently added panel in panel scrollview
            [panelScrollView scrollItemToVisible:(currentPage)];
        }

    }//end if
    //else
    {
        /*
        if((page-1) < [downloadedPhotos count])
        {
            NSNumber* yesObj = [NSNumber numberWithBool:YES];
            [downloadedPhotos replaceObjectAtIndex:(page-1) withObject:yesObj];
        }
         */
    }//end else

}


-(id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {


        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newPanelNotification:)
                                                     name:@"newPanelNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newPanelNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newPanelNotification)
                                                     name:@"newPanelNotification"
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newPanelNotification)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
         */

    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) initiateDataSet
{
    //NSLog(@"initiateDataset");
    
    numPanels = 0;
    panelCounter = 0;
    
    numPlacements = 0;
    placementCounter = 0;
 
    thumbnailsCompleted = 0;
    
    panels = [[NSArray alloc] init];
    resourceList = [[NSArray alloc] init];
    placementList = [[NSArray alloc] init];
    downloadedPanels = [[NSMutableArray alloc] init];
    downloadedPhotos = [[NSMutableArray alloc] init];
    
    currentPanel = [[Panel alloc] init];
    
    panelsLoader = [[PanelLoader alloc] init];
    panelsLoader.delegate = self;

    resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate = self;
    
    _bubblesAdded = NO;
    _resourcesAdded = NO;
    initialized = NO;
    thumbMode = NO;
    
    lastContentOffSet= CGPointMake(0.0, 0.0);
    
    fileMgr = [NSFileManager defaultManager];
    ///Library/Caches
    documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //NSLog(@"PanelViewController.viewDidLoad");
    
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

    [self.imagesLabel setFont:[UIFont fontWithName: @"Transit Display" size:28]];
    
    [menuButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    menuButton.layer.borderWidth=4.0f;
    menuButton.clipsToBounds = YES;
    menuButton.layer.cornerRadius = 10;//half of the width
    [menuButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    menuButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    editButton.clipsToBounds = YES;
    //editButton.layer.borderColor=[UIColor whiteColor].CGColor;
    //editButton.layer.borderWidth=2.0f;

    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
    activityIndicator.center = self.view.center;
    activityIndicator.hidesWhenStopped = YES;
	[self.view addSubview: activityIndicator];
    //[activityIndicator startAnimating];
    
    clickLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(0, 40, 320, 320)];
    clickLabel.textColor = [UIColor whiteColor];
    clickLabel.backgroundColor = [UIColor blackColor];
    clickLabel.text = [NSString stringWithFormat: @"No images in the group. Please add."];
    [clickLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    
    
    //[self initiateDataSet];
    //[self initiateScrollViews];

    //[panelsLoader submitRequestGetPanelsForGroup];
}


- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"PanelViewController.viewWillAppear");
    [super viewWillAppear:YES];

    //Remove any speech bubbles, resources and scrollviews
    for (UIView *subview in self.view.subviews)
    {
        if([subview isMemberOfClass:[SpeechBubbleView class]] || [subview isMemberOfClass:[ResourceView class]]
           || [subview isMemberOfClass:[MainScrollSelector class]])
        {
            [subview removeFromSuperview];
        }
    }
    
    [activityIndicator startAnimating];

    [self initiateDataSet];
    [self initiateScrollViews];
    
    
    [activityIndicator startAnimating];
    [panelsLoader submitRequestGetPanelsForGroup];
}



- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"PanelViewController.viewDidAppear");
    [super viewDidAppear:YES];
 
    /*
    for (UIView *subview in self.view.subviews)
    {
        if([subview isMemberOfClass:[SpeechBubbleView class]] || [subview isMemberOfClass:[ResourceView class]]
           || [subview isMemberOfClass:[MainScrollSelector class]])
        {
            [subview removeFromSuperview];
        }
    }
    */
    
    /*
    [self initiateDataSet];
    [self initiateScrollViews];
    
    [panelsLoader submitRequestGetPanelsForGroup];
    */
    //[panelsLoader submitRequestGetPanelsForGroup];
}


-(void)initiateScrollViews
{
    //NSLog(@"initiateScrollView.numPanels=%i", numPanels);
    // Add panels scrollview
    CGRect panelFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
    CGSize panelSize = CGSizeMake(panelWidth, panelHeight);
    //panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize andNumItems:numPanels];
    panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize];
    panelScrollView.tag=0;
    panelScrollView.delegate=self;
    [self.view addSubview:panelScrollView];
    
    //NSLog(@"initiateScrollView.panelScrollView.subviews.count=%i", [[panelScrollView subviews] count]);
    
    // Add thumbnails scrollview
    CGRect thumbFrame = CGRectMake(thumbnailScrollXOrigin, thumbnailScrollYOrigin, thumbnailScrollObjWidth, thumbnailScrollObjHeight);
    CGSize thumbnailSize = CGSizeMake(thumbnailWidth, thumbnailHeight);
    //thumbnailScrollView = [[MainScrollSelector alloc] initWithFrame:thumbFrame andItemSize:thumbnailSize andNumItems:numPanels];
    thumbnailScrollView = [[MainScrollSelector alloc] initWithFrame:thumbFrame andItemSize:thumbnailSize];
    thumbnailScrollView.tag=1;
    thumbnailScrollView.delegate=self;
    [self.view addSubview:thumbnailScrollView];
}

-(void)cleanupData{
    //NSLog(@"cleanUpData");
  
}

-(void)removeAllBubbles
{
    for (UIView *subview in self.view.subviews)
    {
        if([subview isMemberOfClass:[SpeechBubbleView class]])
        {
            [subview removeFromSuperview];
        }
    }
    _bubblesAdded = NO;
}


-(void)removeAllResources
{
    for (UIView *subview in self.view.subviews)
    {
        if([subview isMemberOfClass:[ResourceView class]])
        {
            [subview removeFromSuperview];
        }
    }
    _resourcesAdded = NO;
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewWillBeginDragging%i.", scrollView.tag);
    //Remove bubbles and resources from the panel when the scrolling starts
    if(scrollView.tag==0)
    {
        [self removeAllBubbles];
        [self removeAllResources];
    }//end if

}


-(void)alignPageInPanelScrollView
{
    thumbMode = NO;
    //NSLog(@"PanelViewController.alignPageInPanelScrollView.numPanels=%i", numPanels);
    if([self.panels count]>0)
    {
        [activityIndicator startAnimating];
        
        //[activityIndicator startAnimating];
        //NSLog(@"alignPage. numPanels= %i", numPanels);
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        
        
        //NSLog(@"alignPage. lastContentOffSet=%f, panelScrollView.contentOffset.x=%f, pos=%f, page=%i", lastContentOffSet.x, panelScrollView.contentOffset.x, pos, page);
        
        //When the last panel is scrolled leftward, refresh the panels
        if(lastContentOffSet.x==panelScrollView.contentOffset.x && currentPage==[self.panels count]-1)
        {
           //NSLog(@"alignPage.Time to refresh.");
           [panelsLoader submitRequestRefreshGetPanelsForGroup];
        }
        
        lastContentOffSet = panelScrollView.contentOffset;

        //NSLog(@"alignPageInPanelScrollView. page=%i, currentPage=%i.", page, currentPage);
        if(page!=currentPage)
        {
            //NSLog(@"alignPageInPanelScrollView. page=%i, currentPage=%i. annotations & placements removed.", page, currentPage);
            [self removeAllBubbles];
            [self removeAllResources];
        }
        
        //NSLog(@"alignPageInPhotoTableView.page=%i, and currentPage=%i", page, currentPage);
        currentPage = page;

        //NSLog(@"alignPageInPhotoTableView.currentPage=%i, [panelScrollView.subviews count]=%i", currentPage, [panelScrollView.subviews count]);
        
        //Add new panel after scrolling
        if(currentPage>=0 && currentPage<[self.panels count])
        {
            //Load new panel after scrolling
            //NSLog(@"alignPageInPhotoTableView. objectAtIndex:currentPage, currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
            
            currentPanel = [self.panels objectAtIndex:currentPage];
            //NSLog(@"alignPageInPanelScrollView.page=%i,currentPage=%i, panelId=%i", page, currentPage, currentPanel.panelId);
            if(currentPanel!=nil)
            {
                //BOOL displayed= NO;
                //Check if the panel is already displayed in the panel scrollview
                for(UIView* subView in panelScrollView.subviews)
                {
                    if(subView.tag==currentPage && [subView isMemberOfClass:[UIImageView class]])
                    {
                        //displayed=YES;
                        [subView removeFromSuperview];
                        break;
                    }//end if
                }//end for
                
                //NSLog(@"alignPageInPanelScrollView.page=%i,currentPage=%i, panelId=%i, displayed=%d", page, currentPage, currentPanel.panelId, displayed);
                 //Check if the panel is not already displayed in the panel scrollview, display it
                //if(!displayed)
                {
                    UIImageView *imageView = [[UIImageView alloc] init];
                    
               
                    //NSFileManager* fileMgr = [NSFileManager defaultManager];
                    //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", currentPanel.photo.photoId];
                    NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                    BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                    

                    //NSLog(@"alignPageinPanelScrollView. Panel[%i].[%@] File exists=%d, currentPanel.photo.imageURL=%@", currentPanel.panelId, imageName, fileExists, currentPanel.photo.imageURL);
                    //NSLog(@"alignPageinPanelScrollView. Panel[%i].[%@] File exists=%d, currentPanel.photo.photoId=%i, currentPage=%i", currentPanel.panelId, imageName, fileExists, currentPanel.photo.photoId, currentPage);
                    
                    
                    if(!fileExists)
                    {
                        //[imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:nil];
                        
                        [imageView setImageWithURL:[NSURL URLWithString:[currentPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                   placeholderImage:nil
                                          completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                         {
                             //NSLog(@"alignPageinPanelScrollView.saving image=%@ for panel[%i], currentPage=%i", imageName, currentPanel.panelId, currentPage);
                             NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                             [data1 writeToFile:currentFile atomically:YES];

                         }];

                    }//end if(!fileExists)
                    else if(fileExists)
                    {
                        UIImage* image = [UIImage imageWithContentsOfFile:currentFile];
                        NSData *imgData = UIImagePNGRepresentation(image);
                        //NSLog(@"alignPageinPanelScrollView.Size of Image%i (bytes):%d",currentPage, [imgData length]);
                        
                        //Check if corrupt image is not downloaded. E.g size less than 640x640 (=409600) bytes
                        if([imgData length]>=409600)
                        {
                            //NSLog(@"alignPageinPanelScrollView.Loading image from file=%@", imageName);
                            [imageView setImage:image];
                        }//end if([imgData length]>409600)
                        else if([imgData length]<409600)
                        {
                            //If corrupt image downloaded earlier, download full image from the server and save it locally
                            [imageView setImageWithURL:[NSURL URLWithString:[currentPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                      placeholderImage:nil
                                             completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                             {
                                 //NSLog(@"alignPageinPanelScrollView.saving image=%@ for panel[%i], currentPage=%i", imageName, currentPanel.panelId, currentPage);
                                 NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                 [data1 writeToFile:currentFile atomically:YES];
                                 
                             }];
                            
                        }//end else if([imgData length]<409600)

                        //[imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                        //[imageView setImage:[UIImage imageNamed:currentFile]];
                    }//end if(fileExists)

                    //[imageView setImageWithURL:[NSURL URLWithString:[currentPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                    
                    imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                    imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion
                    
                    [imageView setContentMode:UIViewContentModeScaleAspectFill];
                    imageView.clipsToBounds= YES;
                    //[activityIndicator stopAnimating];
                    // add images to the panel scrollview
                    [panelScrollView addSubview:imageView];
                    //NSLog(@"alignPageinPanelScrollView. Panel#%i added", currentPage);
                    
                }//end if(!displayed)
                //else
                {
                    //NSLog(@"alignPageInPanelScrollView.panel#%i, displayed=%d", currentPage, displayed);
                }
                

                [activityIndicator stopAnimating];
                //[activityIndicator removeFromSuperview];
                thumbMode = NO;
                
                
                //NSLog(@"alignPageInPhotoTableView. downloadedPanels objectAtIndex:currentPage.currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
                
                //Check if the panel alongwith placements and annotations have already been downloaded
                //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                //NSLog(@"alignPageInPanelScrollView.thumbMode=%d. Panel#%i downloaded=%d.", thumbMode, currentPage, panelDownloaded);
                //if(!panelDownloaded)
                {
                    //NSLog(@"alignPageInPanelScrollView. Panel#%i download called. thumbMode=%d", currentPage, thumbMode);
                    //Download annotations and placements of the panel
                    [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
                }
                
                //else
                {
                    /*
                    //NSLog(@"placements already downloaded.");
                    [self loadPlacements:currentPanel];
                    //NSLog(@"annotations already downloaded are added.");
                    [self loadAnnotations:currentPanel];
                     */
                    
                    //[thumbnailScrollView scrollItemToVisible:(currentPage)];
                    //if([self.panels count]<=4)
                    //    [self alignPageInThumbnailScrollView];
                }//end else
                
 
                if(currentPage==[self.panels count]-1)
                {
                    [self displayPageInPanelScrollView:currentPage-1];
                }
                else if(currentPage<[self.panels count]-1)
                {
                    [self displayPageInPanelScrollView:currentPage+1];
                    if(currentPage>0)
                        [self displayPageInPanelScrollView:currentPage-1];
                }

                //Remove other panels to free up memory
                if([self.panels count]>3)
                {
                    for(UIView* subView in panelScrollView.subviews)
                    {
                        if([subView isMemberOfClass:[UIImageView class]])
                        {
                            if(subView.tag!=currentPage && subView.tag!=currentPage-1 && subView.tag!=currentPage+1)
                                //&& subView.tag!=currentPage-2 && subView.tag!=currentPage+2)
                                //if(subView.tag!=currentPage)
                            {
                                [subView removeFromSuperview];
                            }
                        }//end if
                    }//end for(UIView* subView in panelScrollView.subviews)                   
                }//end if([panels count]>3)
                 
                 
                 
            }//if currentPanel!=nil

        }//end if currentPage>=0 && currentPage<[self.panels count]
        
    }//end if numPanels>0
}

-(void)displayPageInPanelScrollView:(int)page
{
    //NSLog(@"displayPageInPanelScrollView.page=%i, [panelScrollView.subviews count]=%i", page, [panelScrollView.subviews count]);
    if(page>=0 && page<[self.panels count])
    {
        BOOL displayed= NO;
        for(UIView* subView in panelScrollView.subviews)
        {
            if(subView.tag==page && [subView isMemberOfClass:[UIImageView class]])
            {
                displayed=YES;
                break;
            }//end if
        }//end for
        
        //NSLog(@"displayPageInPanelScrollView.panel#%i displayed=%d.", page, displayed);
        if(!displayed)
        {
            //NSLog(@"displayPageInPanelScrollView.objectAtIndex:page");
            Panel* panel = [self.panels objectAtIndex:page];
            //NSLog(@"displayPageInPanelScrollView.page=%i,currentPage=%i, panelId=%i", page, currentPage, panel.panelId);
            if(panel!=nil)
            {
                UIImageView *imageView = [[UIImageView alloc] init];
                //[imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
                
                //NSFileManager* fileMgr = [NSFileManager defaultManager];
                //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
      
                 NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", panel.photo.photoId];
                 NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                 BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                 
                 //NSLog(@"displayPageinPanelScrollView. Panel[%i].[%@] File exists=%d", panel.panelId, imageName, fileExists);
                 if(!fileExists)
                 {
                     //[imageView setImageWithURL:[NSURL URLWithString:[panel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                     
                     [imageView setImageWithURL:[NSURL URLWithString:[panel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                               placeholderImage:nil
                                      completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                      {
                          NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                          [data1 writeToFile:currentFile atomically:YES];
                          
                      }];
                     
                 
                 }//end if(!fileExists)
                 else if(fileExists)
                 {
                     UIImage* image = [UIImage imageWithContentsOfFile:currentFile];
                     NSData *imgData = UIImagePNGRepresentation(image);
                     //NSLog(@"displayPageinPanelScrollView. Size of Image%i (bytes):%d",page, [imgData length]);
                     
                     //Check if corrupt image is not downloaded. E.g size less than 640x640 (=409600) bytes
                     if([imgData length]>=409600)
                     {
                         //NSLog(@"displayPageinPanelScrollView. Loading image from file=%@", imageName);
                         [imageView setImage:image];
                     }//end if([imgData length]>409600)
                     else if([imgData length]<409600)
                     {
                         //If corrupt image downloaded earlier, download full image from the server and save it locally
                         [imageView setImageWithURL:[NSURL URLWithString:[panel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                   placeholderImage:nil
                                          completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                          {
                              NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                              [data1 writeToFile:currentFile atomically:YES];
                              
                          }];
                         
                     }//end else if([imgData length]<409600)
                     
                     //[imageView setImage:[UIImage imageNamed:currentFile]];
                     //[imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                 }//end if(fileExists)
                 
                [imageView setContentMode:UIViewContentModeScaleAspectFill];
                imageView.frame = CGRectMake(page*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                imageView.tag = page;	// tag our images for later use when we place them in serial fashion
                imageView.clipsToBounds= YES;
                // add images to the panel scrollview
                
                [panelScrollView addSubview:imageView];
            }//end if panel!=nil
        }//end if(!displayed)
        
    }//end if(page>=0 && page<[panels count])
}

-(void)alignPageInThumbnailScrollView
{
    //NSLog(@"alignPageInThumbnailScrollView.numPanels=%i", numPanels);
    if(numPanels>0)
    {
        //NSLog(@"alignPageInThumbnailScrollView.thumbPage=%i and currentPage=%i", thumbPage, currentPage);
        //NSLog(@"alignPage. numPanels= %i", numPanels);
        CGFloat pos = (CGFloat)self.thumbnailScrollView.contentOffset.x / thumbnailWidth;
        //CGFloat pos1 = (CGFloat)self.thumbnailScrollView.contentOffset.x / panelScrollObjWidth;
        int page = round(ceilf(pos));
        thumbPage = page;
        
        //NSLog(@"alignPageInThumbnailScrollView. pos1=%f, pos=%f, page=%i, thumbPage=%i and currentPage=%i",pos1, pos, page, thumbPage, currentPage);
        
        //Add new panels to thumbnailscrollviews
        if(page>=0 && page<[self.panels count])
        {
            thumbnailIndex = thumbPage;
            /*
            for(int i=thumbnailIndex; i<thumbnailIndex+4; i++)
            {
                if(i<[self.panels count])
                {
                    UIActivityIndicatorView* aIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    aIndicator.frame = CGRectMake((i-thumbPage)*thumbnailWidth, thumbnailScrollYOrigin, thumbnailWidth, thumbnailScrollObjHeight);
                    aIndicator.center = CGPointMake(aIndicator.frame.origin.x+(thumbnailWidth/2), thumbnailScrollYOrigin+(thumbnailScrollObjHeight/2));
                    aIndicator.tag = i;
                    [aIndicator startAnimating];
                    [self.view addSubview:aIndicator];
                }

            }
            */
            
            [self generateThumbails];
            /*
            for(int index=page; index<page+4; index++)
            {
                //Load new panel after scrolling
                if(index<[self.panels count])
                {
                    Panel* thumbnailPanel = [self.panels objectAtIndex:(index)];
                    if(thumbnailPanel!=nil)
                    {                    
                        if(thumbnailPanel.thumbnail==nil)
                        {
                            CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                            ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                            thumbnailPanel.thumbnail=thumbnailView.snapshot;
                        }
                        
                        UIImageView *imageView = [[UIImageView alloc] init];
                        [imageView setImage:thumbnailPanel.thumbnail];
                        imageView.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);
                        imageView.tag = index;
                        [thumbnailScrollView addSubview:imageView];
                        
                        break;
                    }//end if(thumbnailPanel!=nil)
                    
                }//end if
            }//end for
            
            */
            
            /*
            if([panels count]>4)
            {
                for(UIView* subView in thumbnailScrollView.subviews)
                {
                    if(subView.tag>page+3 || subView.tag<page)
                    {
                        [subView removeFromSuperview];
                    }
                }//end for
            }//end if([panels count]>4)
            */
        }//end if page>=0 && page<[self.panels count]
    }//end if _numImages>0
}


-(void)generateThumbails
{
    //thumbnailIndex = thumbPage;
    //NSLog(@"generateThumbnails. thumbMode=%d. thumbnailIndex=%i, thumbPage=%i", thumbMode, thumbnailIndex, thumbPage);
    thumbMode = YES;
    //Load new panel after scrolling
    if(thumbnailIndex<[self.panels count])
    {
        //NSLog(@"generateThumbnails. thumbnailIndex=%i", thumbnailIndex);
        //NSLog(@"generateThumbnails. self.panels objectAtIndex:currentPage.currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
        Panel* thumbnailPanel = [self.panels objectAtIndex:(thumbnailIndex)];
        //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:thumbnailIndex] boolValue];
        
        //NSLog(@"PanelViewController.generateThumbails.Panel#%i. downloaded=%d" , thumbnailIndex, panelDownloaded);
        //if(!panelDownloaded)
        {
            //NSLog(@"generateThumbnails. Panel%i download called.", thumbnailIndex);
            //Download annotations and placements of the panel
            [panelsLoader submitRequestGetPanelWithId:thumbnailPanel.panelId];
        }
        //else
        {
            //NSLog(@"generateThumbnails. Panel#%i already downloaded.", thumbnailIndex);
        }
        [self displayThumbails];
        
    }//end if(thumbnailIndex<[self.panels count])
}

-(void)displayThumbails
{
    //NSLog(@"displayThumbails called");
    for(int index=thumbPage; index<thumbPage+4; index++)
    {
        //NSLog(@"displayThumbails.index=%i, thumbPage=%i", index, thumbPage);
        if(index<[self.panels count])
        {
            BOOL indicatorExists = NO;
            UIActivityIndicatorView* aIndicator;
            
            for(UIView* subView in thumbnailScrollView.subviews)
            {
                if([subView isMemberOfClass:[UIActivityIndicatorView class]] && subView.tag==index)
                {
                    indicatorExists = YES;
                    break;
                }
            }
            //NSLog(@"indicatorExists[%i]=%d", index, indicatorExists);
            
            if(!indicatorExists)
            {
                aIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                aIndicator.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailScrollObjHeight);
                aIndicator.center = CGPointMake(aIndicator.frame.origin.x+(thumbnailWidth/2), 0+(thumbnailScrollObjHeight/2));
                aIndicator.tag=index;
                aIndicator.hidesWhenStopped = YES;
                [aIndicator startAnimating];
                //[self.view addSubview:aIndicator];
                [thumbnailScrollView addSubview:aIndicator];
            }

            //NSLog(@"displayThumbails. self.panels objectAtIndex:currentPage.currentPage=%i, index=%i, [self.panels count]=%i", currentPage, index, [self.panels count]);
            Panel* thumbnailPanel = [self.panels objectAtIndex:index];
            //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:thumbnailIndex] boolValue];
            BOOL panelDownloaded = [[downloadedPanels objectAtIndex:index] boolValue];
            //NSLog(@"displayThumbnails. PanelIndex=%i is downloaded=%d has placements=%i, annotations=%i", index, panelDownloaded, [thumbnailPanel.placements count], [thumbnailPanel.annotations count]);
            if(thumbnailPanel!=nil && panelDownloaded)
            //if(thumbnailPanel!=nil)
            {
                //NSLog(@"displayThumbnails. PanelIndex=%i is downloaded=%d has placements=%i", index, panelDownloaded, [thumbnailPanel.placements count]);
                //NSData *imgData = UIImagePNGRepresentation(thumbnailPanel.thumbnail);
                //NSLog(@"Size of Image%i (bytes):%d",index, [imgData length]);
                
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);

                CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                if(thumbnailView.snapshot==nil)
                {

                    if(thumbnailView.image==nil)
                    {
                        //NSLog(@"PanelViewController. panel#%i panelPhoto%i both snapshot and image Nil.",index, thumbnailPanel.photo.photoId);
                        
                        //If thumbnail photo has been downloaded, display it in thumbnail scrollview, otherwise display panel photo
                        if(thumbnailView.thumbnailPhoto!=nil)
                        {
                            [imageView setImageWithURL:[NSURL URLWithString:[thumbnailView.thumbnailPhoto.thumbURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                        }//end if(thumbnailView.thumbnailPhoto!=nil)
                        else if(thumbnailView.thumbnailPhoto==nil)
                        {
                            //[imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                            
                            NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", thumbnailPanel.photo.photoId];
                            NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                            BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                            
                            //NSLog(@"displayPageinPanelScrollView. Panel[%i].[%@] File exists=%d", panel.panelId, imageName, fileExists);
                            if(!fileExists)
                            {
                                
                                [imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                          placeholderImage:nil
                                                 completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                                 {
                                     NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                     [data1 writeToFile:currentFile atomically:YES];
                                     
                                 }];
                                
                                
                            }//end if(!fileExists)
                            else if(fileExists)
                            {
                                UIImage* image = [UIImage imageWithContentsOfFile:currentFile];
                                NSData *imgData = UIImagePNGRepresentation(image);
                                //NSLog(@"displayPageinPanelScrollView. Size of Image%i (bytes):%d",page, [imgData length]);
                                
                                //Check if corrupt image is not downloaded. E.g size less than 640x640 (=409600) bytes
                                if([imgData length]>=409600)
                                {
                                    //NSLog(@"displayPageinPanelScrollView. Loading image from file=%@", imageName);
                                    [imageView setImage:image];
                                }//end if([imgData length]>409600)
                                else if([imgData length]<409600)
                                {
                                    //If corrupt image downloaded earlier, download full image from the server and save it locally
                                    [imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                              placeholderImage:nil
                                                     completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                                     {
                                         NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                         [data1 writeToFile:currentFile atomically:YES];
                                         
                                     }];
                                    
                                }//end else if([imgData length]<409600)
                                
                                //[imageView setImage:[UIImage imageNamed:currentFile]];
                                //[imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                            }//end if(fileExists)
                        }//end if(thumbnailView.thumbnailPhoto==nil)

                        
                    }//end if(thumbnailView.image==nil) 
                    else if(thumbnailView.image!=nil)
                    {
                        //NSLog(@"PanelViewController. panel#%i panelPhoto%i snapshot nil, image not nil.",index, thumbnailPanel.photo.photoId);
                        [imageView setImage:thumbnailView.image];
                    }

                }//end if(thumbnailView.snapshot==nil)
                else if(thumbnailView.snapshot!=nil)
                {
                    if(thumbnailView.image==nil)
                    {
                        //NSLog(@"PanelViewController. panel#%i panelPhoto%i snapshot not nil, image nil.",index, thumbnailPanel.photo.photoId);
                        //[imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                        
                        NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", thumbnailPanel.photo.photoId];
                        NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                        BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                        
                        //NSLog(@"displayPageinPanelScrollView. Panel[%i].[%@] File exists=%d", panel.panelId, imageName, fileExists);
                        if(!fileExists)
                        {
                            
                            [imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                      placeholderImage:nil
                                             completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                             {
                                 NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                 [data1 writeToFile:currentFile atomically:YES];
                                 
                             }];
                            
                            
                        }//end if(!fileExists)
                        else if(fileExists)
                        {
                            UIImage* image = [UIImage imageWithContentsOfFile:currentFile];
                            NSData *imgData = UIImagePNGRepresentation(image);
                            //NSLog(@"displayPageinPanelScrollView. Size of Image%i (bytes):%d",page, [imgData length]);
                            
                            //Check if corrupt image is not downloaded. E.g size less than 640x640 (=409600) bytes
                            if([imgData length]>=409600)
                            {
                                //NSLog(@"displayPageinPanelScrollView. Loading image from file=%@", imageName);
                                [imageView setImage:image];
                            }//end if([imgData length]>409600)
                            else if([imgData length]<409600)
                            {
                                //If corrupt image downloaded earlier, download full image from the server and save it locally
                                [imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                          placeholderImage:nil
                                                 completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                                 {
                                     NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                     [data1 writeToFile:currentFile atomically:YES];
                                     
                                 }];
                                
                            }//end else if([imgData length]<409600)
                            
                            //[imageView setImage:[UIImage imageNamed:currentFile]];
                            //[imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                        }//end if(fileExists)
                        
                    }
                    
                    if(thumbnailView.image!=nil)
                    {
                        //NSLog(@"PanelViewController. panel#%i panelPhoto%i snapshot and image not nil.",index, thumbnailPanel.photo.photoId);
                        //CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                        //ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                        thumbnailPanel.thumbnail=thumbnailView.snapshot;
                        [imageView setImage:thumbnailPanel.thumbnail];
                    }
                }//end else if(thumbnailView.snapshot!=nil)
                
                //[imageView setImage:thumbnailPanel.thumbnail];
                //[imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                
                imageView.tag = index;
                //[thumbnailScrollView addSubview:thumbnailView];
                [thumbnailScrollView addSubview:imageView];

                for(UIView* subView in thumbnailScrollView.subviews)
                {
                    if([subView isMemberOfClass:[UIActivityIndicatorView class]] && subView.tag==index)
                    {
                        UIActivityIndicatorView* aIndicator = (UIActivityIndicatorView*) subView;
                        [aIndicator stopAnimating];
                        //[aIndicator removeFromSuperview];
                        //NSLog(@"displayThumbnails.indicator#%i stopped", index);
                        break;
                    }//end if
                }//end for
                
            }//end if(thumbnailPanel!=nil)
        }//end if(index<[self.panels count])
        
        //if(index==thumbPage)
        //    break;
        
    }//end for(int index=thumbPage; index<thumbPage+4; index++)
    
    /*
    for(UIView* subView in self.view.subviews)
    {
        if([subView isMemberOfClass:[ UIActivityIndicatorView class]])
        {
            UIActivityIndicatorView* aIndicator = (UIActivityIndicatorView*) subView;
            [aIndicator stopAnimating];
            //[aIndicator removeFromSuperview];
        }//end if
    }//end for
*/
    //NSLog(@"thumbPage=%i", thumbPage);

    //if(thumbPage<=currentPage)
    {
        for(int page=thumbPage-1; page>thumbPage-5; page--)
        {
            [self displayPageInThumbnailScrollView:page];
        }
        
        for(int page=thumbPage+5; page<thumbPage+9; page++)
        {
            [self displayPageInThumbnailScrollView:page];
        }
    }//end if(thumbPage<=currentPage)


    if([self.panels count]>4)
    {
        for(UIView* subView in thumbnailScrollView.subviews)
        {
            if([subView isMemberOfClass:[UIImageView class]])
            {
                if(subView.tag>thumbPage+8 || subView.tag<thumbPage-4)
                {
                    [subView removeFromSuperview];
                }
            }
           

        }//end for
    }//end if([panels count]>4)

}//end displayThumbails

-(void)displayPageInThumbnailScrollView:(int)page
{
    if(page>=0 && page<[self.panels count])
    {
        BOOL displayed= NO;
        for(UIView* subView in thumbnailScrollView.subviews)
        {
            if(subView.tag==page && [subView isMemberOfClass:[UIImageView class]])
            {
                displayed=YES;
                break;
            }//end if
        }//end for
        
        
        //NSLog(@"displayPageInThumbnailScrollView.panel#%i displayed=%d.", page, displayed);
        if(!displayed)
        {
            //NSLog(@"displayPageInThumbnailScrollView.objectAtIndex:page");
            Panel* thumbnailPanel = [self.panels objectAtIndex:page];
            //BOOL photoDownloaded = [[downloadedPhotos objectAtIndex:page] boolValue];
            //NSLog(@"displayPageInPanelScrollView.page=%i,currentPage=%i, panelId=%i", page, currentPage, panel.panelId);
            
            if(thumbnailPanel!=nil)
            {
              
                UIImageView *imageView = [[UIImageView alloc] init];
                
                CGRect thumbFrame= CGRectMake(page*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                if(thumbnailView.snapshot==nil)
                {
                    
                    if(thumbnailView.image==nil)
                    {
                        //NSLog(@"PanelViewController. panel#%i panelPhoto%i both snapshot and image Nil.",index, thumbnailPanel.photo.photoId);
                        
                        //If thumbnail photo has been downloaded, display it in thumbnail scrollview, otherwise display panel photo
                        if(thumbnailView.thumbnailPhoto!=nil)
                        {
                            [imageView setImageWithURL:[NSURL URLWithString:[thumbnailView.thumbnailPhoto.thumbURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                        }//end if(thumbnailView.thumbnailPhoto!=nil)
                        else if(thumbnailView.thumbnailPhoto==nil)
                        {
                            //[imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                            
                            NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", thumbnailPanel.photo.photoId];
                            NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                            BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                            
                            //NSLog(@"displayPageinPanelScrollView. Panel[%i].[%@] File exists=%d", panel.panelId, imageName, fileExists);
                            if(!fileExists)
                            {
                                
                                [imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                          placeholderImage:nil
                                                 completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                                 {
                                     NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                     [data1 writeToFile:currentFile atomically:YES];
                                     
                                 }];
                                
                                
                            }//end if(!fileExists)
                            else if(fileExists)
                            {
                                UIImage* image = [UIImage imageWithContentsOfFile:currentFile];
                                NSData *imgData = UIImagePNGRepresentation(image);
                                //NSLog(@"displayPageinPanelScrollView. Size of Image%i (bytes):%d",page, [imgData length]);
                                
                                //Check if corrupt image is not downloaded. E.g size less than 640x640 (=409600) bytes
                                if([imgData length]>=409600)
                                {
                                    //NSLog(@"displayPageinPanelScrollView. Loading image from file=%@", imageName);
                                    [imageView setImage:image];
                                }//end if([imgData length]>409600)
                                else if([imgData length]<409600)
                                {
                                    //If corrupt image downloaded earlier, download full image from the server and save it locally
                                    [imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                              placeholderImage:nil
                                                     completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                                     {
                                         NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                         [data1 writeToFile:currentFile atomically:YES];
                                         
                                     }];
                                    
                                }//end else if([imgData length]<409600)
                                
                                //[imageView setImage:[UIImage imageNamed:currentFile]];
                                //[imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                            }//end if(fileExists)
                            
                            
                        }//end else if(thumbnailView.thumbnailPhoto==nil)
                        
                        
                    }//end if(thumbnailView.image==nil)
                    else if(thumbnailView.image!=nil)
                    {
                        //NSLog(@"PanelViewController. panel#%i panelPhoto%i snapshot nil, image not nil.",index, thumbnailPanel.photo.photoId);
                        [imageView setImage:thumbnailView.image];
                    }//end else if(thumbnailView.image!=nil)
                    
                }//end if(thumbnailView.snapshot==nil)
                else if(thumbnailView.snapshot!=nil)
                {
                    if(thumbnailView.image==nil)
                    {
                        //NSLog(@"PanelViewController. panel#%i panelPhoto%i snapshot not nil, image nil.",index, thumbnailPanel.photo.photoId);
                        //[imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                        
                        NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", thumbnailPanel.photo.photoId];
                        NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                        BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                        
                        //NSLog(@"displayPageinPanelScrollView. Panel[%i].[%@] File exists=%d", panel.panelId, imageName, fileExists);
                        if(!fileExists)
                        {
                            
                            [imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                      placeholderImage:nil
                                             completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                             {
                                 NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                 [data1 writeToFile:currentFile atomically:YES];
                                 
                             }];
                            
                            
                        }//end if(!fileExists)
                        else if(fileExists)
                        {
                            UIImage* image = [UIImage imageWithContentsOfFile:currentFile];
                            NSData *imgData = UIImagePNGRepresentation(image);
                            //NSLog(@"displayPageinPanelScrollView. Size of Image%i (bytes):%d",page, [imgData length]);
                            
                            //Check if corrupt image is not downloaded. E.g size less than 640x640 (=409600) bytes
                            if([imgData length]>=409600)
                            {
                                //NSLog(@"displayPageinPanelScrollView. Loading image from file=%@", imageName);
                                [imageView setImage:image];
                            }//end if([imgData length]>409600)
                            else if([imgData length]<409600)
                            {
                                //If corrupt image downloaded earlier, download full image from the server and save it locally
                                [imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                          placeholderImage:nil
                                                 completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                                 {
                                     NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                     [data1 writeToFile:currentFile atomically:YES];
                                     
                                 }];
                                
                            }//end else if([imgData length]<409600)
                            
                            //[imageView setImage:[UIImage imageNamed:currentFile]];
                            //[imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                        }//end if(fileExists)
                        
                    }
                    
                    if(thumbnailView.image!=nil)
                    {
                        //NSLog(@"PanelViewController. panel#%i panelPhoto%i snapshot and image not nil.",index, thumbnailPanel.photo.photoId);
                        //CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                        //ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                        thumbnailPanel.thumbnail=thumbnailView.snapshot;
                        [imageView setImage:thumbnailPanel.thumbnail];
                    }
                }//end else if(thumbnailView.snapshot!=nil)

                
                //[imageView setImageWithURL:[NSURL URLWithString:[panel.photo.thumbURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                imageView.frame = CGRectMake(page*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);
                imageView.tag = page;	// tag our images for later use when we place them in serial fashion
                // add images to the panel scrollview
                [thumbnailScrollView addSubview:imageView];
                 
            }//end if thumbnailPanel!=nil
        }//end if(!displayed)
        
    }//end if(page>=0 && page<[panels count])
}//end displayPageInThumbnailScrollView

/*
-(UIImage*) imageWithView:(UIView*)view
{
    NSLog(@"imageWithView");
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
*/


-(BOOL)checkFileExists:(NSString*)fileName
{
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
    return fileExists;
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndScrollingAnimation.scrollView.tag=%i", scrollView.tag);
    if(scrollView.tag==0)
        [self alignPageInPanelScrollView];
    if(scrollView.tag==1)
        [self alignPageInThumbnailScrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating.scrollView.tag=%i", scrollView.tag);
    if(scrollView.tag==0)
        [self alignPageInPanelScrollView];
    if(scrollView.tag==1)
        [self alignPageInThumbnailScrollView];
}

- (void)newPanelNotification:(NSNotification*)note
{
    
    NSDictionary *theData = [note userInfo];
    if (theData != nil) {
        NSString* message = [theData objectForKey:@"panelnotification"];
        NSLog(@"PanelViewController.notification: %@", message);
        //[[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else{
        //NSLog(@"PanelViewController.Nil data. New panel uploaded.");
    }
}

-(void)newImageNotification
{
    NSLog(@"New image uploaded.");
    //[self removeAllBubbles];
    //[self removeAllResources];
    /*
    [self initiateDataSet];
    [self initiateScrollViews];
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
	activityIndicator.center = self.view.center;
	[self.view addSubview: activityIndicator];
    [activityIndicator startAnimating];
    
    [panelsLoader submitRequestGetPanelsForGroup:1];
    //[self initiateDataSet];
    //[self initiateScrollViews];
    //[panelsLoader submitRequestGetPanelsForGroup:1];
    //[self updateScrollViews];
     */
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
   
    if([[segue identifier] isEqualToString:@"addPanelView"])
    {
        PanelAddViewController *pavc = (PanelAddViewController *)[segue destinationViewController];
        pavc.initialized = NO;
        
    }
    
    //NSLog(@"PanelViewController.segue called.[self.panels count]=%i", [self.panels count]);
    if([self.panels count]>0)
    {
        /*
        NSMutableArray* panelAssestExist = [[NSMutableArray alloc] initWithCapacity:[self.panels count]];
        
        for(int i=0; i<[self.panels count]; i++)
        {
            Panel* panel = [self.panels objectAtIndex:i];
            if(panel!=nil)
            {
                int assestsExist =  [panelsLoader submitSQLRequestGetAssetsForPanel:panel.panelId];
                [panelAssestExist addObject:[NSNumber numberWithInt:assestsExist]];
                //NSLog(@"PanelViewController.segue. panelId=%i, assestsExist=%i", panel.panelId, assestsExist);
            }
            
        }
        
        for(int i=0; i<[panelAssestExist count]; i++)
        {
            int assetsExist = [[panelAssestExist objectAtIndex:i] integerValue];
            NSLog(@"assetsExist=%i", assetsExist);
        }
         */
        //for(int i=0; i<[self.panels count]; i++)
        {
            
            //Panel* panel = [self.panels objectAtIndex:i];
            //if(panel!=nil)
            {
                //NSLog(@"panel#[%i].panelId=%i", i, panel.panelId);
                //if(panel.placements!=nil && panel.annotations!=nil)
                {
                    /*
                    NSLog(@"panel#[%i].panelId=%i", i, panel.panelId);
                    int panelExists = [panelsLoader submitSQLRequestCheckPanelExists:panel.panelId];
                    NSLog(@"PanelViewController.segue. Panel#%i.panelId=%i, panelExists=%i", i, panel.panelId, panelExists);
                    if(panelExists==0)
                    {
                        NSMutableArray* panelsLocal = [[NSMutableArray alloc] init];
                        [panelsLocal addObject:panel];
                        
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
                        [panelsLoader submitSQLRequestSavePanelsForGroup:panelsLocal andGroupHashId:currentGroupHashId];
                    }
                     */
                    /*
                    int assestsExist =  [panelsLoader submitSQLRequestGetAssetsForPanel:panel.panelId];
                    NSLog(@"PanelViewController.segue. panelId=%i, assestsExist=%i", panel.panelId, assestsExist);
                    //if(panelExists==1 && assestsExist==0)
                    if(assestsExist==0)
                    {
                        
                        [panelsLoader submitSQLRequestSaveAssetsForPanel:panel.panelId andPlacements:panel.placements andAnnotations:panel.annotations];
                        
                    }
                 */
    }
                
            }
        }//end for
    }//end if

    
    
    
    if([[segue identifier] isEqualToString:@"panelstomenu"])
    {
        //NSLog(@"panelstomenu");
        /*
        //To prevent the app from crashing when thumbnail resources are being downloaded
        NSMutableArray* panelsMutable = [[NSMutableArray alloc] initWithArray:self.panels];
        [panelsMutable removeAllObjects];
        self.panels = panelsMutable;
        
        panelsMutable = [[NSMutableArray alloc] initWithArray:downloadedPanels];
        [panelsMutable removeAllObjects];
        downloadedPanels = panelsMutable;
        
        panelsMutable = [[NSMutableArray alloc] initWithArray:downloadedPhotos];
        [panelsMutable removeAllObjects];
        downloadedPhotos = panelsMutable;
        */
        [self.panelScrollView removeFromSuperview];
        [self.thumbnailScrollView removeFromSuperview];
    }
    

    
    
    if([[segue identifier] isEqualToString:@"editPanel"])
    {
        if([self.panels count]>0 && [self.panels count]>currentPage)
        {
            //NSLog(@"editPanel.currentPage=%i", currentPage);
            Panel *panel = [self.panels objectAtIndex:(currentPage)];
            if(panel!=nil)
            {
                PanelEditViewController *pevc = (PanelEditViewController *)[segue destinationViewController];
                pevc.url = [NSURL URLWithString:panel.photo.imageURL];
                pevc.currentPanel = panel;
                pevc.currentPage = currentPage;
                
                //NSLog(@"editPanel called.");
               
                
                for (UIView *subview in self.view.subviews)
                {

                   
                    //Add Resources
                    if([subview isMemberOfClass:[ResourceView class]])
                    {
                        ResourceView* sbv =(ResourceView*)subview;
                        
                        if(sbv.angle!=0.00)
                            sbv.transform = CGAffineTransformMakeRotation(0.0);
                        
                        ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andResource:sbv.resource andScale:sbv.scale andAngle:sbv.angle];
                        
                        if(sbv.angle!=0.00)
                            sbv.transform = CGAffineTransformMakeRotation(sbv.angle);
                        
                        new_sbv.userInteractionEnabled = YES;
                        new_sbv.alpha = 0;
                        [pevc.view addSubview:new_sbv];
                    }
                    
                    
                }//end for
              
                for (UIView *subview in self.view.subviews)
                {
                    //Add Speech Bubbles
                    if([subview isMemberOfClass:[SpeechBubbleView class]])
                    {
                        //NSLog(@"edited.speechbubble added.");
                        SpeechBubbleView* sbv =(SpeechBubbleView*)subview;
                        SpeechBubbleView *new_sbv = [[SpeechBubbleView alloc] initWithFrame:sbv.frame andText:sbv.textView.text andStyle:sbv.styleId];
                        new_sbv.userInteractionEnabled = YES;
                        new_sbv.alpha = 0;
                        [pevc.view addSubview:new_sbv];
                    }
                }//end for
                
            }//end if panel!=nil
        }//end if numPanels>0
    }//end if
}


-(void)loadPanelsToScrollViews
{
    //NSLog(@"PanelViewController.loadPanelsToScrollViews. self.panels.count=%i", [self.panels count]);
    if([self.panels count]>0)
    {

        
        panelScrollView.numItems = [panels count];
        [panelScrollView layoutItems];
        
        thumbnailScrollView.numItems = [panels count];
        [thumbnailScrollView layoutItems];
        
        //Scroll panelscrollview and thumbnailscrollview to the last item
        currentPage = [panels count]-1;
        //[panelScrollView scrollItemToVisible:(currentPage)];
        //[thumbnailScrollView scrollItemToVisible:(currentPage)];
        
     

        [panelScrollView scrollItemToVisible:(currentPage)];
        //Display panel if there is only 1 panel in the scrollview
        if([panels count]==1)
            [self alignPageInPanelScrollView];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        singleTap.cancelsTouchesInView = NO;
        [thumbnailScrollView addGestureRecognizer:singleTap];
        
        //if([panels count]<=4)
        //    [self alignPageInThumbnailScrollView];
        /*
        currentPanel= [panels objectAtIndex:currentPage];
        if(currentPanel!=nil)
        {
            if(currentPanel.photo!=nil)
            {
                //Add to panelscrollview
                UIImageView *imageView = [[UIImageView alloc] init];
                [imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                imageView.tag = currentPage;	
                [panelScrollView addSubview:imageView];
            }//end if(currentPanel.photo!=nil)
        }//end if(currentPanel!=nil)
         */

    }//end if [panels count]>0
}

-(NSArray*)arrayByReplacingObject:(NSArray*)array andObjectIndex:(int)index andNewObject:(Panel*)panel
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray replaceObjectAtIndex:index withObject:panel];
    //[newArray addObject:object];
    return [NSArray arrayWithArray:newArray];
}

-(NSArray*)arrayByRemovingObject:(NSArray*)array andResource:(Resource*)resource
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray removeObject:resource];
    return [NSArray arrayWithArray:newArray];
}

-(void)loadAnnotations:(Panel*)panel
{
    if (panel!=nil)
    {
        currentPanel = panel;
        //panelId = panel.panelId;
        if(panel.annotations!=nil)
        {
            for(Annotation* annotation in panel.annotations)
            {
                //NSLog(@"annotation=%@", annotation.text);
                CGRect xywh = CGRectMake(annotation.xOffset,
                                         annotation.yOffset,0,0);
                
                NSString* text = annotation.text;
                int styleId = annotation.bubbleStyle;
                
                SpeechBubbleView* sbv = [[SpeechBubbleView alloc] initWithFrame:xywh andText:text andStyle:styleId];
                sbv.userInteractionEnabled = NO;
                sbv.alpha = 0.0f;
                [self.view addSubview:sbv];
                [UIView transitionWithView:self.view
                                  duration:0.25
                                   options:UIViewAnimationOptionLayoutSubviews
                                animations:^ { sbv.alpha = 1.0f; }
                                completion:nil];
                
            }
            _bubblesAdded = YES;
        }//end if
    }//end if panel!=null
}

-(void)loadPlacements:(Panel*)panel
{
    //NSLog(@"loadPlacements.");
    if (panel != nil)
    {
        currentPanel = panel;
        //panelId = panel.panelId;
        
        if(panel.placements!=nil)
        {
            numPlacements = [panel.placements count];
            int placementCounter = 0;
            //for(Placement* placement in panel.placements)
            
            if(numPlacements > 0)
            {
                for(placementCounter=0; placementCounter<numPlacements; placementCounter++)
                {
                    //NSLog(@"loadPlacements. currentPanel.resources objectAtIndex:currentPage.currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
                    Resource* resource = [currentPanel.resources objectAtIndex:placementCounter];
                    if(resource!=nil)
                    {
                        
                        NSString* type = resource.type;
                        float defaultScale = 1.0;
                        float defaultAngle = 0.0;
                        
                        CGRect resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                        if([type isEqual:@"d"])
                        {
                            if(currentPanel.placements!=nil && [currentPanel.placements count]>placementCounter)
                            {
                                //NSLog(@"loadPlacements. currentPanel.placements objectAtIndex:currentPage.currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
                                Placement* placement = [currentPanel.placements objectAtIndex:placementCounter];
                                if(placement!=nil)
                                {
                                    resourceFrame = CGRectMake(placement.xOffset,
                                                               placement.yOffset,
                                                               decoratorWidth, decoratorHeight);
                                    defaultScale = placement.scale;
                                    defaultAngle = placement.angle;
                                }
                            }
                        }
                        if([type isEqual:@"f"])
                        {
                            resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                        }
                        
                        
                        ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andResource:resource andScale:defaultScale andAngle:defaultAngle];
                        rv.userInteractionEnabled = NO;
                        [self.view addSubview:rv];
                        NSLog(@"loadPlacements.currentPage=%i, resource[%i].resourceId=%i added", currentPage, placementCounter, resource.resourceId);
                        
                    }//end if resource!=nil

                }//end for
            }//end if
            /*
            if(numPlacements > 0)
            {
                int resourceId = [[panel.placements objectAtIndex:placementCounter] resourceId];
                [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                
                
            }//end for
            */
            _resourcesAdded = YES;
        }//end if
    }//end if panel!=null
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"PanelViewController.Panel failed to load.");
    //[self performSegueWithIdentifier:@"panelsToMenu" sender:self];
    [activityIndicator stopAnimating];
    
}


-(void)PanelLoader:(PanelLoader*)loader didLoadPanels:(NSArray*)panelsLocal{

    
    panels= panelsLocal;
    numPanels = [panelsLocal count];
    //NSLog(@"PanelViewController.didLoadPanels.numPanels=%i", numPanels);
    if(numPanels==0)
    {
        [activityIndicator stopAnimating];
        [self.view addSubview:clickLabel];

            //NSLog(@"groupHashId=%@", groupHashId);
        editButton.enabled = NO;
        editButton.alpha = 0.4;

    }
    
    else if(numPanels>0)
    {
        [clickLabel removeFromSuperview];
        editButton.enabled = YES;
        editButton.alpha = 1.0;
    }
    //    [activityIndicator startAnimating];
    
    //NSLog(@"PanelViewController.didLoadPanels.numPanels=%i", numPanels);
    //[photoLoader submitRequestGetPhotosForGroup:@"8fc8a0ed74ea82888c7a37b0f62a105b83d07a12"];
    //NSLog(@"didLoadPanels.numPanels=%i", numPanels);
    //initialzed array to boolean NO. No panel downloaded yet.

    for (int i=0; i<numPanels;i++)
    {
        NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
        [downloadedPanels addObject:panelDownloaded];
        [downloadedPhotos addObject:panelDownloaded];
    }
    
    //NSLog(@"PanelViewController.didLoadPanels.initialized=%d", initialized);
    if(!initialized)
    {
        initialized = YES;
        [self loadPanelsToScrollViews];
        [activityIndicator stopAnimating];
        
    }

}

-(void)PanelLoader:(PanelLoader*)loader didLoadRefreshedPanels:(NSArray*)panelsLocal{
    

    NSLog(@"PanelViewController.didLoadRefreshedPanels. currentPanels=%i, [panelsLocal count]=%i", [panels count], [panelsLocal count]);
    //NSMutableArray *newPanels = [NSMutableArray arrayWithCapacity:[panels count] + [panelsLocal count]];
    [self removeAllBubbles];
    [self removeAllResources];
    
  
    for (int i=0; i<[panelsLocal count];i++)
    {
        NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
        [downloadedPanels addObject:panelDownloaded];
        [downloadedPhotos addObject:panelDownloaded];
    }
    
    //Remove all the existing panel
    for(UIView* subView in panelScrollView.subviews)
    {
        //if(subView.tag==(numPanels-1) && [subView isMemberOfClass:[UIImageView class]])
        if([subView isMemberOfClass:[UIImageView class]])
        {
            [subView removeFromSuperview];
        }//end if
    }//end for
    
    //Remove all the existing thumbnails
    for(UIView* subView in thumbnailScrollView.subviews)
    {
        //if(subView.tag==(numPanels-1) && [subView isMemberOfClass:[UIImageView class]])
        if([subView isMemberOfClass:[UIImageView class]])
        {
            [subView removeFromSuperview];
        }//end if
    }//end for

    initialized = NO;
    NSMutableArray *newPanels;
    if(panels!=nil && [panels count]>0)
    {
        newPanels = [[NSMutableArray alloc] initWithArray:panels];
        [newPanels addObjectsFromArray:panelsLocal];
    }

    panels = newPanels;
    numPanels = [newPanels count];
    


    
    //NSLog(@"PanelViewController.didLoadRefreshedPanels.initialized=%d", initialized);
    if(!initialized)
    {
        initialized = YES;
        
        panelScrollView.numItems = [panels count];
        [panelScrollView layoutItems];
        
        thumbnailScrollView.numItems = [panels count];
        [thumbnailScrollView layoutItems];
        

        //Scroll panelscrollview and thumbnailscrollview to the last item
        currentPage = [panels count]-1;
        
        [panelScrollView scrollItemToVisible:(currentPage)];
        //[thumbnailScrollView scrollItemToVisible:(currentPage)];
        
        //Display panel if there is only 1 panel in the scrollview
        if([panels count]==1)
            [self alignPageInPanelScrollView];

        /*
        [self loadPanelsToScrollViews];
        [activityIndicator stopAnimating];
        */
    }
}



//-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel forObject:(id)obj
-(void)PanelLoader:(PanelLoader*)loader didLoadPanel:(Panel*)panel
{
    //NSLog(@"didLoadPanel. thumbmode=%d", thumbMode);
    //NSLog(@"PanelViewController. didLoadPanel. currentPage=%i, thumbnailIndex=%i, thumbmode=%d", currentPage, thumbnailIndex, thumbMode);
    if (panel!= nil)
    {
        
        
        int index=0;
        if(!thumbMode)
        {
            currentPanel = panel;
            index = currentPage;
        }
        else{
            index = thumbnailIndex;
        }

        //NSLog(@"PanelViewController.didLoadPanel.currentPage=%i, panelIndex=%i, panel.panelId=%i, [panel.placements count]=%i", currentPage, index, panel.panelId, [panel.placements count]);
        
        panelId = panel.panelId;
        //NSLog(@"didloadPanel. self.panels objectAtIndex:currentPage.currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
        Panel* panelInArray = [self.panels objectAtIndex:index];
        
 
        //Replace the panel in the panels array with the downloaded panel that contains annotations and placements
        //panels = [self arrayByReplacingObject:panels andObjectIndex:currentPage andNewObject:currentPanel];
        //NSNumber* yesObj = [NSNumber numberWithBool:YES];
        //[downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
        //NSLog(@"Panel downloaded %i. currentPanel.annotations.count=%i", panel.panelId, [currentPanel.annotations count]);
        //NSLog(@"Panel downloaded %i. currentPanel.placements.count=%i", panel.panelId, [currentPanel.placements count]);
        
        /*
         
        if(panel.annotations!=nil)
        {
            panelInArray.annotations = panel.annotations;
            //NSLog(@"annotations loaded.");
            if([panel.annotations count]>0)
            {
                for(Annotation* annotation in panel.annotations)
                {
                    //NSLog(@"annotation=%@", annotation.text);
                    CGRect xywh = CGRectMake(annotation.xOffset,
                                             annotation.yOffset,0,0);
                    
                    NSString* text = annotation.text;
                    int styleId = annotation.bubbleStyle;
                    
                    if(!thumbMode)
                    {
                        //NSLog(@"Annotation added. currentPage=%i", currentPage);
                        SpeechBubbleView* sbv = [[SpeechBubbleView alloc] initWithFrame:xywh andText:text andStyle:styleId];
                        sbv.userInteractionEnabled = NO;
                        sbv.alpha = 0.0f;
                        [self.view addSubview:sbv];
                        [UIView transitionWithView:self.view
                                          duration:0.25
                                           options:UIViewAnimationOptionLayoutSubviews
                                        animations:^ { sbv.alpha = 1.0f; }
                                        completion:nil];
                    }//end if(!thumbMode)
                }//end for

            }//end if([panel.annotations count]>0)
        }//end if(panel.annotations!=nil)
        */
        
        if(panel.annotations!=nil)
        {
            panelInArray.annotations = panel.annotations;
        }//end if(panel.annotations!=nil)
        
        if(panel.placements!=nil)
        {
            //NSLog(@"didLoadPanel.panel.placements is not nil. thumMode=%d, panelId=%i has placements=%i", thumbMode, panel.panelId, [panel.placements count]);
            panelInArray.placements = panel.placements;
            panel.resources = [[NSMutableArray alloc] init];
            panelInArray.resources = panel.resources;
            
            numPlacements = [panel.placements count];
            //NSLog(@"numPlacements=%i", numPlacements);
            placementCounter = 0;
            //NSLog(@"didLoadPanel.panel.placements is not nil. thumMode=%d, panelId=%i has placements=%i, numPlacements=%i", thumbMode, panel.panelId, [panel.placements count], numPlacements);
            if(numPlacements>0)
            {
                //NSLog(@"placements loaded. thumbMode=%d", thumbMode);
                //NSLog(@"didLoadPanel. self.panels objectAtIndex:currentPage.currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
                if(placementCounter<[panel.placements count])
                {
                    //NSLog(@"didLoadPanel. resourceloader called. thumbMode=%d", thumbMode);
                    int resourceId = [[panel.placements objectAtIndex:placementCounter] resourceId];
                    [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                }
            }//end if
            else if(numPlacements==0)
            {
                
                //Declare a panel downloaded
                NSNumber* yesObj = [NSNumber numberWithBool:YES];
                /*
                if(panel.annotations!=nil)
                {
                    if([panel.annotations count]>0)
                    {
                        for(Annotation* annotation in panel.annotations)
                        {
                            //NSLog(@"annotation=%@", annotation.text);
                            CGRect xywh = CGRectMake(annotation.xOffset,
                                                     annotation.yOffset,0,0);
                            
                            NSString* text = annotation.text;
                            int styleId = annotation.bubbleStyle;
                            
                            if(!thumbMode)
                            {
                                //NSLog(@"Annotation added. currentPage=%i", currentPage);
                                SpeechBubbleView* sbv = [[SpeechBubbleView alloc] initWithFrame:xywh andText:text andStyle:styleId];
                                sbv.userInteractionEnabled = NO;
                                sbv.alpha = 0.0f;
                                [self.view addSubview:sbv];
                                [UIView transitionWithView:self.view
                                                  duration:0.25
                                                   options:UIViewAnimationOptionLayoutSubviews
                                                animations:^ { sbv.alpha = 1.0f; }
                                                completion:nil];
                            }//end if(!thumbMode)
                        }//end for
                        
                    }//end if([panel.annotations count]>0)
                }//end if(panel.annotations!=nil)
                 */
                
                if(!thumbMode)
                {

                    
                    //Add annotations to the panelview
                    if(panel.annotations!=nil)
                    {
                        if([panel.annotations count]>0)
                        {
                            for(Annotation* annotation in panel.annotations)
                            {
                                //NSLog(@"annotation=%@", annotation.text);
                                CGRect xywh = CGRectMake(annotation.xOffset,
                                                         annotation.yOffset,0,0);
                                
                                NSString* text = annotation.text;
                                int styleId = annotation.bubbleStyle;
                                
                                //NSLog(@"Annotation added. currentPage=%i", currentPage);
                                SpeechBubbleView* sbv = [[SpeechBubbleView alloc] initWithFrame:xywh andText:text andStyle:styleId];
                                sbv.userInteractionEnabled = NO;
                                sbv.alpha = 0.0f;
                                [self.view addSubview:sbv];
                                NSLog(@"PanelViewController. didloadPanel. currentPage=%i, annotation added.", currentPage);
                                [UIView transitionWithView:self.view
                                                  duration:0.25
                                                   options:UIViewAnimationOptionLayoutSubviews
                                                animations:^ { sbv.alpha = 1.0f; }
                                                completion:nil];
                            }//end for
                            
                        }//end if([panel.annotations count]>0)
                    }//end if(panel.annotations!=nil)
                    
                    
                    //Declate a panel has been downloaded
                    if(currentPage<[downloadedPanels count])
                    {
                        BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                        if(!panelDownloaded)
                        {
                            [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                        }
                        
                    }
                    
                    /*
                    NSFileManager* fileMgr = [NSFileManager defaultManager];
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString* imageName = [NSString stringWithFormat:@"thumbPhoto%i.png", panelInArray.panelId];
                    NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                    BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                    if(!fileExists)
                    {
                        CGRect thumbFrame= CGRectMake(currentPage*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                        ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:panelInArray];
                        panelInArray.thumbnail=thumbnailView.snapshot;
                        
                        NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(panelInArray.thumbnail)];
                        [data1 writeToFile:currentFile atomically:YES];
                    }//end if(!fileExists)
                    */
                    
                    // Scroll to the current page's thumbnail in thumbnail scrollview, after the panel is downloaded
                    [thumbnailScrollView scrollItemToVisible:(currentPage)];
                    if([panels count]<=4)
                        [self alignPageInThumbnailScrollView];
                    
                }//end if(!thumbMode)
                if(thumbMode)
                {
                    
                    
                    //Declare a panel downloaded
                    if(thumbnailIndex<[downloadedPanels count])
                    {
                        BOOL panelDownloaded = [[downloadedPanels objectAtIndex:thumbnailIndex] boolValue];
                        if(!panelDownloaded)
                        {
                            [downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                        }
                        
                    }

                    /*
                    NSFileManager* fileMgr = [NSFileManager defaultManager];
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString* imageName = [NSString stringWithFormat:@"thumbPhoto%i.png", panel.panelId];
                    NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                    BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                    if(!fileExists)
                    {
                        CGRect thumbFrame= CGRectMake(thumbnailIndex*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                        ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:panelInArray];
                        panelInArray.thumbnail=thumbnailView.snapshot;
                        
                        NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(panelInArray.thumbnail)];
                        [data1 writeToFile:currentFile atomically:YES];
                    }//end if(!fileExists)
                    */
                    
                    //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:thumbnailIndex] boolValue];
                    //NSLog(@"didLoadPanel.thumbMode=%d, downloadedPanels[%i]=%d", thumbMode, thumbnailIndex, panelDownloaded);
                    
                    /*
                    CGRect thumbFrame= CGRectMake(thumbnailIndex*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:panelInArray];
                    panelInArray.thumbnail=thumbnailView.snapshot;
                    */
                    
                    /*
                    if(thumbnailIndex<[downloadedPhotos count])
                    {
                        //BOOL photoDownloaded = [[downloadedPhotos objectAtIndex:thumbnailIndex] boolValue];
                       [downloadedPhotos replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                        
                    }
                     */
                    
                    if(thumbPage+3<[self.panels count])
                    {
                        if(thumbnailIndex<(thumbPage+3))
                        {
                            thumbnailIndex++;
                            [self generateThumbails];
                        }
                        else if(thumbnailIndex==(thumbPage+3))
                        {
                            thumbMode = NO;
                            //NSLog(@"didloadPanel.thumbMode changed to=%d", thumbMode);
                            [self displayThumbails];
                        }
                        
                    }
                    /*
                    if(thumbnailIndex<(thumbPage+3))
                    {
                        thumbnailIndex++;
                        [self generateThumbails];
                    }
                    else if(thumbnailIndex==(thumbPage+3))
                    {
                        thumbMode = NO;
                        NSLog(@"didloadPanel.thumbMode changed to=%d", thumbMode);
                        [self displayThumbails];
                    }
                     */
                }//end if thumbMode
            }//end else if(panel.placements==0)
        }//end if panel.placements!=nil
        
        /*
        else if(panel.placements==nil)
        {
            //NSLog(@"didLoadPanel.panel.placements is nil");
            //Declare a panel downloaded
            NSNumber* yesObj = [NSNumber numberWithBool:YES];
            if(!thumbMode)
            {
                if(currentPage<[downloadedPanels count])
                    [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                
                // Scroll to the current page's thumbnail in thumbnail scrollview
                [thumbnailScrollView scrollItemToVisible:(currentPage)];
                
                //Display thumbnail images if there is only 1 panel
                //if([panels count]<=4)
                //    [self alignPageInThumbnailScrollView];
                
            }//end if(!thumbMode)
            if(thumbMode)
            {
                if(thumbnailIndex<[downloadedPanels count])
                    [downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                
                
                if(thumbnailIndex<(thumbPage+3))
                {
                    thumbnailIndex++;
                    [self generateThumbails];
                }
                else{
                    thumbMode = NO;
                    [self displayThumbails];
                }
            }//end if(thumbMode)
        }//end if(panel.placements==nil)
         */
    }//end if panel!=nil
 
}


#pragma mark ResourceLoader functions.
-(void)ResourceLoader:(ResourceLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"PanelViewController.Resource failed to load.");
    
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResources:(NSArray*)resources{
    NSLog(@"PanelViewController.Resources loaded.");
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResource:(Resource*)resource
{
    //NSLog(@"Resource downloaded.thumbMode=%d, resourceId=%i", thumbMode, resource.resourceId);
    if (resource != nil)
    {
        Panel* resourcePanel;
        if(!thumbMode)
        {
            resourcePanel = currentPanel;
        }
        else
        {
            //NSLog(@"didLoadResource. self.panels objectAtIndex called");
            if(thumbnailIndex<[self.panels count])
                resourcePanel = [self.panels objectAtIndex:thumbnailIndex];
        }
        
        if(resourcePanel==nil){
            //NSLog(@"didLoadResource.resourcePanel is nil");
        }
        
        if(resourcePanel!=nil)
        {
            //Add resource to the panel object's resources array.
            [resourcePanel.resources addObject:resource];
            //NSLog(@"resourcePanel.resources count=%i, thumbMode=%d", [resourcePanel.resources count], thumbMode);

            if(!thumbMode)
            {
                //Add resources to the view if the resourcePanel is the currentPanel (i.e. on display in panelscrollView)
                NSString* type = resource.type;
                float defaultScale = 1.0;
                float defaultAngle = 0.0;
                
                CGRect resourceFrame; //= CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                if([type isEqual:@"d"])
                {
                    if(resourcePanel.placements!=nil && [resourcePanel.placements count]>placementCounter)
                    {
                        //NSLog(@"didLoadResource. resourcePanel.placements objectAtIndex.");
                        Placement* placement = [resourcePanel.placements objectAtIndex:placementCounter];
                        if(placement!=nil)
                        {
                            resourceFrame = CGRectMake(placement.xOffset,
                                                       placement.yOffset,
                                                       decoratorWidth, decoratorHeight);
                            defaultScale = placement.scale;
                            defaultAngle = placement.angle;
                        }//end if(placement!=nil)
                    }//end if(resourcePanel.placements!=nil && [resourcePanel.placements count]>placementCounter)
                }//end if([type isEqual:@"d"])
                if([type isEqual:@"f"])
                {
                    resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                }//end if([type isEqual:@"f"])
                
                //NSLog(@"resourceview added. currentPage=%i", currentPage);
                ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andResource:resource andScale:defaultScale andAngle:defaultAngle];
                rv.userInteractionEnabled = NO;
                [self.view addSubview:rv];
                //NSLog(@"PanelViewController.didloadResource.currentPage=%i, resource.resourceId=%i added", currentPage, resource.resourceId);
            }//end if(!thumbMode)
            
            
            //Download other placements in the placements array
            if(placementCounter<(numPlacements-1))
            {
                placementCounter++;
                if(placementCounter<[resourcePanel.placements count])
                {
                    //NSLog(@"didLoadResource. resourcePanel.placements objectAtIndex:placementCounter. resourceId");
                    int resourceId = [[resourcePanel.placements objectAtIndex:placementCounter] resourceId];
                    //NSLog(@"resourceId #%i", resourceId);
                    [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                }

            }
            else if(placementCounter==(numPlacements-1))
            {
                //NSLog(@"didLoadResources.all placements downloaded.thumbMode=%d", thumbMode);
                //Declaring a panel downloaded after all placements are downloaded
                NSNumber* yesObj = [NSNumber numberWithBool:YES];
                
                /*
                if(resourcePanel.annotations!=nil)
                {
                    if([resourcePanel.annotations count]>0)
                    {
                        for(Annotation* annotation in resourcePanel.annotations)
                        {
                            //NSLog(@"annotation=%@", annotation.text);
                            CGRect xywh = CGRectMake(annotation.xOffset,
                                                     annotation.yOffset,0,0);
                            
                            NSString* text = annotation.text;
                            int styleId = annotation.bubbleStyle;
                            
                            if(!thumbMode)
                            {
                                //NSLog(@"Annotation added. currentPage=%i", currentPage);
                                SpeechBubbleView* sbv = [[SpeechBubbleView alloc] initWithFrame:xywh andText:text andStyle:styleId];
                                sbv.userInteractionEnabled = NO;
                                sbv.alpha = 0.0f;
                                [self.view addSubview:sbv];
                                [UIView transitionWithView:self.view
                                                  duration:0.25
                                                   options:UIViewAnimationOptionLayoutSubviews
                                                animations:^ { sbv.alpha = 1.0f; }
                                                completion:nil];
                            }//end if(!thumbMode)
                        }//end for
                 
                    }//end if([panel.annotations count]>0)
                }//end if(panel.annotations!=nil)
                */
                if(!thumbMode)
                {
                    /*
                    for(int i=0; i<[resourcePanel.resources count]; i++)
                    {
                        Resource* resource = [resourcePanel.resources objectAtIndex:i];
                        //Add resources to the view if the resourcePanel is the currentPanel (i.e. on display in panelscrollView)
                        NSString* type = resource.type;
                        float defaultScale = 1.0;
                        float defaultAngle = 0.0;
                        
                        CGRect resourceFrame; //= CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                        if([type isEqual:@"d"])
                        {
                            if(resourcePanel.placements!=nil && [resourcePanel.placements count]>i)
                            {
                                //NSLog(@"didLoadResource. resourcePanel.placements objectAtIndex.");
                                Placement* placement = [resourcePanel.placements objectAtIndex:i];
                                if(placement!=nil)
                                {
                                    resourceFrame = CGRectMake(placement.xOffset,
                                                               placement.yOffset,
                                                               decoratorWidth, decoratorHeight);
                                    defaultScale = placement.scale;
                                    defaultAngle = placement.angle;
                                }//end if(placement!=nil)
                            }//end if(resourcePanel.placements!=nil && [resourcePanel.placements count]>placementCounter)
                        }//end if([type isEqual:@"d"])
                        if([type isEqual:@"f"])
                        {
                            resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                        }//end if([type isEqual:@"f"])
                        
                        //NSLog(@"resourceview added. currentPage=%i", currentPage);
                        ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andResource:resource andScale:defaultScale andAngle:defaultAngle];
                        rv.userInteractionEnabled = NO;
                        [self.view addSubview:rv];
                        NSLog(@"PanelViewController.didloadResource.currentPage=%i, resource.resourceId=%i added", currentPage, resource.resourceId);
                    }//end for                    
                    */
                    
                    if(resourcePanel.annotations!=nil)
                    {
                        if([resourcePanel.annotations count]>0)
                        {
                            for(Annotation* annotation in resourcePanel.annotations)
                            {
                                //NSLog(@"annotation=%@", annotation.text);
                                CGRect xywh = CGRectMake(annotation.xOffset,
                                                         annotation.yOffset,0,0);
                                
                                NSString* text = annotation.text;
                                int styleId = annotation.bubbleStyle;
                                
                                //NSLog(@"Annotation added. currentPage=%i", currentPage);
                                SpeechBubbleView* sbv = [[SpeechBubbleView alloc] initWithFrame:xywh andText:text andStyle:styleId];
                                sbv.userInteractionEnabled = NO;
                                sbv.alpha = 0.0f;
                                [self.view addSubview:sbv];
                                //NSLog(@"PanelViewController. didloadResource. currentPage=%i, annotation added.", currentPage);
                                [UIView transitionWithView:self.view
                                                  duration:0.25
                                                   options:UIViewAnimationOptionLayoutSubviews
                                                animations:^ { sbv.alpha = 1.0f; }
                                                completion:nil];
                            }//end for
                            
                        }//end if([panel.annotations count]>0)
                    }//end if(panel.annotations!=nil)
                    
                    //Declare a panel downloaded
                    if(currentPage<[downloadedPanels count])
                    {
                        BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                        if(!panelDownloaded)
                        {
                            [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj]; 
                        }

                    }
                    //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                    //NSLog(@"Panel#%i. didloadResource. downloaded=%d", currentPage, panelDownloaded);
                    
                    /*
                    NSFileManager* fileMgr = [NSFileManager defaultManager];
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString* imageName = [NSString stringWithFormat:@"thumbPhoto%i.png", resourcePanel.panelId];
                    NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                    BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                    if(!fileExists)
                    {
                        CGRect thumbFrame= CGRectMake(currentPage*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                        ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:resourcePanel];
                        resourcePanel.thumbnail=thumbnailView.snapshot;
                        NSLog(@"didloadResource.!thumMode. saving image =%@", imageName);
                        NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(resourcePanel.thumbnail)];
                        [data1 writeToFile:currentFile atomically:YES];
                        
                        if(currentPage<[downloadedPhotos count])
                        {
                            [downloadedPhotos replaceObjectAtIndex:currentPage withObject:yesObj];
                            
                        }
                    }//end if(!fileExists)
                    */
                    /*
                    CGRect thumbFrame= CGRectMake(currentPage*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:resourcePanel];
                    resourcePanel.thumbnail=thumbnailView.snapshot;
                    NSLog(@"Panel#%i thumbnail generated", currentPage);
                    
                    
                    if(currentPage<[downloadedPhotos count])
                    {
                        //BOOL photoDownloaded = [[downloadedPhotos objectAtIndex:thumbnailIndex] boolValue];
                        [downloadedPhotos replaceObjectAtIndex:currentPage withObject:yesObj];
                        
                    }
                     */
                    

                    // Scroll to the current page's thumbnail in thumbnail scrollview
                    [thumbnailScrollView scrollItemToVisible:(currentPage)];
                    //Display thumbnail images if there is only 1 panel
                    if([panels count]<=4)
                        [self alignPageInThumbnailScrollView];
                }//end if(!thumbMode)
                
                if(thumbMode)
                {
                    
                    //Declare a panel downloaded
                    if(thumbnailIndex<[downloadedPanels count])
                    {
                        BOOL panelDownloaded = [[downloadedPanels objectAtIndex:thumbnailIndex] boolValue];
                        if(!panelDownloaded)
                        {
                            [downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                        }
                    }

                    
                    //if(thumbnailIndex<[downloadedPanels count])
                    //    [downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                    
                    //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:thumbnailIndex] boolValue];
                    //NSLog(@"Panel#%i. downloaded=%d", thumbnailIndex, panelDownloaded);
                    /*
                    NSFileManager* fileMgr = [NSFileManager defaultManager];
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString* imageName = [NSString stringWithFormat:@"thumbPhoto%i.png", resourcePanel.panelId];
                    NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                    BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                    if(!fileExists)
                    {
                        CGRect thumbFrame= CGRectMake(thumbnailIndex*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                        ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:resourcePanel];
                        resourcePanel.thumbnail=thumbnailView.snapshot;
                        
                        NSLog(@"didloadResource.thumMode. saving image =%@", imageName);
                        NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(resourcePanel.thumbnail)];
                        [data1 writeToFile:currentFile atomically:YES];
                        
                        if(thumbnailIndex<[downloadedPhotos count])
                        {
                            [downloadedPhotos replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                            
                        }
                    }//end if(!fileExists)
                     */
                    
                    /*
                    CGRect thumbFrame= CGRectMake(thumbnailIndex*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:resourcePanel];
                    resourcePanel.thumbnail=thumbnailView.snapshot;
                    NSLog(@"Panel#%i thumbnail generated", thumbnailIndex);
                   
                    
                    if(thumbnailIndex<[downloadedPhotos count])
                    {
                        //BOOL photoDownloaded = [[downloadedPhotos objectAtIndex:thumbnailIndex] boolValue];
                        [downloadedPhotos replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                        
                    }
                    */
                    
                    //NSLog(@"didLoadResource. All placements downloaded.thumbnailIndex=%i, currentPage=%i, thumbPage=%i", thumbnailIndex, currentPage, thumbPage);
                    //if(thumbnailIndex<currentPage)
                    
                    //if(thumbPage+3<[self.panels count])
                    {
                        if(thumbnailIndex<(thumbPage+3))
                        {
                            thumbnailIndex++;
                            [self generateThumbails];
                        }
                        else if(thumbnailIndex==(thumbPage+3))
                        {
                            thumbMode = NO;
                            //NSLog(@"didloadPanel.thumbMode changed to=%d", thumbMode);
                            [self displayThumbails];
                            //[self alignPageInPanelScrollView];
                        }
                    }
                    /*
                    else{
                        thumbMode = NO;
                        NSLog(@"didloadPanel.thumbMode changed to=%d", thumbMode);
                        [self displayThumbails];
                    }
                     */
                        
                    
                /*
                    if(thumbnailIndex<(thumbPage+3))
                    {
                        thumbnailIndex++;
                        [self generateThumbails];
                    }
                    else if(thumbnailIndex==(thumbPage+3)){
                        
                        thumbMode = NO;
                        //NSLog(@"didloadResource.thumbMode changed to=%d", thumbMode);
                        [self displayThumbails];
                    }
                     */
                }//end if thumbMode
            }//end else if(placementCounter==(numPlacements-1))

        }//end if resourcePanel!=nil
 
    }//end if resource!=nil
}

#pragma mark ImageLoader functions.
-(void)imageDownloader:(ImageDownloader*)imageDownloader didLoadImage:(UIImage*)image{
    if (image){

        // ResourceImageView* resourceImage = [[ResourceImageView alloc] initWithFrame:CGRectMake(0.0,40,320,320) image:image];
        //[panelScrollView addSubview:resourceImage];
        //[self.view addSubview:resourceImage];
    }//end if image!=nil
}

-(void)imageDownloader:(ImageDownloader *)imageDownloader didFailWithError:(NSError*)error{
    NSLog(@"Error in image downloaded.");
}


@end

