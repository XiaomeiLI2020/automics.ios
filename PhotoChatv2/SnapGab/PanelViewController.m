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
#import "ResourceLoader.h"
#import "ResourceImageView.h"
#import "ImageDownloader.h"
#import "GUIConstant.h"
#import "Annotation.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>

@interface PanelViewController ()

@end

@implementation PanelViewController

@synthesize panelScrollView;
@synthesize thumbnailScrollView;


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

PanelLoader *panelsLoader;
ResourceLoader *resourceLoader;

NSString* urlImageString;

int panelId;
int panelCounter;

int numPlacements;
int placementCounter;


Panel* currentPanel;
Placement* currentPlacement;

NSArray *resourceList;
NSArray *placementList;
NSMutableArray* downloadedPanels;

- (void)updateScrollViews
{
    
    //NSLog(@"updateScrollViews.numPanels=%i", numPanels);
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

        
    }//end if(numPanels>0)
    
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
        if(currentPage>0 && currentPage<[self.panels count])
        {
            currentPanel = [self.panels objectAtIndex:(currentPage)];
        }
        
        
        //NSLog(@"singleTap. touchPoint.x = %f", (CGFloat)touchPoint.x);
        //NSLog(@"singleTap. page= %i and currentPage=%i", page, currentPage);
        
        
        //Remove bubbles and resources from the current view
        [self removeAllBubbles];
        [self removeAllResources];
        
        // Scroll to the most rcently added panel in panel scrollview
        [panelScrollView scrollItemToVisible:(currentPage)];

    }//end if
     
    /*
    //Add bubbles and resources to the new panel's view after scrolling
    //[panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
    if(currentPanel!=nil)
    {
        if(currentPanel.annotations==nil || currentPanel.placements==nil)
        {
            [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
        }
        
    }
     */

}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {


        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newImageNotification)
                                                     name:@"newImageNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newImageNotification)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

    }
    return self;
}

-(void) initiateDataSet
{
    //NSLog(@"initiateDataset");
    
    numPanels = 0;
    panelCounter = 0;
    
    numPlacements = 0;
    placementCounter = 0;
 
    
    panels = [[NSArray alloc] init];
    resourceList = [[NSArray alloc] init];
    placementList = [[NSArray alloc] init];
    downloadedPanels = [[NSMutableArray alloc] init];
    
    currentPanel = [[Panel alloc] init];
    
    panelsLoader = [[PanelLoader alloc] init];
    panelsLoader.delegate = self;
    
    resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate = self;
    
    _bubblesAdded = NO;
    _resourcesAdded = NO;
    initialized = NO;

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
    //NSLog(@"viewDidLoad");
    [self initiateDataSet];
    [self initiateScrollViews];
    
    
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
	activityIndicator.center = self.view.center;
	[self.view addSubview: activityIndicator];
    [activityIndicator startAnimating];
    
    [panelsLoader submitRequestGetPanelsForGroup:1];


}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"viewDidAppear");

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
    }

}

