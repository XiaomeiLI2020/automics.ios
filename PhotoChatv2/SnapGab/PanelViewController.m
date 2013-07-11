//
//  PanelViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 01/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "PanelEditViewController.h"
#import "PanelViewController.h"
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
@synthesize activityIndicator;

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

int thumbnailsCompleted;

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
}

/*
- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear.");
    [super viewWillAppear:animated];
}
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"PanelViewController.viewDidLoad");

    //[self initiateDataSet];
    //[self initiateScrollViews];
    

    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
	activityIndicator.center = self.view.center;
	[self.view addSubview: activityIndicator];
    [activityIndicator startAnimating];

    //[panelsLoader submitRequestGetPanelsForGroup];


}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"viewWillAppear");
    [super viewWillAppear:YES];
    
    for (UIView *subview in self.view.subviews)
    {
        if([subview isMemberOfClass:[SpeechBubbleView class]] || [subview isMemberOfClass:[ResourceView class]]
           || [subview isMemberOfClass:[MainScrollSelector class]])
        {
            [subview removeFromSuperview];
        }
    }
    
    [self initiateDataSet];
    [self initiateScrollViews];
    
    [panelsLoader submitRequestGetPanelsForGroup];

}


- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"viewDidAppear");
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
                
                NSFileManager* fileMgr = [NSFileManager defaultManager];
                //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                //NSString* imageName = [NSString stringWithFormat:@"%i.png", page];
                NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", panel.photo.photoId];
                NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                //NSLog(@"displayPageinPanelScrollView. Panel[%i].[%@] File exists=%d", panel.panelId, imageName, fileExists);
                if(!fileExists)
                {
                    
                    [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                              placeholderImage:nil
                                       success:^(UIImage *imageDownloaded) {
                                           //UIImageWriteToSavedPhotosAlbum(imageDownloaded, nil, nil, nil);

                                           //NSLog(@"displayPageinPanelScrollView.saving image=%@", imageName);
                                           NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                           [data1 writeToFile:currentFile atomically:YES];
                           
                                       }
                                       failure:^(NSError *error) {
                                           NSLog(@"displayPageinPanelScrollView.Failed to load image");
                                       }];
                }//end if(!fileExists)
                else if(fileExists)
                {
                    
                    //NSLog(@"displayPageinPanelScrollView. Loading image from file=%@", imageName);
                    //NSError* err;
                    //[fileMgr removeItemAtPath:currentFile error:&err];
                    [imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                    //[imageView setImage:[UIImage imageNamed:currentFile]];
                    //[imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
                }//end if(fileExists)
                

                //[imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
                [imageView setContentMode:UIViewContentModeScaleAspectFill];
                imageView.frame = CGRectMake(page*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                imageView.tag = page;	// tag our images for later use when we place them in serial fashion
                imageView.clipsToBounds= YES;
                // add images to the panel scrollview
                
                [panelScrollView addSubview:imageView];
            }//end if panel!=nil
        }//end if(!displayed)
        //else
        {
            //NSLog(@"displayPageInPanelScrollView.panel#%i already displayed.", page);
        }

    }//end if(page>=0 && page<[panels count])
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
        
        if(lastContentOffSet.x==panelScrollView.contentOffset.x)
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
                BOOL displayed= NO;
                //Check if the panel is already displayed in the panel scrollview
                for(UIView* subView in panelScrollView.subviews)
                {
                    if(subView.tag==currentPage && [subView isMemberOfClass:[UIImageView class]])
                    {
                        displayed=YES;
                        break;
                    }//end if
                }//end for
                
                //NSLog(@"alignPageInPanelScrollView.page=%i,currentPage=%i, panelId=%i, displayed=%d", page, currentPage, currentPanel.panelId, displayed);
                 //Check if the panel is not already displayed in the panel scrollview, display it
                if(!displayed)
                {
                    UIImageView *imageView = [[UIImageView alloc] init];
                    
               
                    NSFileManager* fileMgr = [NSFileManager defaultManager];
                    //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    //NSString* imageName = [NSString stringWithFormat:@"%i.png", currentPage];
                    NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", currentPanel.photo.photoId];
                    NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                    BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                    

                    //NSLog(@"alignPageinPanelScrollView. Panel[%i].[%@] File exists=%d", currentPanel.panelId, imageName, fileExists);

                    if(!fileExists)
                    {
                        
                        [imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL]
                                  placeholderImage:nil
                                           success:^(UIImage *imageDownloaded) {
                                               //UIImageWriteToSavedPhotosAlbum(imageDownloaded, nil, nil, nil);
                                              
                                               //NSLog(@"alignPageinPanelScrollView.saving image=%@", imageName);
                                               NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                               [data1 writeToFile:currentFile atomically:YES];
                                              
                                           }
                                           failure:^(NSError *error) {
                                               NSLog(@"alignPageinPanelScrollView.Failed to load image");
                                           }];
                    }//end if(!fileExists)
                    else if(fileExists)
                    {
                        //NSLog(@"alignPageinPanelScrollView. Loading image from file=%@", imageName);
                        //NSError* err;
                        //[fileMgr removeItemAtPath:currentFile error:&err];
                        [imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                        //[imageView setImage:[UIImage imageNamed:currentFile]];
                        //[imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:nil];
                    }//end if(fileExists)
                    
                    
                    //[imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:nil];
                    imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                    imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion
                    
                    [imageView setContentMode:UIViewContentModeScaleAspectFill];
                    imageView.clipsToBounds= YES;
                    //[activityIndicator stopAnimating];
                    // add images to the panel scrollview
                    [panelScrollView addSubview:imageView];
                    
                }//end if(!displayed)
                else{
                    //NSLog(@"alignPageInPanelScrollView.panel#%i, displayed=%d", currentPage, displayed);
                }
                

                [activityIndicator stopAnimating];
                //[activityIndicator removeFromSuperview];
                thumbMode = NO;
                
                //NSLog(@"alignPageInPhotoTableView. downloadedPanels objectAtIndex:currentPage.currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
                //Check if the panel alongwith placements and annotations have already been downloaded
                BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                //NSLog(@"alignPageInPanelScrollView.thumbMode=%d. Panel#%i downloaded=%d.", thumbMode, currentPage, panelDownloaded);
                if(!panelDownloaded)
                //if(currentPanel.placements==nil&&currentPanel.annotations==nil)
                {
                    //NSLog(@"alignPageInPanelScrollView. Panel#%i download called. thumbMode=%d", currentPage, thumbMode);
                    //Download annotations and placements of the panel
                    [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
                }
                else
                {
                    //NSLog(@"annotations already downloaded are added.");
                    [self loadAnnotations:currentPanel];
                    //NSLog(@"placements already downloaded.");
                    [self loadPlacements:currentPanel];
                    
                    [thumbnailScrollView scrollItemToVisible:(currentPage)];
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

            
            // Scroll to the current page's thumbnail in thumbnail scrollview
            //[thumbnailScrollView scrollItemToVisible:(currentPage)];
            //NSLog(@"alignPageInPanelScrollView.thumbnailScrollView scrollItemToVisible:(currentPage)");
            //if([self.panels count]<=4)
            //    [self alignPageInThumbnailScrollView];
            
            

        }//end if currentPage>=0 && currentPage<[self.panels count]
        
    }//end if numPanels>0
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
        BOOL panelDownloaded = [[downloadedPanels objectAtIndex:thumbnailIndex] boolValue];
        
        if(!panelDownloaded)
        {
            //NSLog(@"generateThumbnails. Panel%i download called.", thumbnailIndex);
            //Download annotations and placements of the panel
            [panelsLoader submitRequestGetPanelWithId:thumbnailPanel.panelId];
        }
        else
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
                
                /*
                NSFileManager* fileMgr = [NSFileManager defaultManager];
                NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString* imageName = [NSString stringWithFormat:@"%i.png", index];
                NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                NSString *pngFilePath;
                if (fileExists == NO){
                    NSLog(@"File does not exist");
                    
                    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    
                    // If you go to the folder below, you will find those pictures
                    NSLog(@"%@",docDir);
                    
                    NSLog(@"saving png");
                    CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                    pngFilePath = [NSString stringWithFormat:@"%@/%i.png",docDir, index];
                    NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(thumbnailView.snapshot)];
                    //[data1 writeToFile:pngFilePath atomically:YES];
                    [data1 writeToFile:currentFile atomically:YES];
                } else {
                    NSLog(@"File exists.currentFile=%@, pngFilePath=%@", currentFile, pngFilePath);
                }
                */
                
                //NSData *imgData = UIImagePNGRepresentation(thumbnailPanel.thumbnail);
                //NSLog(@"Size of Image%i (bytes):%d",index, [imgData length]);
                
                //if([imgData length]==0)
                
                BOOL photoDownloaded = [[downloadedPhotos objectAtIndex:index] boolValue];
                //NSLog(@"displayThumbnails.downloadedPhotos objectAtIndex:index[%i]=%d", index, photoDownloaded);
                if(!photoDownloaded)
                {
                     
                    CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                    thumbnailPanel.thumbnail=thumbnailView.snapshot;
                    //NSLog(@"thumbnail#%i generated",index);

                    //NSData *imgData = UIImagePNGRepresentation(thumbnailPanel.thumbnail);
                    //NSLog(@"Size of ThumbnailImage%i (bytes):%d",index, [imgData length]);
                    
                    //NSData *imgData1 = UIImagePNGRepresentation(thumbnailPanel.photo.imageURL);
                    //NSLog(@"Size of ThumbnailImage%i (bytes):%d",index, [imgData length]);

                    NSNumber* yesObj = [NSNumber numberWithBool:YES];
                    if(index<[downloadedPhotos count])
                        [downloadedPhotos replaceObjectAtIndex:index withObject:yesObj];
                    //NSLog(@"displayThumbnails.downloadedPhotos objectAtIndex:index[%i] changed to %d, thumbMode=%d", index, photoDownloaded, thumbMode);
                    
                }


                /*
                NSError *err;
                NSFileManager* fileMgr = [NSFileManager defaultManager];
                NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString* imageName = [NSString stringWithFormat:@"%i.png", index];
                NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                if (fileExists == NO){
                    NSLog(@"File does not exist");
                    CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                    thumbnailPanel.thumbnail=thumbnailView.snapshot;
                    
                    NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(thumbnailView.snapshot)];
                    //[data1 writeToFile:pngFilePath atomically:YES];
                    [data1 writeToFile:currentFile atomically:YES];
                }//end if
                else{
                    NSLog(@"File exists");
                    //[fileMgr removeItemAtPath:currentFile error:&err];
                }
                */
                if(index==thumbPage+3)
                {
                    //thumbnailsCompleted++;
                    //NSLog(@"ALL THUMBNAILS LOADED.thumbnailsCompleted=%i", thumbnailsCompleted);
                    //if(thumbnailsCompleted==4)
                    {
                        /*
                        for(int i=thumbPage; i<thumbPage+4; i++)
                        {
                            NSNumber* yesObj = [NSNumber numberWithBool:YES];
                            [downloadedPhotos replaceObjectAtIndex:i withObject:yesObj];
                            BOOL photoDownloaded = [[downloadedPhotos objectAtIndex:i] boolValue];
                            NSLog(@"displayThumbnails.downloadedPhotos objectAtIndex:index[%i] changed to %d, thumbMode=%d", i, photoDownloaded, thumbMode);
                        }
                         */
                        //thumbnailsCompleted =0;
                         
                    }
                }
                
                /*
                //UIImage *prodImg = [[UIImage alloc] initWithContentsOfFile:currentFile];
                UIImage *prodImg1 = [UIImage imageWithContentsOfFile:currentFile];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:prodImg1];
                imageView.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);

                //[imageView setImage:prodImg];
                //imageView.image = prodImg;
                imageView.tag = index;
                [thumbnailScrollView addSubview:imageView];
               */
                
                
                
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);
                //[imageView setImage:thumbnailPanel.thumbnail];
                photoDownloaded = [[downloadedPhotos objectAtIndex:index] boolValue];
                if(!photoDownloaded)
                {
                    //NSLog(@"Panel without resources shown. index=%i", index);
                    [imageView setImageWithURL:[NSURL URLWithString:thumbnailPanel.photo.imageURL] placeholderImage:nil];

                    /*
                    NSFileManager* fileMgr = [NSFileManager defaultManager];
                    //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    //NSString* imageName = [NSString stringWithFormat:@"%i.png", currentPage];
                    NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", thumbnailPanel.photo.photoId];
                    NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                    BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                    
                    UIImageView *imageView = [[UIImageView alloc] init];
                    //NSLog(@"alignPageinPanelScrollView. Panel[%i].[%@] File exists=%d", currentPanel.panelId, imageName, fileExists);
                    if(!fileExists)
                    {
                        
                        [imageView setImageWithURL:[NSURL URLWithString:thumbnailPanel.photo.imageURL]
                                  placeholderImage:nil
                                           success:^(UIImage *imageDownloaded) {
                                               //UIImageWriteToSavedPhotosAlbum(imageDownloaded, nil, nil, nil);
                                               
                                               //NSLog(@"alignPageinPanelScrollView.saving image=%@", imageName);
                                               NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                               [data1 writeToFile:currentFile atomically:YES];
                                               
                                           }
                                           failure:^(NSError *error) {
                                               NSLog(@"displayThumbnails.Failed to load image");
                                           }];
                    }//end if(!fileExists)
                    else if(fileExists)
                    {
                        //NSLog(@"displayThumbnails. Loading image from file=%@", imageName);
                        //NSError* err;
                        //[fileMgr removeItemAtPath:currentFile error:&err];
                        [imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                        //[imageView setImageWithURL:[NSURL URLWithString:thumbnailPanel.photo.imageURL] placeholderImage:nil];
                    }//end if(fileExists)
                  */
                }//end if(!photoDownloaded)
                else
                {
                    //NSLog(@"displayThumbnails.Thumbnail shown. index=%i", index);
                    [imageView setImage:thumbnailPanel.thumbnail];
                }
                /*
                NSFileManager* fileMgr = [NSFileManager defaultManager];
                //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                //NSString* imageName = [NSString stringWithFormat:@"%i.png", page];
                NSString* imageName = [NSString stringWithFormat:@"thumbPhoto%i.png", thumbnailPanel.panelId];
                NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                //NSLog(@"displayPageinPanelScrollView. Panel[%i].[%@] File exists=%d", panel.panelId, imageName, fileExists);
                if(!fileExists)
                {
                    CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                    thumbnailPanel.thumbnail=thumbnailView.snapshot;
                    
                    NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(thumbnailView.snapshot)];
                    [data1 writeToFile:currentFile atomically:YES];
                    
                    [imageView setImage:thumbnailPanel.thumbnail];
                    //NSNumber* yesObj = [NSNumber numberWithBool:YES];
                    //if(index<[downloadedPhotos count])
                    //    [downloadedPhotos replaceObjectAtIndex:index withObject:yesObj];
                    
                }
                else if (fileExists)
                {
                   [imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                }
                 */
                
                imageView.tag = index;
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

}

