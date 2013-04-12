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
#import "UIImage+Resize.h"
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

PhotoLoader *photoLoader;
PanelLoader *panelsLoader;
ResourceLoader *resourceLoader;

NSString* urlImageString;

int panelId;
int panelCounter;
int thumbnailIndex;

int numPlacements;
int placementCounter;


Panel* currentPanel;
Placement* currentPlacement;

NSArray *resourceList;
NSArray *placementList;
NSMutableArray* downloadedPanels;
NSMutableArray* downloadedPhotos;
NSArray* photos;

UIActivityIndicatorView* aIndicator0;
UIActivityIndicatorView* aIndicator1;
UIActivityIndicatorView* aIndicator2;
UIActivityIndicatorView* aIndicator3;

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
            //NSLog(@"singleTapcaptured. objectAtIndex");
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
    
    aIndicator0 = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aIndicator1 = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aIndicator2 = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    aIndicator3 = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
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
    }//end if

}

-(void)displayPageInPanelScrollView:(int)page
{
    if(page>=0 && page<[self.panels count])
    {
        BOOL displayed= NO;
        for(UIView* subView in panelScrollView.subviews)
        {
            if(subView.tag==page)
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
                [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                imageView.frame = CGRectMake(page*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                imageView.tag = page;	// tag our images for later use when we place them in serial fashion
                // add images to the panel scrollview
                [panelScrollView addSubview:imageView];
            }//end if panel!=nil
        }//end if(!displayed)
        else
        {
            //NSLog(@"displayPageInPanelScrollView.panel#%i already displayed.", page);
        }

    }//end if(page>=0 && page<[panels count])
}

-(void)alignPageInPanelScrollView
{
    thumbMode = NO;
    //NSLog(@"alignPageInPanelScrollView.numPanels=%i", numPanels);
    if([self.panels count]>0)
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
            //NSLog(@"alignPageInPhotoTableView. objectAtIndex:currentPage, currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
            currentPanel = [self.panels objectAtIndex:(currentPage)];
            //NSLog(@"alignPageInPhotoTableView.page=%i,currentPage=%i, panelId=%i", page, currentPage, currentPanel.panelId);
            if(currentPanel!=nil)
            {
                BOOL displayed= NO;
                for(UIView* subView in panelScrollView.subviews)
                {
                    if(subView.tag==currentPage)
                    {
                        displayed=YES;
                        break;
                    }//end if
                }//end for
                
                if(!displayed)
                {
                    UIImageView *imageView = [[UIImageView alloc] init];
                    [imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                    imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                    imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion
                    
                    //[activityIndicator stopAnimating];
                    // add images to the panel scrollview
                    [panelScrollView addSubview:imageView];
                }//end if(!displayed)
                

                [activityIndicator stopAnimating];
                
                //NSLog(@"alignPageInPhotoTableView. downloadedPanels objectAtIndex:currentPage.currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
                //Check if the panel alongwith placements and annotations have already been downloaded
                BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                if(!panelDownloaded)
                {
                    //NSLog(@"alignPageInPanelScrollView. Panel#%i download called.", currentPage);
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
                        if(subView.tag!=currentPage && subView.tag!=currentPage-1 && subView.tag!=currentPage+1)
                           //&& subView.tag!=currentPage-2 && subView.tag!=currentPage+2)
                        //if(subView.tag!=currentPage)
                        {
                            [subView removeFromSuperview];
                        }
                    }//end for
                    
                }//end if([panels count]>3)

            }//if currentPanel!=nil

            // Scroll to the current page's thumbnail in thumbnail scrollview
            [thumbnailScrollView scrollItemToVisible:(currentPage)];
            //[self alignPageInThumbnailScrollView];

        }//end if currentPage>=0 && currentPage<[self.panels count]
        
    }//end if numPanels>0
}

