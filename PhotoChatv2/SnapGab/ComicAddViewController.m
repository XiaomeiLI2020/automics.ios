//
//  ComicAddViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 13/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ComicAddViewController.h"
#import "ComicPosterViewController.h"
#import "UIImageView+WebCache.h"
#import "SpeechBubbleView.h"
#import "ResourceView.h"
#import "Comic.h"
#import "GUIConstant.h"
#import "ResourceImageView.h"
#import "ImageDownloader.h"
#import "Annotation.h"
#import "ThumbnailView.h"
#import <QuartzCore/QuartzCore.h>

@interface ComicAddViewController ()

@end

@implementation ComicAddViewController


@synthesize thumbnailScrollView;
@synthesize panelScrollView;
@synthesize _groupName;
@synthesize currentPage;
@synthesize postButton;
@synthesize thumbPage;

@synthesize panels;
@synthesize panelArray;
@synthesize panelCounter;
@synthesize activityIndicator;
@synthesize lastContentOffsetX;
@synthesize comicName;
@synthesize backButton;

BOOL _bubblesAdded;
BOOL _resourcesAdded;

int panelId;
int numPanels;
int panelCounter;

int numComicPanels;
int comicPanelCounter;

int numPlacements;
int placementCounter;
int thumbnailIndex;
int clickedPanelIndex;

PanelLoader* panelsLoader;
ComicLoader* comicLoader;
ResourceLoader* resourceLoader;

Panel* currentPanel;
Comic* currentComic;
Placement* currentPlacement;


NSArray *comicPanelList;
NSArray *comicPanelThumbnailIds;
NSArray *resourceList;
NSArray *placementList;

NSString* urlImageString;
UILabel* clickLabel;
NSMutableArray* downloadedPanels;
NSMutableArray* downloadedPhotos;

BOOL thumbMode;
BOOL alertShown;

int addAlertView = 0;
int deleteAlertView = 1;
int backAlertView = 2;

NSFileManager* fileMgr;
NSString *documentsDirectory;

-(void) initiateDataSet
{
    //NSLog(@"initiateDataset");
    currentPage = 0;
    numPanels = 0;
    panelCounter = 0;
    numComicPanels = 0;
    comicPanelCounter = 0;
    numPlacements = 0;
    placementCounter = 0;
    
    panels = [[NSArray alloc] init];
    comicPanelList = [[NSArray alloc] init];
    comicPanelThumbnailIds = [[NSArray alloc] init];
    resourceList = [[NSArray alloc] init];
    placementList = [[NSArray alloc] init];
    downloadedPanels = [[NSMutableArray alloc] init];
    downloadedPhotos = [[NSMutableArray alloc] init];
    
    panelsLoader = [[PanelLoader alloc] init];
    panelsLoader.delegate = self;

    resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate = self;
    
    comicLoader = [[ComicLoader alloc] init];
    comicLoader.delegate = self;
    
    _bubblesAdded = NO;
    _resourcesAdded = NO;
    thumbMode = NO;
    alertShown = NO;
    
    lastContentOffsetX = 0.0;
    clickedPanelIndex = 0;
    
    fileMgr = [NSFileManager defaultManager];
    ///Library/Caches
    documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
}



-(void)addLabel
{
    clickLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(0, 40, 320, 320)];
    clickLabel.textColor = [UIColor whiteColor];
    clickLabel.backgroundColor = [UIColor blackColor];
    //clickLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(36.0)];
    clickLabel.text = [NSString stringWithFormat: @"Click a thumbnail to add to the comic."];
    [clickLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    [self.view addSubview:clickLabel];
}


- (void)longPressGestureCaptured:(UILongPressGestureRecognizer*)gesture
{
    //NSLog(@"longPressGesture");
    if([comicPanelList count] >0)
    {
        if(!alertShown)
        {
            alertShown = YES;
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Delete Image"
                                                              message:@"Delete image from the comic."
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Delete", nil];
            message.tag = deleteAlertView;
            [message show];
        }
        
        
    }

}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    // Determine the position of clicked thumbnail
    CGPoint touchPoint=[gesture locationInView:thumbnailScrollView];
    CGFloat pos = (CGFloat)touchPoint.x / thumbnailWidth;
    int page = round(ceilf(pos));
    //NSLog(@"singleTap. page= %i", page);
    
    if(page>0)
        page--;
    
    if(page>=0 && page < [downloadedPhotos count])
    {
        
        NSNumber* yesObj = [NSNumber numberWithBool:YES];
        [downloadedPhotos replaceObjectAtIndex:page withObject:yesObj];
    }

    if(!alertShown)
    {
        clickedPanelIndex = page;
        alertShown = YES;
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Add panel"
                                                          message:@"You are adding this panel."
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Confirm", nil];
        message.tag=addAlertView;
        [message show];
    }
    
    /*
    //currentPage++;
    //NSLog(@"singleTap. page= %i", page);
    //Remove bubbles and resources from the current view
    //if(page!=currentPage)
    {
        [self removeAllBubbles];
        [self removeAllResources];
    }
    //Add a panel to the comic
    [self addNewPanelToComic:page];
     */
}