-(void)displayPageInThumbnailScrollView:(int)page
{
    if(page>=0 && page<[self.panels count])
    {
        BOOL displayed= NO;
        for(UIView* subView in thumbnailScrollView.subviews)
        {
            if(subView.tag==page)
            {
                displayed=YES;
                break;
            }//end if
        }//end for
        
        
        //NSLog(@"displayPageInThumbnailScrollView.panel#%i displayed=%d.", page, displayed);
        if(!displayed)
        {
            //NSLog(@"displayPageInThumbnailScrollView.objectAtIndex:page");
            Panel* panel = [self.panels objectAtIndex:page];
            BOOL photoDownloaded = [[downloadedPhotos objectAtIndex:page] boolValue];
            //NSLog(@"displayPageInPanelScrollView.page=%i,currentPage=%i, panelId=%i", page, currentPage, panel.panelId);
            

            if(panel!=nil)
            {
                /*
                UIImageView *imageView;
                NSError *err;
                NSFileManager* fileMgr = [NSFileManager defaultManager];
                NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString* imageName = [NSString stringWithFormat:@"%i.png", page];
                NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                if (fileExists == NO){
                    imageView = [[UIImageView alloc] init];
                    NSLog(@"File does not exist");
                    [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
                }//end if
                else{
                    NSLog(@"File exists");
                    //[fileMgr removeItemAtPath:currentFile error:&err];
                    UIImage *prodImg1 = [UIImage imageWithContentsOfFile:currentFile];
                    imageView = [[UIImageView alloc] initWithImage:prodImg1];
                }
                

                imageView.frame = CGRectMake(page*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);
                imageView.tag = page;	// tag our images for later use when we place them in serial fashion
                // add images to the panel scrollview
                [thumbnailScrollView addSubview:imageView];
                 */
                
                //[imageView setImage:thumbnailPanel.thumbnail];
                /*
                 if(!photoDownloaded)
                 {
                 //[imageView setImageWithURL:[NSURL URLWithString:thumbnailPanel.photo.imageURL] placeholderImage:nil];
                 
                 NSFileManager* fileMgr = [NSFileManager defaultManager];
                 //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                 NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                 //NSString* imageName = [NSString stringWithFormat:@"%i.png", currentPage];
                 NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", panel.photo.photoId];
                 NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                 BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                 
                 UIImageView *imageView = [[UIImageView alloc] init];
                 //NSLog(@"alignPageinPanelScrollView. Panel[%i].[%@] File exists=%d", currentPanel.panelId, imageName, fileExists);
                 if(!fileExists)
                 {
                 
                 [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                 placeholderImage:nil
                 success:^(UIImage *imageDownloaded) {
                 //UIImageWriteToSavedPhotosAlbum(imageDownloaded, nil, nil, nil);
                 
                 //NSLog(@"alignPageinPanelScrollView.saving image=%@", imageName);
                 NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                 [data1 writeToFile:currentFile atomically:YES];
                 
                 }
                 failure:^(NSError *error) {
                 NSLog(@"displayPageInThumbnailScrollView.Failed to load image");
                 }];
                 }//end if(!fileExists)
                 else if(fileExists)
                 {
                 //NSLog(@"alignPageinPanelScrollView. Loading image from file=%@", imageName);
                 //NSError* err;
                 //[fileMgr removeItemAtPath:currentFile error:&err];
                 [imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                 //[imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:nil];
                 }//end if(fileExists)
                 }
                 */

                UIImageView *imageView = [[UIImageView alloc] init];
                if(!photoDownloaded)
                {
                    [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
                    /*
                    NSFileManager* fileMgr = [NSFileManager defaultManager];
                    //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    //NSString* imageName = [NSString stringWithFormat:@"%i.png", currentPage];
                    NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", panel.photo.photoId];
                    NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                    BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                    
                    //NSLog(@"alignPageinPanelScrollView. Panel[%i].[%@] File exists=%d", currentPanel.panelId, imageName, fileExists);
                    if(!fileExists)
                    {
                        
                        [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                                  placeholderImage:nil
                                           success:^(UIImage *imageDownloaded) {
                                               //UIImageWriteToSavedPhotosAlbum(imageDownloaded, nil, nil, nil);
                                               
                                               //NSLog(@"alignPageinPanelScrollView.saving image=%@", imageName);
                                               NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                               [data1 writeToFile:currentFile atomically:YES];
                                               
                                           }
                                           failure:^(NSError *error) {
                                               NSLog(@"displayThumbnails.Failed to load image");
                                           }];
                    }//end if(!fileExists)
                    else if(fileExists)
                    {
                        //NSLog(@"displayThumbnails. Loading image from file=%@", imageName);
                        //NSError* err;
                        //[fileMgr removeItemAtPath:currentFile error:&err];
                        [imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                        //[imageView setImageWithURL:[NSURL URLWithString:thumbnailPanel.photo.imageURL] placeholderImage:nil];
                    }//end if(fileExists)
                     */
                }
                else
                {
                    [imageView setImage:panel.thumbnail];
                }
                /*
                NSFileManager* fileMgr = [NSFileManager defaultManager];
                //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                //NSString* imageName = [NSString stringWithFormat:@"%i.png", page];
                NSString* imageName = [NSString stringWithFormat:@"thumbPhoto%i.png", panel.panelId];
                NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
                BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
                //NSLog(@"displayPageinPanelScrollView. Panel[%i].[%@] File exists=%d", panel.panelId, imageName, fileExists);
                if(!fileExists)
                {
                    [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
                    
                }
                else if (fileExists)
                {
                    [imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                }
                */

                 
                 
                imageView.frame = CGRectMake(page*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);
                imageView.tag = page;	// tag our images for later use when we place them in serial fashion
                // add images to the panel scrollview
                [thumbnailScrollView addSubview:imageView];
                 
            }//end if panel!=nil
        }//end if(!displayed)
        //else
        {
            //NSLog(@"displayPageInPanelScrollView.panel#%i already displayed.", page);
        }
        
    }//end if(page>=0 && page<[panels count])
}

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
        NSLog(@"notification: %@", message);
        //[[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else{
        NSLog(@"Nil data. New panel uploaded.");
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
        [panelScrollView scrollItemToVisible:(currentPage)];
        //[thumbnailScrollView scrollItemToVisible:(currentPage)];
        
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
    //NSLog(@"didLoadPanels.numPanels=%i", numPanels);
    if(numPanels==0)
        [activityIndicator stopAnimating];
    
    //if(numPanels>0)
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

-(void)PanelLoader:(PanelLoader *)loader didLoadRefreshedPanels:(NSArray*)panelsLocal{
    
    /*
    NSMutableArray* arrayCat(NSArray *a, NSArray *b)
    {
        NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[a count] + [b count]];
        [ret addObjectsFromArray:a];
        [ret addObjectsFromArray:b];
        return ret;
    }
     */

    //NSLog(@"PanelViewController.didLoadRefreshedPanels. currentPanels=%i, [panelsLocal count]=%i", [panels count], [panelsLocal count]);
    //NSMutableArray *newPanels = [NSMutableArray arrayWithCapacity:[panels count] + [panelsLocal count]];
    initialized = NO;
    NSMutableArray *newPanels = [[NSMutableArray alloc] initWithArray:panels];
    [newPanels addObjectsFromArray:panelsLocal];
    
    panels = newPanels;
    numPanels = [newPanels count];
    
    
    for(UIView* subView in panelScrollView.subviews)
    {
        //if(subView.tag==page && [subView isMemberOfClass:[UIImageView class]])
        if([subView isMemberOfClass:[UIImageView class]])
        {
            [subView removeFromSuperview];
        }//end if
    }//end for

    for (int i=0; i<[panelsLocal count];i++)
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

    /*
    panels= panelsLocal;
    numPanels = [panelsLocal count];
    
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
     */
}



//-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel forObject:(id)obj
-(void)PanelLoader:(PanelLoader*)loader didLoadPanel:(Panel*)panel
{
    //NSLog(@"didLoadPanel. thumbmode=%d", thumbMode);
    //NSLog(@"PanelViewController. didLoadPanel.numPanels=%i, thumbmode=%d", numPanels, thumbMode);
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

        //NSLog(@"Panel downloaded.currentPage=%i, and panelIndex=%i", currentPage, index);
        
        panelId = panel.panelId;
        //NSLog(@"didloadPanel. self.panels objectAtIndex:currentPage.currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
        Panel* panelInArray = [self.panels objectAtIndex:index];
 
        //Replace the panel in the panels array with the downloaded panel that contains annotations and placements
        //panels = [self arrayByReplacingObject:panels andObjectIndex:currentPage andNewObject:currentPanel];
        //NSNumber* yesObj = [NSNumber numberWithBool:YES];
        //[downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
        //NSLog(@"Panel downloaded %i. currentPanel.annotations.count=%i", panel.panelId, [currentPanel.annotations count]);
        //NSLog(@"Panel downloaded %i. currentPanel.placements.count=%i", panel.panelId, [currentPanel.placements count]);
        

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
                if(!thumbMode)
                {
                    //Declate a panel has been downloaded
                    if(currentPage<[downloadedPanels count])
                        [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                    //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                    //NSLog(@"didLoadPanel.thumbMode=%d, downloadedPanels[%i] =%d. thumbnailScrollView scrollItemToVisible:(currentPage)", thumbMode, currentPage, panelDownloaded);
                    
                    //[self alignPageInPanelScrollView];
                    // Scroll to the current page's thumbnail in thumbnail scrollview, after the panel downloaded
                    [thumbnailScrollView scrollItemToVisible:(currentPage)];
                    
                    if([panels count]<=4)
                        [self alignPageInThumbnailScrollView];
                    
                }//end if(!thumbMode)
                if(thumbMode)
                {
                    if(thumbnailIndex<[downloadedPanels count])
                        [downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                    //[downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                    
                    
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
    }//end if panel!=nil
 
}


#pragma mark ResourceLoader functions.
-(void)ResourceLoader:(ResourceLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"resource failed to load.");
    
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResources:(NSArray*)resources{
    //NSLog(@"resources loaded.");
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResource:(Resource*)resource
{
    //NSLog(@"Resource downloaded.thumbMode=%d", thumbMode);
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
                if(!thumbMode)
                {
                    //Declare a panel downloaded
                    if(currentPage<[downloadedPanels count])
                        [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                    
                    //[panelScrollView scrollItemToVisible:(currentPage)];
                    //[self alignPageInPanelScrollView];
                    //NSLog(@"didLoadResources.thumbnailScrollView scrollItemToVisible:(currentPage)");
                    // Scroll to the current page's thumbnail in thumbnail scrollview
                    [thumbnailScrollView scrollItemToVisible:(currentPage)];
                    
                    //Display thumbnail images if there is only 1 panel
                    if([panels count]<=4)
                        [self alignPageInThumbnailScrollView];
                }
                
                if(thumbMode)
                {
                    if(thumbnailIndex<[downloadedPanels count])
                        [downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                    /*
                    CGRect thumbFrame= CGRectMake(thumbnailIndex*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:resourcePanel];
                    resourcePanel.thumbnail=thumbnailView.snapshot;
                   */
                    /*
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