-(void)alignPageInPanelScrollView
{
    //NSLog(@"alignPageInPhotoTableView.numPanels=%i", numPanels);
    if(numPanels>0)
    {
        [activityIndicator startAnimating];
        
        //NSLog(@"alignPage. numPanels= %i", numPanels);
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        
        //if(page!=currentPage)
        {
            //NSLog(@"annotations & placements removed.");
            [self removeAllBubbles];
            [self removeAllResources];
        }
        
        //NSLog(@"alignPageInPhotoTableView.page=%i, and currentPage=%i", page, currentPage);
        currentPage = page;

        //NSLog(@"alignPageInPhotoTableView.currentPage=%i", currentPage);
        
        //Add new panel after scrolling
        if(currentPage>=0 && currentPage<[self.panels count])
        {
           //Load new panel after scrolling
            currentPanel = [self.panels objectAtIndex:(currentPage)];
            if(currentPanel!=nil)
            {
                UIImageView *imageView = [[UIImageView alloc] init];
                [imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);                
                imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion
    
                [activityIndicator stopAnimating];
                // add images to the panel scrollview
                [panelScrollView addSubview:imageView];
                
                //Check if the panel alongwith placements and annotations have already been downloaded
                BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                if(!panelDownloaded)
                {
                    //Download annotations and placements of the panel
                    [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
                }
                else
                {
                    //NSLog(@"annotations already downloaded are added.");
                    [self loadAnnotations:currentPanel];
                    //NSLog(@"placements already downloaded.");
                    [self loadPlacements:currentPanel];
                }//end else
                
                //Remove other panels to free up memory
                if([panels count]>3)
                {
                    for(UIView* subView in panelScrollView.subviews)
                    {
                        //if(subView.tag!=currentPage || subView.tag!=currentPage-1 || subView.tag!=currentPage+1)
                        if(subView.tag!=currentPage)
                        {
                            [subView removeFromSuperview];
                        }
                    }//end for
                    
                }//end if([panels count]>3)

            }//if currentPanel!=nil

            // Scroll to the current page's thumbnail in thumbnail scrollview
            [thumbnailScrollView scrollItemToVisible:(currentPage)];
            [self alignPageInThumbnailScrollView];
            //[self addPageToThumbnailScrollView:currentPage];
        }//end if currentPage>=0 && currentPage<[self.panels count]
        
    }//end if _numImages>0
}

-(void)alignPageInThumbnailScrollView
{
    //NSLog(@"alignPageInThumbnailScrollView.numPanels=%i", numPanels);
    if(numPanels>0)
    {
        //NSLog(@"alignPage. numPanels= %i", numPanels);
        CGFloat pos = (CGFloat)self.thumbnailScrollView.contentOffset.x / thumbnailWidth;
        int page = round(ceilf(pos));
    
        
        //NSLog(@"alignPageInThumbnailScrollView.page=%i", page);
        
        //Add new panels to thumbnailscrollviews
        if(page>=0 && page<[self.panels count])
        {
            for(int index=page; index<page+4; index++)
            {
                //Load new panel after scrolling
                if(index<[self.panels count])
                {
                    Panel* thumbnailPanel = [self.panels objectAtIndex:(index)];
                    if(thumbnailPanel!=nil)
                    {
                        //NSLog(@"panel downloaded.");
                        UIImageView *imageView = [[UIImageView alloc] init];
                        [imageView setImageWithURL:[NSURL URLWithString:thumbnailPanel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                        imageView.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailScrollObjHeight);
                        imageView.tag = index;
                        // add images to the thumbnail scrollview
                        [thumbnailScrollView addSubview:imageView];
                        
                        if(index==currentPage)
                        {
                            //NSLog(@"alignPageInThumbnailScrollView.index=%i, currentPage=%i", index, currentPage);
                            //imageView.backgroundColor = [UIColor clearColor];
                            imageView.layer.borderColor = [[UIColor blackColor] CGColor];
                            imageView.layer.borderWidth = 2.0;
                        }
                        
                    }//end if

                }//end if(index<[panels count]
            }//end for
            
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
            
        }//end if page>=0 && page<[self.panels count]
        
    }//end if _numImages>0
}

-(void)addPageToThumbnailScrollView:(int)page
{
    NSLog(@"addPageToThumbnailScrollView.page=%i", page);
    if([panels count]>0)
    {
       //Add bubbles and resources to a panel after scrolling
        if(page>=0 && page<[self.panels count])
        {
            //Load new panel after scrolling
            Panel* thumbnailPanel = [self.panels objectAtIndex:(page)];
            if(thumbnailPanel!=nil)
            {
                
                //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                //If panel not already downloaded, add it to the panelScrollView, and download placements and annotations
                //if(!panelDownloaded)
                {
                    //NSLog(@"panel downloaded.");
                    //Add to panelscrollview
                    UIImageView *imageView = [[UIImageView alloc] init];
                    [imageView setImageWithURL:[NSURL URLWithString:thumbnailPanel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                    imageView.frame = CGRectMake(page*thumbnailWidth, 0, thumbnailWidth, thumbnailScrollObjHeight);
                    imageView.tag = page;
                    
                    // add images to the thumbnail scrollview
                    [thumbnailScrollView addSubview:imageView];
                    
                    
                    /*
                    if([panels count]>4)
                    {
                        for(UIView* subView in thumbnailScrollView.subviews)
                        {
                            if(subView.tag!=currentPage || subView.tag!=currentPage+1 || subView.tag!=currentPage-1 ||
                               subView.tag!=currentPage+2 || subView.tag!=currentPage-2)
                            {
                                [subView removeFromSuperview];
                            }
                        }//end for
                        
                    }//end if([panels count]>3)
                    */
                }

            }//if currentPanel!=nil
            
            // Scroll to the current page's thumbnail in thumbnail scrollview
            //[thumbnailScrollView scrollItemToVisible:(currentPage)];
        }//end if currentPage>=0 && currentPage<[self.panels count]
        
    }//end if _numImages>0
    
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndScrollingAnimation");
    if(scrollView.tag==0)
        [self alignPageInPanelScrollView];
    if(scrollView.tag==1)
        [self alignPageInThumbnailScrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating");
    if(scrollView.tag==0)
        [self alignPageInPanelScrollView];
    if(scrollView.tag==1)
        [self alignPageInThumbnailScrollView];
}

-(void)newImageNotification
{
    //NSLog(@"newImageNotification.");
    [self removeAllBubbles];
    [self removeAllResources];
    [panelsLoader submitRequestGetPanelsForGroup:1];
    [self updateScrollViews];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
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
                        
                        //ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andURL:sbv.urlImageString andType:sbv.type andId:sbv.resourceId andScale:sbv.scale];
                        /*
                        NSLog(@"edited resource.frame=%@", NSStringFromCGRect(sbv.frame));
                        NSLog(@"edited resource.bounds%@", NSStringFromCGRect(sbv.bounds));
                        NSLog(@"edited resource.imageView.frame=%@", NSStringFromCGRect(sbv.imageView.frame));
                        NSLog(@"edited resource.imageView.bounds%@", NSStringFromCGRect(sbv.imageView.bounds));
                        */
                        
                        //CGRect transformedBounds = CGRectApplyAffineTransform(sbv.bounds, sbv.transform);
                        //CGRect transformedFrame = CGRectApplyAffineTransform(sbv.frame, CGAffineTransformMakeRotation(0.0));
                        //CGAffineTransform transform = CGAffineTransformMakeRotation(-sbv.angle);
                        //CGRect rawFrame = CGRectApplyAffineTransform(sbv.frame, transform);
                        //CGRect nextFrame = CGRectApplyAffineTransform(rawFrame, transform);
                        /*
                        CGAffineTransform transform = CGAffineTransformScale([[sender view] transform], newScale, newScale);
                        CGAffineTransform iTransform = CGAffineTransformInvert([[sender view] transform]);
                        CGRect rawFrame = CGRectApplyAffineTransform([[sender view] frame], iTransform);
                        CGRect nextFrame = CGRectApplyAffineTransform(rawFrame, transform);
                        */
                        //CGRect (CGAffineTransformMakeRotation(0.0));
                        //CGAffineTransformRotate(myImage.transform, 180.0)
                        //CGRect transformedFrame = CGAffineTransformRotate;
                        //NSLog(@"edited transformedFrame=%@", NSStringFromCGRect(rawFrame));
                        //NSLog(@"edited pre-rotation resource.bounds%@", NSStringFromCGRect(sbv.bounds));
                        
                        sbv.transform = CGAffineTransformMakeRotation(0.0);
                        //[sbv removeFromSuperview];

                        NSLog(@"edited pre-rotation resource.frame=%@", NSStringFromCGRect(sbv.frame));
                        //NSLog(@"edited pre-rotation resource.bounds%@", NSStringFromCGRect(sbv.bounds));
                        //CGRect originalRect = CGRectMake(sbv.originalOrigin.x, sbv.originalOrigin.y, sbv.bounds.size.width, sbv.bounds.size.height);
                        //ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:originalRect andResource:sbv.resource andScale:sbv.scale andAngle:sbv.angle];
                        
                        
                        ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andResource:sbv.resource andScale:sbv.scale andAngle:sbv.angle];
                        
                        sbv.transform = CGAffineTransformMakeRotation(sbv.angle);
                        //new_sbv.transform = CGAffineTransformMakeRotation(0.0);
                        NSLog(@"edited pre-rotation newresource.frame=%@", NSStringFromCGRect(new_sbv.frame));
                        NSLog(@"edited pre-rotation newresource.bounds%@", NSStringFromCGRect(new_sbv.bounds));
                        
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
    //NSLog(@"loadPanelsToScrollViews. self.panels.count=%i", [self.panels count]);
    if([panels count]>0)
    {
        panelScrollView.numItems = [panels count];
        [panelScrollView layoutItems];
        
        thumbnailScrollView.numItems = [panels count];
        [thumbnailScrollView layoutItems];
        
        
        //Scroll panelscrollview and thumbnailscrollview to the last item
        currentPage = [panels count]-1;
        [panelScrollView scrollItemToVisible:(currentPage)];
        [thumbnailScrollView scrollItemToVisible:(currentPage)];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        singleTap.cancelsTouchesInView = NO;
        [thumbnailScrollView addGestureRecognizer:singleTap];

        //int index= currentPage;
        for(int index=currentPage; index>=0; index--)
        {
            currentPanel= [panels objectAtIndex:index];
            if(currentPanel!=nil)
            {
                if(currentPanel.photo!=nil)
                {
                    //if(currentPanel.photo.photoId>0)
                    {
                        //urlImageString = currentPanel.photo.imageURL;
                        //NSLog(@"loadPanelsToScrollViews.panel.panelId=%i and imageurl=%@",currentPanel.panelId, urlImageString);
                      
                        //Download the latest panel and add to the panelscrollview
                        if(index==currentPage)
                        {
                            //Add to panelscrollview
                            UIImageView *imageView = [[UIImageView alloc] init];
                            [imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                            imageView.frame = CGRectMake(index*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                            imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion
                            
                            // add images to the panel scrollview
                            [panelScrollView addSubview:imageView];
                            
                            //Load annotations and placements of the panel
                            [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
                            
                            //NSNumber* yesObj = [NSNumber numberWithBool:YES];
                            //[downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                            
                            //break;
                        }
                        
                        
                        if([panels count]>4)
                        {
                            if(index==currentPage-3)
                                break;
                            
                        }
                        UIImageView *thumbnailView = [[UIImageView alloc] init];
                        __weak UIImageView* _thumbnailView = thumbnailView;
                        
                        //[thumbnailView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                        [thumbnailView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL]
                                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]
                                               success:^(UIImage *imageDownloaded) {
                                                   
                                                   /*
                                                   UIImage * resizedImage = [imageDownloaded resizedImage:CGSizeMake(thumbnailWidth, thumbnailWidth) interpolationQuality:kCGInterpolationLow];
                                                   */
                                                   _thumbnailView.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailScrollObjHeight);
                                                   _thumbnailView.tag = index;	// tag our images for later use when we place them in serial fashion
                                                   
                                                   _thumbnailView.image = imageDownloaded;
                                                   // add images to the thumbnail scrollview
                                                   [thumbnailScrollView addSubview:_thumbnailView];
                                                   
                                                   if(index==currentPage)
                                                   {
                                                       _thumbnailView.layer.borderColor = [[UIColor blackColor] CGColor];
                                                       _thumbnailView.layer.borderWidth = 2.0;
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
                         
                         
                        /*

                        thumbnailView.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailScrollObjHeight);
                        thumbnailView.tag = panelCounter;	// tag our images for later use when we place them in serial fashion
                        
                        // add images to the thumbnail scrollview
                        [thumbnailScrollView addSubview:thumbnailView];
                        */

                    }//end if(currentPanel.photo.photoId>0)
                    
                }//end if(currentPanel.photo!=nil)
                
            }//end if(currentPanel!=nil)
        }//end for
    }//end if [panels count]>0
}

-(NSArray*)arrayByReplacingObject:(NSArray*)array andObjectIndex:(int)index andNewObject:(Panel*)panel
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray replaceObjectAtIndex:index withObject:panel];
    //[newArray addObject:object];
    return [NSArray arrayWithArray:newArray];
}

-(void)loadAnnotations:(Panel*)panel
{
    if (panel != nil)
    {
        currentPanel = panel;
        panelId = panel.panelId;
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
        panelId = panel.panelId;
        
        if(panel.placements!=nil)
        {
            numPlacements = [panel.placements count];
            int placementCounter = 0;
            //for(Placement* placement in panel.placements)
            
            if(numPlacements > 0)
            {
                for(placementCounter=0; placementCounter<numPlacements; placementCounter++)
                {
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

-(void)loadPlacementsCache:(Panel*)panel
{
    if (panel != nil)
    {
        currentPanel = panel;
        panelId = panel.panelId;
        
        if(panel.placements!=nil)
        {
            numPlacements = [panel.placements count];
            placementCounter = 0;
            //for(Placement* placement in panel.placements)
            if(numPlacements > 0)
            {
                int resourceId = [[panel.placements objectAtIndex:placementCounter] resourceId];
                [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                
                
            }//end for
            
            _resourcesAdded = YES;
        }//end if
    }//end if panel!=null
}


#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"Panel failed to load.");
    
}


-(void)PanelLoader:(PanelLoader *)loader didLoadPanels:(NSArray*)panelsLocal{

    panels= panelsLocal;
    numPanels = [panelsLocal count];
    
    if(!initialized)
    {
        initialized = YES;
        [self loadPanelsToScrollViews];
        [activityIndicator stopAnimating];
        
    }
 
    //NSLog(@"didLoadPanels.numPanels=%i", numPanels);
    //initialzed array to boolean NO. No panel downloaded yet.
    for (int i=0; i<numPanels;i++)
    {
        NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
        [downloadedPanels addObject:panelDownloaded];
    }
    

 
}

-(void)PanelLoader:(PanelLoader*)loader didLoadPanel:(Panel *)panel{
    //NSLog(@"Panel downloaded.currentPage=%i", currentPage);
    
    if (panel != nil)
    {
        currentPanel = panel;
        panelId = panel.panelId;
        //panel.resources = [[NSMutableArray alloc] init];
        
        //Replace the panel in the panels array with the downloaded panel that contains annotations and placements
        panels = [self arrayByReplacingObject:panels andObjectIndex:currentPage andNewObject:currentPanel];
        
        //NSNumber* yesObj = [NSNumber numberWithBool:YES];
        //[downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
        
        //NSLog(@"Panel downloaded %i. currentPanel.annotations.count=%i", panel.panelId, [currentPanel.annotations count]);
        //NSLog(@"Panel downloaded %i. currentPanel.placements.count=%i", panel.panelId, [currentPanel.placements count]);
        
        if(panel.annotations!=nil)
        {
            //NSLog(@"annotations loaded.");
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
        }//end if
        
        
        if(panel.placements!=nil)
        {
            //panel.resources = [[NSMutableArray alloc] initWithArray:panel.placements];
            //panel.resources = [NSMutableArray arrayWithArray:panel.placements];
            panel.resources = [[NSMutableArray alloc] init];
            numPlacements = [panel.placements count];
            placementCounter = 0;
            
            
            if(numPlacements > 0)
            {
                //NSLog(@"placements loaded.");
                int resourceId = [[panel.placements objectAtIndex:placementCounter] resourceId];
                [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                
            }//end for
        }//end if
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
    //NSLog(@"Resource downloaded");
    if (resource != nil)
    {
        //Add resource to the panel object's resources array.
        [currentPanel.resources addObject:resource];
        //NSLog(@"currentPanel.resources count=%i", [currentPanel.resources count]);
        
        NSString* type = resource.type;
        float defaultScale = 1.0;
        float defaultAngle = 0.0;

        CGRect resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
        if([type isEqual:@"d"])
        {
            if(currentPanel.placements!=nil && [currentPanel.placements count]>placementCounter)
            {
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
        
        //ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andURL:resource.imageURL andType:resource.type andId:resource.resourceId andScale:defaultScale];
        
        ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andResource:resource andScale:defaultScale andAngle:defaultAngle];
        rv.userInteractionEnabled = NO;
        [self.view addSubview:rv];
        
        //Download other placements in the placements array
        if(placementCounter<(numPlacements-1))
        {
            placementCounter++;
            int resourceId = [[currentPanel.placements objectAtIndex:placementCounter] resourceId];
            //NSLog(@"resourceId #%i", resourceId);
            [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
        }
        else{
            //NSLog(@"all placements downloaded.");
            //Declaring a panel downloaded after all placements are downloaded
            NSNumber* yesObj = [NSNumber numberWithBool:YES];
            [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
        }

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