-(void)addNewPanelToComic:(int)page
{
    //NSLog(@"addNewPanelToComic.currentPage=%i", currentPage);
    [activityIndicator startAnimating];
    
    if(page>=0 && page<[panels count])
    {
        Panel* panel = [panels objectAtIndex:page];
        if(panel!=nil)
        {
            
            //Add panel to the comic panelList
            comicPanelList = [self arrayByAddingObject:comicPanelList andObject:panel];
            comicPanelThumbnailIds = [self arrayByAddingObject:comicPanelThumbnailIds andObject:[NSNumber numberWithInt:page]];
            
            numComicPanels= [comicPanelList count];
            //NSLog(@"add panel.panelId=%i to comic. comicPanelCounter=%i", panel.panelId, comicPanelCounter);
            currentPage = [comicPanelList count] -1;
            //NSLog(@"addNewPanelToComic.currentPage=%i", currentPage);
            
            //remove clickLabel if there are panels in thumbnail scrollView
            if([comicPanelList count]>0)
            {
                if(postButton.enabled == NO)
                {
                    //NSLog(@"panelScrollView added.");
                    [clickLabel removeFromSuperview];
                    //[self.view addSubview:panelScrollView];
                    
                    if([comicPanelList count]>1)
                    {
                        postButton.enabled = YES; 
                    }//end if([comicPanelList count]>1)

                }//end if(postButton.enabled == NO)
                
            }//end if([comicPanelList count]>0)
            
            //Update the number of items in comic scrollview
            panelScrollView.numItems = [comicPanelList count];
            //Display images in comic scrollview
            [panelScrollView layoutItems];
            //Scroll to the most recently added panel in the comicScrollView
            [panelScrollView scrollItemToVisible:currentPage];
            
         
             UIImage *image = [UIImage imageNamed:panel.photo.imageURL];
             //Add image to the imageview
             UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
             [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
             placeholderImage:nil];
             imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjWidth);
             imageView.tag = currentPage;
             
             [activityIndicator stopAnimating];
             // add image to the panel scrollview
             [panelScrollView addSubview:imageView];
             //NSLog(@"addNewPanelToComic.subView added to panelScrollView. [panelScrollView.subviews count]= %i", [panelScrollView.subviews count]);
             
             //NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
             //[downloadedPanels addObject:panelDownloaded];
             
             //Add bubbles and resources to the new panel's view
             //[panelsLoader submitRequestGetPanelWithId:panel.panelId];
             
             comicPanelCounter++;
             if([comicPanelList count]==1)
             {
             [self alignPageInPanelScrollView];
             }
             
             if([comicPanelList count]>1)
             {
             [self displayPageInPanelScrollView:currentPage-1];
             }
             
             
        }//end if(panel!=nil)

    }//end if(page>=0 && page<[panels count])
    
   
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        //_groupName = [prefs objectForKey:@"groupname"];
        //_groupname = @"d1";
        //NSLog(@"groupname is %@", _groupname);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newImageNotification)
                                                     name:@"newImageNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newImageNotification)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [self initiateDataSet];
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //NSLog(@"viewDidLoad");
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
    
    
    [self.backButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.backButton.layer.borderWidth=4.0f;
    self.backButton.clipsToBounds = YES;
    self.backButton.layer.cornerRadius = 10;//half of the width
    [self.backButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    self.backButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    
    
    [self initiateScrollViews];
    
    if(numComicPanels==0)
    {
        [self addLabel];
        postButton.enabled = NO;
    }
    
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
	activityIndicator.center = self.view.center;
	[self.view addSubview: activityIndicator];
    
    //Load panels in thumbnailscrollViews
    //[panelsLoader submitRequestGetPanelsForGroup:1];
    [panelsLoader submitRequestGetPanelsForGroup];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"viewDidAppear");
    //_bubblesAdded = NO;
    //_resourcesAdded = NO;
    //[self updateScrollViews];
}

-(void)initiateScrollViews
{
    //NSLog(@"initiateScrollView.numPanels=%i", numPanels);
    // Add panels scrollview
    CGRect panelFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
    CGSize panelSize = CGSizeMake(panelWidth, panelHeight);
    panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize];
    panelScrollView.delegate=self;
    panelScrollView.tag=0;
    [self.view addSubview:panelScrollView];
    
    // Add thumbnails scrollview
    CGRect thumbFrame = CGRectMake(thumbnailScrollXOrigin, thumbnailScrollYOrigin, thumbnailScrollObjWidth, thumbnailScrollObjHeight);
    CGSize thumbnailSize = CGSizeMake(thumbnailWidth, thumbnailHeight);
    thumbnailScrollView = [[MainScrollSelector alloc] initWithFrame:thumbFrame andItemSize:thumbnailSize];
    thumbnailScrollView.delegate=self;
    thumbnailScrollView.tag=1;
    [self.view addSubview:thumbnailScrollView];
}