-(void)alignPageInThumbnailScrollView
{
    //NSLog(@"alignPageInThumbnailScrollView.numPanels=%i", numPanels);
    if(numPanels>0)
    {
        //NSLog(@"alignPage. numPanels= %i", numPanels);
        CGFloat pos = (CGFloat)self.thumbnailScrollView.contentOffset.x / thumbnailWidth;
        int page = round(ceilf(pos));
        thumbPage = page;
        
        //NSLog(@"alignPageInThumbnailScrollView.thumbPage=%i and currentPage=%i", thumbPage, currentPage);
        
        //Add new panels to thumbnailscrollviews
        if(page>=0 && page<[self.panels count])
        {
            thumbnailIndex = thumbPage;
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

    for(int index=thumbPage; index<thumbPage+4; index++)
    {
        if(index<[self.panels count])
        {
            /*
            UIActivityIndicatorView* aIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            aIndicator.frame = CGRectMake((index-thumbPage)*thumbnailWidth, thumbnailScrollYOrigin, thumbnailWidth, thumbnailScrollObjHeight);
            aIndicator.center = CGPointMake(aIndicator.frame.origin.x+(thumbnailWidth/2), thumbnailScrollYOrigin+(thumbnailScrollObjHeight/2));
            [aIndicator startAnimating];
            [self.view addSubview:aIndicator];
            */
            /*
            BOOL displayed= NO;

            for(UIView* subView in thumbnailScrollView.subviews)
            {
                if(subView.tag==index)
                {
                    displayed=YES;
                    [subView removeFromSuperview];
                    break;
                }//end if
            }//end for
            */
            //NSLog(@"displayThumbails. self.panels objectAtIndex:currentPage.currentPage=%i, index=%i, [self.panels count]=%i", currentPage, index, [self.panels count]);
            Panel* thumbnailPanel = [self.panels objectAtIndex:index];
            //NSLog(@"displayThumbnails. PanelIndex=%i", index);
            if(thumbnailPanel!=nil)
            {
                //NSData *imgData = UIImagePNGRepresentation(thumbnailPanel.thumbnail);
                //NSLog(@"Size of Image%i (bytes):%d",index, [imgData length]);
                //if([imgData length]==0)
                {
                    CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                    thumbnailPanel.thumbnail=thumbnailView.snapshot;
                    //NSLog(@"thumbnail#%i displayed=%d",index, thumbnailPanel.displayed);
                }

                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);
                [imageView setImage:thumbnailPanel.thumbnail];
                imageView.tag = index;
                [thumbnailScrollView addSubview:imageView];

            }//end if(thumbnailPanel!=nil)
            
        }//end if(index<[self.panels count])
    }//end for
    
   
    //NSLog(@"thumbPage=%i", thumbPage);
    if(thumbPage<=currentPage)
    {
        for(int page=thumbPage-1; page>thumbPage-5; page--)
        {
            [self displayPageInThumbnailScrollView:page];
        }
        
        for(int page=thumbPage+5; page<thumbPage+9; page++)
        {
            [self displayPageInThumbnailScrollView:page];
        }
        
    }
    

    if([self.panels count]>4)
    {
        for(UIView* subView in thumbnailScrollView.subviews)
        {
            if(subView.tag>thumbPage+8 || subView.tag<thumbPage-4)
            {
                [subView removeFromSuperview];
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
            //NSLog(@"displayPageInPanelScrollView.page=%i,currentPage=%i, panelId=%i", page, currentPage, panel.panelId);
            if(panel!=nil)
            {
                UIImageView *imageView = [[UIImageView alloc] init];
                [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
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


-(UIImage*) imageWithView:(UIView *)view
{
    NSLog(@"imageWithView");
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
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
        //[thumbnailScrollView scrollItemToVisible:(currentPage)];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        singleTap.cancelsTouchesInView = NO;
        [thumbnailScrollView addGestureRecognizer:singleTap];
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

-(void)loadAnnotations:(Panel*)panel
{
    if (panel != nil)
    {
        //currentPanel = panel;
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
        //currentPanel = panel;
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


#pragma rendering subviews into an image
- (UIImage*)imageFromView:(UIView*)view
{
    /*
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [view bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context
    CGContextSaveGState(context);
    // Center the context around the view's anchor point
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    // Apply the view's transform about the anchor point
    CGContextConcatCTM(context, [view transform]);
    // Offset by the portion of the bounds left of and above the anchor point
    CGContextTranslateCTM(context, -[view bounds].size.width * [[view layer] anchorPoint].x,
                          -[view bounds].size.height * [[view layer] anchorPoint].y);
    
    // Render the layer hierarchy to the current context
    [[view layer] renderInContext:context];
    
    // Restore the context
    CGContextRestoreGState(context);

    
    // Retrieve the screenshot image
    UIImage *imageWhole = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageWhole;
          */
    
    // Retrieve the screenshot image
    UIImage *imageWhole = [[UIImage alloc] init];
    
    /*
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:MyURL]]];
    
    CGSize imageSize = CGSizeMake(thumbnailWidth, thumbnailHeight);
    CGRect imageRect = CGRectMake(0.0, 0.0, thumbnailWidth, thumbnailHeight);
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    */


    
    UIGraphicsEndImageContext();
    
    return imageWhole;
    
}

#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"PanelViewController.Panel failed to load.");
    
}


-(void)PanelLoader:(PanelLoader *)loader didLoadPanels:(NSArray*)panelsLocal{

    panels= panelsLocal;
    numPanels = [panelsLocal count];
    
    //NSLog(@"numPanels=%i", numPanels);
    //[photoLoader submitRequestGetPhotosForGroup:@"8fc8a0ed74ea82888c7a37b0f62a105b83d07a12"];
    
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



-(void)PanelLoader:(PanelLoader*)loader didLoadPanel:(Panel*)panel{
    
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
            for(Annotation* annotation in panel.annotations)
            {
                //NSLog(@"annotation=%@", annotation.text);
                CGRect xywh = CGRectMake(annotation.xOffset,
                                         annotation.yOffset,0,0);
                
                NSString* text = annotation.text;
                int styleId = annotation.bubbleStyle;
         
                if(!thumbMode)
                {
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
        }//end if
        
        
        if(panel.placements!=nil)
        {
            panelInArray.placements = panel.placements;
            panel.resources = [[NSMutableArray alloc] init];
            panelInArray.resources = panel.resources;
            
            numPlacements = [panel.placements count];
            //NSLog(@"numPlacements=%i", numPlacements);
            placementCounter = 0;
            if(numPlacements > 0)
            {
                //NSLog(@"placements loaded.");
                //NSLog(@"didLoadPanel. self.panels objectAtIndex:currentPage.currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
                if(placementCounter<[panel.placements count])
                {
                    int resourceId = [[panel.placements objectAtIndex:placementCounter] resourceId];
                    [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                }
            }//end if
            else{
                //Declare a panel downloaded
                NSNumber* yesObj = [NSNumber numberWithBool:YES];
                if(!thumbMode)
                {
                    if(currentPage<[downloadedPanels count])
                        [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                }
               if(thumbMode)
                {
                    if(thumbnailIndex<[downloadedPanels count])
                        [downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                    //[downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                    CGRect thumbFrame= CGRectMake(thumbnailIndex*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:panelInArray];
                    panelInArray.thumbnail=thumbnailView.snapshot;
                    
                    if(thumbnailIndex<currentPage)
                    {
                        thumbnailIndex++;
                        [self generateThumbails];
                    }

                    /*
                     
                    if(thumbnailIndex<currentPage)
                    {
                        thumbnailIndex++;
                        [self generateThumbails];
                    }
                    else{
                        thumbMode = NO;
                        [self displayThumbails];
                    }
                     */
                }//end if thumbMode
            }
        }//end if
        else{
            //Declare a panel downloaded
            NSNumber* yesObj = [NSNumber numberWithBool:YES];
            if(!thumbMode)
            {
                if(currentPage<[downloadedPanels count])
                    [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                
            }
            if(thumbMode)
            {
                if(thumbnailIndex<[downloadedPanels count])
                    [downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                CGRect thumbFrame= CGRectMake(thumbnailIndex*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:panelInArray];
                panelInArray.thumbnail=thumbnailView.snapshot;
                
                if(thumbnailIndex<currentPage)
                {
                    thumbnailIndex++;
                    [self generateThumbails];
                }
                else{
                    thumbMode = NO;
                    [self displayThumbails];
                }
            }//end if thumbMode
        }
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
            //NSLog(@"currentPanel.resources count=%i", [currentPanel.resources count]);
            
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
            else
            {
                //NSLog(@"all placements downloaded.");
                //Declaring a panel downloaded after all placements are downloaded
                NSNumber* yesObj = [NSNumber numberWithBool:YES];
                
                if(!thumbMode)
                {
                    if(currentPage<[downloadedPanels count])
                        [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                }
                
                if(thumbMode)
                {
                    if(thumbnailIndex<[downloadedPanels count])
                        [downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                    
                    CGRect thumbFrame= CGRectMake(thumbnailIndex*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:resourcePanel];
                    resourcePanel.thumbnail=thumbnailView.snapshot;
                    
                    if(thumbnailIndex<currentPage)
                    {
                        thumbnailIndex++;
                        [self generateThumbails];
                    }
                    else{
                        thumbMode = NO;
                        [self displayThumbails];
                    }
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