- (void)updateScrollViews
{
    
    if([panels count]>0) {
        
        panelScrollView.numItems = numComicPanels;
        [panelScrollView layoutItems];
        
        //NSLog(@"updateScrollViews.[panelScrollView.subviews count]= %i", [panelScrollView.subviews count]);
        thumbnailScrollView.numItems = [panels count];
        [thumbnailScrollView layoutItems];
        
        
        //NSLog(@"updateScrollViews.numPanels=%i", numPanels);
        //currentPage = 0;
        
        //currentPanel= [comicPanelList objectAtIndex:currentPage];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        singleTap.cancelsTouchesInView = NO;
        [thumbnailScrollView addGestureRecognizer:singleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        longPress.cancelsTouchesInView = NO;
        [panelScrollView addGestureRecognizer:longPress];
        
        

    }//end if(numPanels>0)
    
}//end updateScrollViews

-(void)alignPageInPanelScrollView
{
    thumbMode = NO;
    if([comicPanelList count]>0)
    {
        
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        //NSLog(@"alignPageInPanelScrollView.page=%i", page);
        
        [self removeAllBubbles];
        [self removeAllResources];
        
        currentPage= page;
        
        //NSLog(@"alignPageInPanelScrollView.currentPage=%i, selectedThumbnailIndex=%i", currentPage, selectedThumbnailIndex);
        
        if(currentPage>=0 && currentPage<[comicPanelList count])
        {
            currentPanel = [comicPanelList objectAtIndex:currentPage];
            
            
            if(currentPanel!=nil)
            {
                
                BOOL displayed= NO;
                for(UIView* subView in panelScrollView.subviews)
                {
                    if([subView isKindOfClass:[UIImageView class]] && subView.tag==currentPage)
                    {
                        [subView removeFromSuperview];
                        //displayed=YES;
                        break;
                    }//end if
                }//end for
                
                //NSLog(@"currentPanel.panelId=%i, displayed=%d, currentPage=%i, currentPanel.photo.imageURL=%@", currentPanel.panelId, displayed, currentPage, currentPanel.photo.imageURL);
                if(!displayed)
                {
                    UIImageView *imageView = [[UIImageView alloc] init];
                    [imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:nil];
                    imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                    imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion

                    //[imageView setContentMode:UIViewContentModeScaleAspectFill];
                    //[activityIndicator stopAnimating];
                    // add images to the panel scrollview
                    [panelScrollView addSubview:imageView];
                    //NSLog(@"alignPageInPanelScrollView.subView added to panelScrollView. [panelScrollView.subviews count]= %i", [panelScrollView.subviews count]);
                }//end if(!displayed)
                
                
                [activityIndicator stopAnimating];
                thumbMode = NO;
                
                //NSLog(@"alignPageInPhotoTableView. downloadedPanels objectAtIndex:currentPage.currentPage=%i, [self.panels count]=%i", currentPage, [self.panels count]);
                
                //Check if the panel alongwith placements and annotations have already been downloaded
                //Find the corresponding thumbnail image of a panel in the comic
                int selectedThumbnailIndex = [[comicPanelThumbnailIds objectAtIndex:currentPage] intValue];
                if(selectedThumbnailIndex>=0 && selectedThumbnailIndex<[downloadedPanels count])
                {
                    //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:selectedThumbnailIndex] boolValue];
                    BOOL panelDownloaded = [[downloadedPanels objectAtIndex:selectedThumbnailIndex] boolValue];
                    //NSLog(@"alignPageInPanelScrollView.thumbMode=%d. Panel#%i downloaded=%d.", thumbMode, currentPage, panelDownloaded);
                    if(!panelDownloaded)
                    {
                        //NSLog(@"alignPageInPanelScrollView. Panel#%i download called.", currentPage);
                        //Download annotations and placements of the panel
                        [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
                    }
                    else
                    {
                        //NSLog(@"placements already downloaded.");
                        [self loadPlacements:currentPanel];
                        
                        //NSLog(@"annotations already downloaded are added.");
                        [self loadAnnotations:currentPanel];

                    }//end else
                }//end if(selectedThumbnailIndex>=0 && selectedThumbnailIndex<[downloadedPanels count])
                

                if(currentPage==[comicPanelList count]-1)
                {
                    [self displayPageInPanelScrollView:currentPage-1];
                }
               
                else if(currentPage<[comicPanelList count]-1)
                {
                    [self displayPageInPanelScrollView:currentPage+1];
                    if(currentPage>0)
                        [self displayPageInPanelScrollView:currentPage-1];
                }
               
                //Remove other panels to free up memory
                //if([comicPanelList count]>3)
                {
                    for(UIView* subView in panelScrollView.subviews)
                    {
                        //if(subView.tag!=currentPage && subView.tag!=currentPage+1 && subView.tag!=currentPage-1)
                            //if(subView.tag!=currentPage)
                        if(subView.tag>currentPage+1 || subView.tag<currentPage-1)
                        {
                            //NSLog(@"currentPage=%i, subView.tag=%i removed", currentPage, subView.tag);
                            [subView removeFromSuperview];
                        }
                    }//end for
                    
                }//end if([panels count]>3)
                 
            }//end if currentPanel!=nil
             
        }//end if currentPage>=0

        
    }//end if _numImages>0
}

-(void)loadAnnotations:(Panel*)panel{
    
    if(panel!=nil)
    {
        //Download speech bubbles
        if(panel.annotations!=nil)
        {
            for(Annotation* annotation in panel.annotations)
            {
                
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
                
            }//end for
        }//end if
    }//end if
    
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
                for(placementCounter=0; placementCounter<[currentPanel.resources count]; placementCounter++)
                {
                    Resource* resource = [currentPanel.resources objectAtIndex:placementCounter];
                    if(resource!=nil)
                    {
                        
                        NSString* type = resource.type;
                        float defaultScale = 1.0;
                        float defaultAngle = 0.0;
                        
                        CGRect resourceFrame= CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
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


-(void)alignPageInThumbnailScrollView
{
    thumbMode = YES;
    //NSLog(@"alignPageInThumbnailScrollView.numPanels=%i", numPanels);
    if(numPanels>0)
    {
        //NSLog(@"alignPage. numPanels= %i", numPanels);
        
        CGFloat pos = (CGFloat)self.thumbnailScrollView.contentOffset.x / thumbnailWidth;
        int page = round(ceilf(pos));
        
        //if(lastContentOffsetX == self.thumbnailScrollView.contentOffset.x && page==[self.panels count]-1)
        {
            //NSLog(@"ComicAddViewController.panels refreshed");
            //[panelsLoader submitRequestRefreshGetPanelsForGroup];
        }
        
        lastContentOffsetX = self.thumbnailScrollView.contentOffset.x;
        
        /*
        CGFloat totalWidth = (CGFloat) ([self.panels count]-1)*thumbnailWidth;
        NSLog(@"alignPageInThumbnailScrollView.self.thumbnailScrollView.contentOffset.x=%f, totalWidth=%f, page=%i, [self.panels count]=%i", self.thumbnailScrollView.contentOffset.x, totalWidth, page, [self.panels count]);
        */
        thumbPage = page;
        //NSLog(@"alignPageInThumbnailScrollView.page=%i, [panels count]=%i, thumbnailIndex=%i", page, [panels count], thumbnailIndex);
        
        //Add bubbles and resources to a panel after scrolling
        if(page>=0 && page<[self.panels count])
        {
            thumbnailIndex = thumbPage;
            [self generateThumbails];
            /*
            for(int index=page; index<page+4; index++)
            {
                //Load new panel after scrolling
                Panel* thumbnailPanel = [panels objectAtIndex:(index)];
                if(thumbnailPanel!=nil)
                {
                    //NSLog(@"panel downloaded.");
                    //Add to panelscrollview
                    UIImageView *imageView = [[UIImageView alloc] init];
                    [imageView setImageWithURL:[NSURL URLWithString:thumbnailPanel.photo.imageURL] placeholderImage:nil];
                    imageView.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailScrollObjHeight);
                    imageView.tag = index;
                    // add images to the thumbnail scrollview
                    [thumbnailScrollView addSubview:imageView];
                    
                }//end if
            }//end for
            
            if([panels count]>4)
            {
                for(UIView* subView in thumbnailScrollView.subviews)
                {
                    if(subView.tag>page+7 || subView.tag<page-4)
                    {
                        [subView removeFromSuperview];
                    }
                }//end for
                
            }//end if([panels count]>3)
            */ 
            
        }//end if page>=0 && page<[self.panels count]
        
    }//end if _numImages>0
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
    //NSLog(@"scrollViewWillBeginDragging");
    //Remove bubbles and resources from the panel when the scrolling starts
    if(scrollView.tag==0)
    {
        [self removeAllBubbles];
        [self removeAllResources];
    }
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

-(void)didReceiveMemoryWarning{
    //NSLog(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

-(void)newImageNotification
{
    //NSLog(@"newImageNotification.");
    [self removeAllBubbles];
    [self removeAllResources];
    [self updateScrollViews];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"comicPosterView"])
    {
        if([panels count] >0)
        {
            
            ComicPosterViewController *cpvc = (ComicPosterViewController *)[segue destinationViewController];
            cpvc.comicContents = [[NSMutableArray alloc] init];
            cpvc.comicName = comicName;
            
            NSUInteger i;
            for(i=0; i<[comicPanelList count]; i++)
            {
                int panelId = [[comicPanelList objectAtIndex:i] panelId];
                [cpvc.comicContents addObject:[NSNumber numberWithInt:panelId]];
            }
            
        }//end if panelList count > 0
    } //end if
    
    
    if([[segue identifier] isEqualToString:@"editComic"])
    {
    }//end if
    
    
}


- (IBAction)deletePanel:(id*)sender
{
    if([comicPanelList count] >0)
    {
        if(!alertShown)
        {
            alertShown = YES;
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Delete Image"
                                                              message:@"Delete image from the comic."
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Delete", nil];
            message.tag = deleteAlertView;
            [message show];
        }
        

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if(alertView.tag==deleteAlertView)
    {
        if([title isEqualToString:@"Delete"])
        {
            //NSLog(@"Button 1 was selected.");
            alertShown = NO;
            [self deletePanelConfirmed];
        }
    }//end if(alertView.tag==deleteAlertView)

    if(alertView.tag==addAlertView)
    {
        if([title isEqualToString:@"Confirm"])
        {
            //if(page!=currentPage)
            {
                [self removeAllBubbles];
                [self removeAllResources];
            }
            //Add a panel to the comic
            [self addNewPanelToComic:clickedPanelIndex];
            alertShown = NO;
            return;
        }
    }//end if(alertView.tag==addAlertView)
    
    if(alertView.tag==backAlertView)
    {
        if([title isEqualToString:@"Confirm"])
        {
            NSLog(@"backAlertView.Confirm pressed");
            alertShown = NO;
            if([comicPanelList count]==0)
            {
                //[clickLabel removeFromSuperview];
            }

            [self.navigationController popViewControllerAnimated:YES];
            //[self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
    }//end if(alertView.tag==backAlertView)
    
    if([title isEqualToString:@"Cancel"])
    {
        //NSLog(@"Button 2 was selected.");
        alertShown = NO;
        return;
    }
    

    
    
}

-(void)deletePanelConfirmed
{
    if([comicPanelList count] >0)
    {
        //NSLog(@"deletePanelConfirmed. numComicPanels=%i and currentPage=%i", [comicPanelList count],  currentPage);
        int itemReplaced = 0;
        int itemRemoved= currentPage;
        
        if(currentPage>=0 && currentPage<[comicPanelList count])
        {
            for (UIView *subview in panelScrollView.subviews)
            {
                if([subview isKindOfClass:[UIImageView class]] && currentPage==subview.tag)
                {
                    
                    [subview removeFromSuperview];
                    [self removeAllBubbles];
                    [self removeAllResources];
                    comicPanelList = [self arrayByRemovingObject:comicPanelList andObjectIndex:itemRemoved];

                    if(currentPage>0)
                        currentPage--;
                    
                    //NSLog(@"[panelList count] after %i", [panelList count]);
                    if([comicPanelList count]==0)
                    {
                        //[panelScrollView removeFromSuperview];
                        [self.view addSubview:clickLabel];
                        currentPage = 0;
                        postButton.enabled = NO;
                    }//end if
                    else if([comicPanelList count]>0)
                    {
                        
                        if(itemRemoved==[comicPanelList count])
                        {
                            itemReplaced=[comicPanelList count]-1;
                        }
                        else if(itemRemoved<[comicPanelList count])
                        {
                            itemReplaced=itemRemoved;
                        }
                        
                        //NSLog(@"itemReplaced %i", itemReplaced);
                        panelScrollView.numItems = [comicPanelList count];
                        [panelScrollView layoutItems];
                        //[panelScrollView scrollItemToVisible:(itemReplaced)];
                        //currentPage = itemReplaced;
                        //currentPanel = [comicPanelList objectAtIndex:itemReplaced];
                    } //end else if([comicPanelList count]>0)
                    break;
                }//end if([subview isKindOfClass:[UIImageView class]] && currentPage==subview.tag)
            }//end for
            
            //NSLog(@"deletePanelConfirmed. After, [panelScrollView.subviews count]= %i", [panelScrollView.subviews count]);
            //Re-assign tags to subviews in panel scrollviews
            comicPanelCounter = 0;
            for (UIView *subview in panelScrollView.subviews)
            {
                if([subview isKindOfClass:[UIImageView class]])
                {
                    subview.tag = comicPanelCounter;
                    comicPanelCounter++;
                }//end if
            }//end for subviews 

            [self alignPageInPanelScrollView];
        } //end if currentPage < [comicPanelList count]
    }//end if [comicPanelList count] > 0
    
    
}

-(NSArray *)arrayByRemovingObject:(NSArray*)array andObjectIndex:(int)index
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray removeObjectAtIndex:index];
    return [NSArray arrayWithArray:newArray];
}

-(NSArray *)arrayByAddingObject:(NSArray*)array andObject:(id)object
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray addObject:object];
    return [NSArray arrayWithArray:newArray];
}


-(void)addComicPanelToComicScrollView:(Panel*)panel
{
 
    if(panel!=nil)
    {

        //NSLog(@"addPanelToComicScrollView.panel=%i, currentPage=%i, imageView.tag=comicPanelCounter=%i", panel.panelId, currentPage, comicPanelCounter);
        //if(comicPanelCounter==0 || (currentPage >= comicPanelCounter))
        {
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:nil];
            imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
            imageView.tag = currentPage;
            // add images to the thumbnail scrollview
            [panelScrollView addSubview:imageView];
            
            //NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
            //[downloadedPanels addObject:panelDownloaded];
            /*
            CGRect rect1 = imageView.frame;
            rect1.size.height = panelScrollObjHeight;
            rect1.size.width = panelWidth;
            imageView.frame = rect1;
            imageView.tag = comicPanelCounter;
            //imageView.tag = panel.panelId;	// tag our images for later use when we place them in serial fashion
            */

            
            //Update comicPanelCounter
            comicPanelCounter++;
            
            //[self updateScrollViews];

        }

    }//end if panel!=nil
    
}

-(void)addPanelToThumbnailScrollViews:(Panel*)panel
{
    if(panel!=nil)
    {
        //NSLog(@"panel added to thumbnail scrollviews=%i, and panelCounter=%i", panel.panelId, panelCounter);
        
        UIImageView *thumbnailView = [[UIImageView alloc] init];
        [thumbnailView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:nil];
        
        CGRect rect1 = thumbnailView.frame;
        rect1.size.height = thumbnailScrollObjHeight;
        rect1.size.width = thumbnailWidth;
        thumbnailView.frame = rect1;
        thumbnailView.tag = panelCounter;	// tag our images for later use when we place them in serial fashion
        
        
        // add images to the thumbnail scrollview
        [thumbnailScrollView addSubview:thumbnailView];
    }
    
    panelCounter++;
    
    if(panelCounter==numPanels)
        [self updateScrollViews];
}

-(void)addSpeechBubbles:(Panel*)panel{
    
    if(panel!=nil)
    {
        //Download speech bubbles
        if(panel.annotations!=nil)
        {
            for(Annotation* annotation in panel.annotations)
            {
                
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
                
            }//end for
        }//end if
    }//end if
    
}

-(void)addResources:(Panel*)panel{
    
    if(panel!=nil)
    {
        currentPanel = panel;
        
        //Download placements
        if(panel.placements!=nil)
        {
            //NSLog(@"didLoadPanel.panel.panelId=%i has %i placements", panel.panelId, [panel.placements count]);
            
            placementList = panel.placements;
            numPlacements = [panel.placements count];
            placementCounter = 0;
            
            
            //Load placements of a panel
            if(numPlacements>0)
            {
                currentPlacement = [currentPanel.placements objectAtIndex:placementCounter];
                if(currentPlacement!=nil)
                {
                    int resourceId = currentPlacement.resourceId;
                    [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                }
                
                
            }//end for
        }//end if
        
    }//end if
    
}

-(NSArray*)arrayByReplacingObject:(NSArray*)array andObjectIndex:(int)index andNewObject:(Panel*)panel
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray replaceObjectAtIndex:index withObject:panel];
    //[newArray addObject:object];
    return [NSArray arrayWithArray:newArray];
}


-(void)generateThumbails
{
    //thumbnailIndex = thumbPage;
    thumbMode = YES;
    //NSLog(@"generateThumbnails.thumbMode=%d, thumbPage=%i, thumbnailIndex=%i", thumbMode, thumbPage, thumbnailIndex);

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
        
        [self displayThumbnails];
        
    }//end if(thumbnailIndex<[self.panels count])
}

-(void)displayThumbnails
{
    //NSLog(@"displayThumbails.thumbMode=%d, thumbPage=%i, thumbnailIndex=%i", thumbMode, thumbPage, thumbnailIndex);
    for(int index=thumbPage; index<thumbPage+4; index++)
    {
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
                //aIndicator.frame = CGRectMake((index-thumbPage)*thumbnailWidth, thumbnailScrollYOrigin, thumbnailWidth, thumbnailScrollObjHeight);
                aIndicator.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailScrollObjHeight);
                //aIndicator.center = CGPointMake(aIndicator.frame.origin.x+(thumbnailWidth/2), thumbnailScrollYOrigin+(thumbnailScrollObjHeight/2));
                aIndicator.center = CGPointMake(aIndicator.frame.origin.x+(thumbnailWidth/2), 0+(thumbnailScrollObjHeight/2));
                aIndicator.tag=index;
                [aIndicator startAnimating];
                //[self.view addSubview:aIndicator];
                [thumbnailScrollView addSubview:aIndicator];
            }
            //NSLog(@"displayThumbails. self.panels objectAtIndex:currentPage.currentPage=%i, index=%i, [self.panels count]=%i", currentPage, index, [self.panels count]);
            Panel* thumbnailPanel = [self.panels objectAtIndex:index];
            BOOL panelDownloaded = [[downloadedPanels objectAtIndex:index] boolValue];
            //NSLog(@"displayThumbnails. PanelIndex=%i is downloaded=%d has placements=%i", index, panelDownloaded, [thumbnailPanel.placements count]);
            BOOL displayed = NO;
            
            if([panelsLoader isReachable])
            {
                if(thumbnailPanel!=nil && panelDownloaded)
                {
                    displayed = YES;
                }
            }
            else if([panelsLoader isReachable])
            {
                if(thumbnailPanel!=nil)
                {
                    displayed = YES;
                }
            }
                
            if(displayed)
            //if(thumbnailPanel!=nil && panelDownloaded)
            //if(thumbnailPanel!=nil)
            {
                //NSLog(@"displayThumbnails. PanelIndex=%i is downloaded=%d has placements=%i", index, panelDownloaded, [thumbnailPanel.placements count]);
                /*
                BOOL photoDownloaded = [[downloadedPhotos objectAtIndex:index] boolValue];
                //NSLog(@"downloadedPhotos objectAtIndex:[%i]=%d", index, photoDownloaded);
                if(!photoDownloaded)
                {
                    CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                    thumbnailPanel.thumbnail=thumbnailView.snapshot;
                    //NSLog(@"thumbnail#%i generated",index);
                    
                    NSNumber* yesObj = [NSNumber numberWithBool:YES];
                    if(index<[downloadedPhotos count])
                        [downloadedPhotos replaceObjectAtIndex:index withObject:yesObj];
                }
                
                
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);
                //[imageView setImage:thumbnailPanel.thumbnail];
                if(!photoDownloaded)
                    [imageView setImageWithURL:[NSURL URLWithString:thumbnailPanel.photo.imageURL] placeholderImage:nil];
                else
                    [imageView setImage:thumbnailPanel.thumbnail];
                imageView.tag = index;
                [thumbnailScrollView addSubview:imageView];
                //NSLog(@"thumbnail#%i displayed",index);
                 */
                
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);
                
                //NSString* thumbName = [NSString stringWithFormat:@"thumbPhoto%i.png", thumbnailPanel.panelId];
                //NSString* thumbFile = [documentsDirectory stringByAppendingPathComponent:thumbName];
                //if(![fileMgr fileExistsAtPath:thumbFile])
                
                /*
                 BOOL photoDownloaded = [[downloadedPhotos objectAtIndex:index] boolValue];
                 //NSLog(@"displayThumbnails.downloadedPhotos objectAtIndex:index[%i]=%d", index, photoDownloaded);
                 if(!photoDownloaded)
                 {
                 CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                 ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                 thumbnailPanel.thumbnail=thumbnailView.snapshot;
                 
                 //[imageView setImage:thumbnailPanel.thumbnail];
                 
                 //NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(thumbnailPanel.thumbnail)];
                 //[data1 writeToFile:thumbFile atomically:YES];
                 
                 NSNumber* yesObj = [NSNumber numberWithBool:YES];
                 if(index<[downloadedPhotos count])
                 [downloadedPhotos replaceObjectAtIndex:index withObject:yesObj];
                 
                 
                 }
                 
                 if(photoDownloaded)
                 {
                 NSString* panelName = [NSString stringWithFormat:@"panelPhoto%i.png", thumbnailPanel.photo.photoId];
                 NSString* panelFile = [documentsDirectory stringByAppendingPathComponent:panelName];
                 BOOL panelExists = [fileMgr fileExistsAtPath:panelFile];
                 
                 if(panelExists)
                 {
                 CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                 ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                 thumbnailPanel.thumbnail=thumbnailView.snapshot;
                 [imageView setImage:thumbnailPanel.thumbnail];
                 
                 }//end if(panelExists)
                 else if(!panelExists)
                 {
                 [imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                 
                 }//end else if(!panelExists)
                 
                 
                 }
                 */
                
                
                
                //[imageView setImage:thumbnailPanel.thumbnail];
                
                //NSFileManager* fileMgr = [NSFileManager defaultManager];
                //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                
                //NSString* thumbName = [NSString stringWithFormat:@"thumbPhoto%i.png", thumbnailPanel.panelId];
                //NSString* thumbFile = [documentsDirectory stringByAppendingPathComponent:thumbName];
                NSString* panelName = [NSString stringWithFormat:@"panelPhoto%i.png", thumbnailPanel.photo.photoId];
                NSString* panelFile = [documentsDirectory stringByAppendingPathComponent:panelName];
                BOOL panelExists = [fileMgr fileExistsAtPath:panelFile];
                //NSLog(@"PanelViewController.displayThumbnails. %@ exists=%d", panelFile, panelExists);
                //BOOL thumbnailExists = [fileMgr fileExistsAtPath:thumbFile];
                //NSLog(@"%@ exists=%d", thumbName, thumbnailExists);
                
                
                if(panelExists)
                {
                    
                    BOOL photoDownloaded = [[downloadedPhotos objectAtIndex:index] boolValue];
                    //BOOL photoDownloaded = [fileMgr fileExistsAtPath:thumbFile];
                    //NSLog(@"displayThumbnails.downloadedPhotos objectAtIndex:index[%i]=%d", index, photoDownloaded);
                    if(!photoDownloaded)
                    {
                        CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                        ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                        thumbnailPanel.thumbnail=thumbnailView.snapshot;
                        
                        //NSLog(@"displayThumbnails.downloadedPhotos objectAtIndex:index[%i]=%d. Thumbnail generated", index, photoDownloaded);
                        [imageView setImage:thumbnailPanel.thumbnail];
                        
                        //NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(thumbnailPanel.thumbnail)];
                        //[data1 writeToFile:thumbFile atomically:YES];
                        
                        NSNumber* yesObj = [NSNumber numberWithBool:YES];
                        if(index<[downloadedPhotos count])
                            [downloadedPhotos replaceObjectAtIndex:index withObject:yesObj];
                        
                    }
                    else{
                        //NSLog(@"displayThumbnails.downloadedPhotos objectAtIndex:index[%i]=%d. Thumbnail existed.", index, photoDownloaded);
                        [imageView setImage:thumbnailPanel.thumbnail];
                        //UIImage* imageDownloaded = [UIImage imageWithContentsOfFile:thumbFile];
                        //[imageView setImage:imageDownloaded];
                    }
                    
                    /*
                     CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                     ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                     thumbnailPanel.thumbnail=thumbnailView.snapshot;
                     */
                    /*
                     if(![fileMgr fileExistsAtPath:thumbFile])
                     {
                     CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                     ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                     thumbnailPanel.thumbnail=thumbnailView.snapshot;
                     
                     NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(thumbnailPanel.thumbnail)];
                     [data1 writeToFile:thumbFile atomically:YES];
                     
                     }
                     */
                    //[imageView setImage:thumbnailPanel.thumbnail];
                    
                    //NSLog(@"displayThumbnails.Thumbnail#%i with resources", index);
                    //UIImage* imageDownloaded = [UIImage imageWithContentsOfFile:panelFile];
                    //[imageView setImage:imageDownloaded];
                    
                    //NSNumber* yesObj = [NSNumber numberWithBool:YES];
                    //if(index<[downloadedPhotos count])
                    //    [downloadedPhotos replaceObjectAtIndex:index withObject:yesObj];
                }//end if(panelExists)
                else if(!panelExists)
                {
                    /*
                     if(index==[self.panels count]-1)
                     {
                     CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                     ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                     thumbnailPanel.thumbnail=thumbnailView.snapshot;
                     
                     [imageView setImage:thumbnailPanel.thumbnail];
                     }
                     */
                    //else
                    {
                        //NSLog(@"displayThumbnails.panel:index[%i] file exists = %d.", index, panelExists);
                        
                        CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                        ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                        thumbnailPanel.thumbnail=thumbnailView.snapshot;
                        //NSLog(@"displayThumbnails.panel:index[%i] file exists = %d. Thumbnail generated", index, panelExists);
                        
                        panelExists = [fileMgr fileExistsAtPath:panelFile];
                        //NSLog(@"displayThumbnails.panel:index[%i] file exists = %d. After thumbnail generated", index, panelExists);
                        if(panelExists)
                        {
                            //NSLog(@"displayThumbnails.panel:index[%i] file exists = %d. Thumbnail with resources.", index, panelExists);
                            [imageView setImage:thumbnailPanel.thumbnail];
                        }
                        else
                        {
                            //NSLog(@"displayThumbnails.panel:index[%i] file exists = %d. Thumbnail without resources.", index, panelExists);
                            [imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                        }
                    }
                    
                    
                    
                    //NSLog(@"displayThumbnails.Thumbnail#%i without resources", index);
                    
                    /*
                     CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                     ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                     thumbnailPanel.thumbnail=thumbnailView.snapshot;
                     
                     [imageView setImage:thumbnailPanel.thumbnail];
                     */
                    /*
                     [imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                     placeholderImage:nil
                     success:^(UIImage *imageDownloaded) {
                     
                     //NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                     //[data1 writeToFile:panelFile atomically:YES];
                     //[[NSUserDefaults standardUserDefaults] synchronize];
                     //NSLog(@"PanelViewController.displayThumbnails. File saved [%@]", panelFile);
                     
                     }
                     failure:^(NSError *error) {
                     NSLog(@"PanelViewController.displayThumbnails.Failed to load image");
                     }];
                     */
                }
                
                
                
                
                /*
                 if(fileExists)
                 {
                 UIImage* imageDownloaded = [UIImage imageWithContentsOfFile:thumbFile];
                 [imageView setImage:imageDownloaded];
                 }
                 */
                
                //[imageView setImage:thumbnailPanel.thumbnail];
                
                
                /*
                 photoDownloaded = [[downloadedPhotos objectAtIndex:index] boolValue];
                 
                 
                 fileExists = [fileMgr fileExistsAtPath:currentFile];
                 //NSLog(@"Panel without resources shown. index=%i", index);
                 //NSLog(@"displayThumbnails.before setImage, downloadedPhotos objectAtIndex:index[%i]=%d", index, photoDownloaded);
                 //if(!photoDownloaded)
                 if(!fileExists)
                 {
                 //NSLog(@"displayThumbnails.Thumbnail without resources shown. index=%i", index);
                 //[imageView setImageWithURL:[NSURL URLWithString:[thumbnailPanel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                 
                 CGRect thumbFrame= CGRectMake(index*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                 ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:thumbnailPanel];
                 thumbnailPanel.thumbnail=thumbnailView.snapshot;
                 
                 }//end if(!photoDownloaded)
                 else
                 {
                 //NSLog(@"displayThumbnails.Thumbnail with resources shown. index=%i", index);
                 //[imageView setImage:thumbnailPanel.thumbnail];
                 }
                 */
                //[imageView setImage:thumbnailPanel.thumbnail];

                
                
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
            }//end if(thumbnailPanel!=nil && panelDownloaded)
            
        }//end if(index<[self.panels count])
    }//end for
    
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
    
    
    if(thumbPage>=4)
    {
        for(int page=thumbPage-1; page>thumbPage-5; page--)
        {
            [self displayPageInThumbnailScrollView:page];
        }
        
    }

    
    for(int page=thumbPage+4; page<thumbPage+8; page++)
    {
        [self displayPageInThumbnailScrollView:page];
    }


    /*
    if(thumbPage<=thumbPage+4)
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
    */
    

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

    //[thumbnailScrollView layoutItems];
}

-(void)displayPageInPanelScrollView:(int)page
{
    if(page>=0 && page<[comicPanelList count])
    {
        //Check if the image already exists in panelscrollview
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
        //If the image does not exist in panelscrollview, display it there
        if(!displayed)
        {
            Panel* panel = [comicPanelList objectAtIndex:page];
            //NSLog(@"displayPageInPanelScrollView.page=%i,currentPage=%i, panelId=%i", page, currentPage, panel.panelId);
            if(panel!=nil)
            {
                UIImageView *imageView = [[UIImageView alloc] init];
                //[imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
                imageView.frame = CGRectMake(page*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                imageView.tag = page;	// tag our images for later use when we place them in serial fashion
                // add images to the panel scrollview
                [panelScrollView addSubview:imageView];
                //NSLog(@"displayPageInPanelScrollView.subView added to panelScrollView. [panelScrollView.subviews count]= %i", [panelScrollView.subviews count]);
            }//end if panel!=nil
        }//end if(!displayed)
        else
        {
            //NSLog(@"displayPageInPanelScrollView.panel#%i already displayed.", page);
        }
        
    }//end if(page>=0 && page<[panels count])
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
            //BOOL photoDownloaded = [[downloadedPhotos objectAtIndex:page] boolValue];
            //NSLog(@"displayPageInPanelScrollView.page=%i,currentPage=%i, panelId=%i, photoDownloaded=%d", page, currentPage, panel.panelId, photoDownloaded);
            if(panel!=nil)
            { 
                UIImageView *imageView = [[UIImageView alloc] init];
                /*
                if(!photoDownloaded)
                    [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
                else
                    [imageView setImage:panel.thumbnail];
                */
                
                
                //NSFileManager* fileMgr = [NSFileManager defaultManager];
                //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString* panelFileName = [NSString stringWithFormat:@"panelPhoto%i.png", panel.photo.photoId];
                NSString* panelFile = [documentsDirectory stringByAppendingPathComponent:panelFileName];
                BOOL panelFileExists = [fileMgr fileExistsAtPath:panelFile];
                if(panelFileExists)
                {
                    /*
                     CGRect thumbFrame= CGRectMake(page*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                     ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:panel];
                     panel.thumbnail=thumbnailView.snapshot;
                     
                     [imageView setImage:panel.thumbnail];
                     */
                    
                    UIImage* imageDownloaded = [UIImage imageWithContentsOfFile:panelFile];
                    [imageView setImage:imageDownloaded];
                }
                else if(!panelFileExists)
                {
                    [imageView setImageWithURL:[NSURL URLWithString:[panel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                    /*
                     [imageView setImageWithURL:[NSURL URLWithString:[panel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                     placeholderImage:nil
                     success:^(UIImage *imageDownloaded) {
                     
                     NSLog(@"displayPageinThumbnailScrollView.saving image=%@", panelFileName);
                     NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                     [data1 writeToFile:panelFile atomically:YES];
                     
                     }
                     failure:^(NSError *error) {
                     NSLog(@"displayPageinThumbnailScrollView.Failed to load image");
                     }];
                     
                     */
                }//end else
                
                
                imageView.frame = CGRectMake(page*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);
                imageView.tag = page;	// tag our images for later use when we place them in serial fashion
                // add images to the panel scrollview
                [thumbnailScrollView addSubview:imageView];
                
                imageView.frame = CGRectMake(page*thumbnailWidth, 0, thumbnailWidth, thumbnailHeight);
                imageView.tag = page;	// tag our images for later use when we place them in serial fashion
                // add images to thumbnail scrollview
                [thumbnailScrollView addSubview:imageView];
            }//end if panel!=nil
        }//end if(!displayed)
        //else
        {
            //NSLog(@"displayPageInPanelScrollView.panel#%i already displayed.", page);
        }
    }//end if(page>=0 && page<[panels count])
}

#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error{
    
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
    //initialized = NO;
    NSMutableArray *newPanels = [[NSMutableArray alloc] initWithArray:panels];
    [newPanels addObjectsFromArray:panelsLocal];
    
    panels = newPanels;
    numPanels = [newPanels count];
    
    
    for(UIView* subView in thumbnailScrollView.subviews)
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
    
    
    [self updateScrollViews];
    [self alignPageInThumbnailScrollView];

}


-(void)PanelLoader:(PanelLoader *)loader didLoadPanels:(NSArray*)panelsLocal{
    

    panels = panelsLocal;
    numPanels = [panels count];
    //NSLog(@"didLoadPanels.numPanels=%i", numPanels);
    if(numPanels>0)
    {
        for (int i=0; i<numPanels;i++)
        {
            NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
            [downloadedPanels addObject:panelDownloaded];
            [downloadedPhotos addObject:panelDownloaded];
        }
        
        [self updateScrollViews];
        [self alignPageInThumbnailScrollView];
    }//end if(numPanels>0)
}

//-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel forObject:(id)obj
-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel*)panel
{
    
    if(panel != nil)
    {
        //NSLog(@"After thumbnail clicked, didLoadPanel.Panel id downloaded.%i, currentPage=%i, [comicPanelList count]=%i, thumbnailIndex=%i", panel.panelId, currentPage, [comicPanelList count], thumbnailIndex);
        
        int index=0;
        if(!thumbMode)
        {
            currentPanel = panel;
            index = currentPage;
            
            //Replace the panel in the panels array with the downloaded panel that contains annotations and placements
            comicPanelList = [self arrayByReplacingObject:comicPanelList andObjectIndex:currentPage andNewObject:currentPanel];
            
            panelId = panel.panelId;
            urlImageString = panel.photo.imageURL;
            //NSLog(@"Panel downloaded. urlImageString=%@", urlImageString);
        }
        else if(thumbMode)
        {
            index = thumbnailIndex;
            panels = [self arrayByReplacingObject:panels andObjectIndex:index andNewObject:panel];
            
        }
        
        //currentPanel = panel;
        //Download speech bubbles
        /*
        if(panel.annotations!=nil)
        {
            if([panel.annotations count]>0)
            {
                for(Annotation* annotation in panel.annotations)
                {
                    if(!thumbMode)
                    {
                       CGRect xywh = CGRectMake(annotation.xOffset, annotation.yOffset,0,0);
                        
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
                    }//end if(!thumbMode)
                }//end for
            }//end if

        }//end if
         */
        
        
        //Download placements
        if(panel.placements!=nil)
        {
            //NSLog(@"didLoadPanel.panel.panelId=%i has %i placements", panel.panelId, [panel.placements count]);
            
            placementList = panel.placements;
            numPlacements = [panel.placements count];
            placementCounter = 0;
            panel.resources = [[NSMutableArray alloc] init];
            
            //Load placements of a panel
            if(numPlacements>0)
            {
                if(placementCounter<numPlacements)
                {
                    currentPlacement = [panel.placements objectAtIndex:placementCounter];
                    if(currentPlacement!=nil)
                    {
                        int resourceId = currentPlacement.resourceId;
                        if(resourceId>0)
                            [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                    }//end if
                }//end if
            }//end if(numPlacements>0)
            else if(numPlacements==0)
            {
                //Declare a panel downloaded
                NSNumber* yesObj = [NSNumber numberWithBool:YES];
                //[downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                if(!thumbMode)
                {
                    if(currentPage<[downloadedPanels count])
                        [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                    
                    
                    if(panel.annotations!=nil)
                    {
                        if([panel.annotations count]>0)
                        {
                            for(Annotation* annotation in panel.annotations)
                            {
                                CGRect xywh = CGRectMake(annotation.xOffset, annotation.yOffset,0,0);
                                
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
                            }//end for
                        }//end if([panel.annotations count]>0)
                        
                    }//end if(panel.annotations!=nil)
                    
                    /*
                    // Scroll to the current page's thumbnail in thumbnail scrollview, after the panel is downloaded
                    [thumbnailScrollView scrollItemToVisible:(currentPage)];
                    if([panels count]<=4)
                        [self alignPageInThumbnailScrollView];
                     */
                }
                if(thumbMode)
                {
                    if(thumbnailIndex<[downloadedPanels count])
                        [downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                    //[downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                    //NSLog(@"didLoadPanel. downloadedPanel turned YES. thumbnailIndex=%i", thumbnailIndex);
                    
                    CGRect thumbFrame= CGRectMake(thumbnailIndex*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:panel];
                    panel.thumbnail=thumbnailView.snapshot;
                    
                    
                    if(thumbnailIndex<thumbPage+3)
                    {
                        thumbnailIndex++;
                        //NSLog(@"didLoadPanel.generateThumbails called.");
                        [self generateThumbails];
                    }
                    
                    /*
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
                     */

                    
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
                

                
            }//end else if(numPlacements==0)
        }//end if(panel.placements!=nil)
    }//end if panel!=nil
}

#pragma mark ResourceLoader functions.
-(void)ResourceLoader:(ResourceLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"resource failed to load.");
    
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResources:(NSArray*)resources{
    NSLog(@"Resources loaded.");
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResource:(Resource*)resource
{
    //NSLog(@"Resource downloaded %i", placementCounter);
    if(resource != nil)
    {
        Panel* resourcePanel;
        if(!thumbMode)
        {
            resourcePanel = currentPanel;
        }
        else if(thumbMode)
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
            else if(placementCounter==(numPlacements-1))
            {
                //NSLog(@"all placements downloaded.thumbMode=%d", thumbMode);
                //Declaring a panel downloaded after all placements are downloaded
                NSNumber* yesObj = [NSNumber numberWithBool:YES];
                
                if(!thumbMode)
                {
                    if(currentPage<[downloadedPanels count])
                        [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                    
                    if(resourcePanel.annotations!=nil)
                    {
                        if([resourcePanel.annotations count]>0)
                        {
                            for(Annotation* annotation in resourcePanel.annotations)
                            {
                                
                                CGRect xywh = CGRectMake(annotation.xOffset, annotation.yOffset,0,0);
                                
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
                                
                            }//end for
                        }//end if([panel.annotations count]>0)
                    }//end if(panel.annotations!=nil)
                    
                    /*
                    // Scroll to the current page's thumbnail in thumbnail scrollview
                    [thumbnailScrollView scrollItemToVisible:(currentPage)];
                    //Display thumbnail images if there is only 1 panel
                    if([panels count]<=4)
                        [self alignPageInThumbnailScrollView];
                    */
                    
                    // Scroll to the current page's thumbnail in thumbnail scrollview
                    //[thumbnailScrollView scrollItemToVisible:(currentPage)];
                }//end if(!thumbMode)
                
                if(thumbMode)
                {
                    if(thumbnailIndex<[downloadedPanels count])
                        [downloadedPanels replaceObjectAtIndex:thumbnailIndex withObject:yesObj];
                    
                    CGRect thumbFrame= CGRectMake(thumbnailIndex*thumbnailWidth, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                    ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithFrame:thumbFrame andPanel:resourcePanel];
                    resourcePanel.thumbnail=thumbnailView.snapshot;
                    
                    if(thumbnailIndex<thumbPage+3)
                    {
                        thumbnailIndex++;
                        //NSLog(@"didLoadResource.generateThumbails called.");
                        [self generateThumbails];
                    }
                    else if(thumbnailIndex==thumbPage+3)
                    {
                        thumbMode = NO;
                        //NSLog(@"didLoadResource.displayThumbails called.");
                        [self displayThumbnails];
                    }
                }//end if thumbMode

                
            }//end else if(placementCounter==(numPlacements-1))
            
        }//end if resourcePanel!=nil
        
        /*
        if(currentPanel.resources!=nil)
        {
            //Add resource to the panel object's resources array.
            [currentPanel.resources addObject:resource];
            
            NSString* type = resource.type;
            float scale = 1.0;
            float angle = 0.0;
            
            //NSString* urlImageString = resource.imageURL;
            //NSLog(@"resource.imageURL=%@",resource.imageURL);
            CGRect resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
            if([type isEqual:@"d"])
            {
                resourceFrame = CGRectMake(currentPlacement.xOffset, currentPlacement.yOffset, decoratorWidth, decoratorHeight);
                scale = currentPlacement.scale;
                angle = currentPlacement.angle;
            }
            if([type isEqual:@"f"])
            {
                resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                scale=1.0;
                angle=0.0;
            }
            
            
            ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andResource:resource
                                                          andScale:scale andAngle:angle];
            rv.userInteractionEnabled = NO;
            [self.view addSubview:rv];
            
            
            if(placementCounter<(numPlacements-1))
            {
                placementCounter++;
                currentPlacement = [currentPanel.placements objectAtIndex:placementCounter];
                if(currentPlacement!=nil)
                {
                    int resourceId=currentPlacement.resourceId;
                    if(resourceId>0)
                        [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                }
            }
            else
            {
                //Declaring a panel downloaded after all placements are downloaded
                //NSLog(@"all resources loaded.");
                NSNumber* yesObj = [NSNumber numberWithBool:YES];
                [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                return;
            }

        }//end if
         */
               
    }//end if(resource!=nil)
}

#pragma mark ImageLoader functions.
-(void)imageDownloader:(ImageDownloader*)imageDownloader didLoadImage:(UIImage*)image{
    
    
    if (image){
        NSLog(@"Image downloaded successfully.");

    }
    
}

-(void)imageDownloader:(ImageDownloader *)imageDownloader didFailWithError:(NSError*)error{
    NSLog(@"Error in image downloaded.");
}

-(IBAction)comicsButtonCicked:(id)sender{
    //NSLog(@"comicsButtonCicked");
    if(!alertShown)
    {
        alertShown = YES;
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Lose changes?"
                                                          message:@"You will lose all changes."
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Confirm", nil];
        message.tag=backAlertView;
        [message show];
    }

    //[self dismissViewControllerAnimated:YES completion:nil];
}


@end
