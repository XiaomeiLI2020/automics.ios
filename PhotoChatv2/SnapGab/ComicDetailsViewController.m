//
//  ComicDetailsViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 16/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ComicDetailsViewController.h"
#import "ComicEditViewController.h"
#import "UIImageView+WebCache.h"
#import "SpeechBubbleView.h"
#import "ResourceView.h"
#import "Comic.h"
#import "GUIConstant.h"
#import "ResourceImageView.h"
#import "ImageDownloader.h"
#import "Annotation.h"
#import <QuartzCore/QuartzCore.h>

@interface ComicDetailsViewController ()

@end

@implementation ComicDetailsViewController

@synthesize comicId;
@synthesize panelScrollView;
@synthesize currentPage;
@synthesize activityIndicator;
@synthesize comicName;
@synthesize comicNameLabel;
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

PanelLoader* panelsLoader;
ComicLoader* comicLoader;
ResourceLoader* resourceLoader;

Panel* currentPanel;
Panel* peripheralPanel;
Comic* currentComic;
Placement* currentPlacement;

NSArray *panelList;
NSArray *comicPanelList;
NSArray *resourceList;
NSArray *placementList;
NSMutableArray* downloadedPanels;

NSString* urlImageString;
BOOL initialized;
BOOL peripheralMode;
int peripheralPage;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        /*
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        _groupName = [prefs objectForKey:@"groupname"];
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
        */ 
        //[self initiateDataSet];
        
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
    
    
    [comicNameLabel setFont:[UIFont fontWithName: @"Transit Display" size:28]];
    
    [self.backButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.backButton.layer.borderWidth=4.0f;
    self.backButton.clipsToBounds = YES;
    self.backButton.layer.cornerRadius = 10;//half of the width
    [self.backButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    self.backButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    [self initiateDataSet];
    [self initiateScrollViews];
    

    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
	activityIndicator.center = self.view.center;
    activityIndicator.hidesWhenStopped = YES;
	[self.view addSubview: activityIndicator];
    //[activityIndicator startAnimating];


    if(comicId>0)
    {
        //NSLog(@"ComicDetailViewController.comicId=%i", comicId);
        //self.comicNameLabel.text = @"Comic";
        [comicLoader submitRequestGetComicWithId:comicId];
    }

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //[activityIndicator startAnimating];
    //NSLog(@"ComicDetailsViewController. comicId=%i", comicId);
 
    /*
    if(comicId>0)
    {
        //NSLog(@"ComicDetailViewController.comicId=%i", comicId);
        //self.comicNameLabel.text = @"Comic";
        [comicLoader submitRequestGetComicWithId:comicId];
    }
    
  
    _bubblesAdded = NO;
    _resourcesAdded = NO;
    [self updateScrollViews];
*/
    
}

/*
- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"viewDidAppear");
    
    
    _bubblesAdded = NO;
    _resourcesAdded = NO;
    
    [self updateScrollViews];
}

*/

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
    
    panelList = [[NSArray alloc] init];
    comicPanelList = [[NSArray alloc] init];
    resourceList = [[NSArray alloc] init];
    placementList = [[NSArray alloc] init];
    downloadedPanels = [[NSMutableArray alloc] init];
    
    panelsLoader = [[PanelLoader alloc] init];
    panelsLoader.delegate = self;
    
    
    resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate = self;
    
    comicLoader = [[ComicLoader alloc] init];
    comicLoader.delegate = self;
    
    
    _bubblesAdded = NO;
    _resourcesAdded = NO;
    initialized = NO;
    peripheralMode = NO;
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

}


- (void)updateScrollViews
{
    
    if(numComicPanels>0)
    {
        panelScrollView.numItems = numComicPanels;
        [panelScrollView layoutItems];
        currentPanel= [comicPanelList objectAtIndex:currentPage];
    }//end if(numComicPanels>0)
    
}//end updateScrollViews


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

-(void)addBubblesForPanel:(Panel*)panel{
    
}

-(void)loadPlacements:(Panel*)panel
{
    //NSLog(@"loadPlacements.");
    if (panel !=nil)
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


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewWillBeginDragging");
    //Remove bubbles and resources from the panel when the scrolling starts
    [self removeAllBubbles];
    [self removeAllResources];
}

-(void)alignPageInPanelScrollView
{
    peripheralMode = NO;
    if(numComicPanels>0)
    {
        //[activityIndicator startAnimating];
        
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        //NSLog(@"alignPageInPanelScrollView. page= %i. peripheralMode=%d", page, peripheralMode);
        
        [self removeAllBubbles];
        [self removeAllResources];
        
        currentPage= page;

        if(currentPage>=0 && currentPage<[comicPanelList count])
        {
            currentPanel = [comicPanelList objectAtIndex:currentPage];
            if(currentPanel!=nil)
            {
                
                
                BOOL displayed= NO;
                //Check if the panel is already displayed in the panel scrollview
                for(UIView* subView in panelScrollView.subviews)
                {
                    if(subView.tag==currentPage && [subView isMemberOfClass:[UIImageView class]])
                    {
                        displayed=YES;
                        //[subView removeFromSuperview];
                        break;
                    }//end if
                }//end for
                //NSLog(@"alignPageinPanelScrollView.Panel#%i disPlayed=%d, subviews count=%i, numItems=%i", currentPage, displayed, [panelScrollView.subviews count], panelScrollView.numItems);
                

                panelId = currentPanel.panelId;
                if(panelId>0)
                {
                    if(!displayed)
                    {
                        //Check if the panel alongwith placements and annotations have already been downloaded
                        BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                        //NSLog(@"alignPageinPanelScrollView.Panel#%i panelDownloaded=%d", currentPage, panelDownloaded);
                        if(!panelDownloaded)
                        {
                            //Download annotations and placements of the panel
                            [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
                        }
                        else if(panelDownloaded)
                        {
                            [self addComicPanelToComicScrollView:currentPanel];
                            [self loadPlacements:currentPanel];
                            [self loadAnnotations:currentPanel];
                        }
                        
                    }//end if(!displayed)
                    else if(displayed)
                    {
                        
                        //[self addComicPanelToComicScrollView:currentPanel];
                        //NSLog(@"placements already downloaded.");
                        [self loadPlacements:currentPanel];
                        [self loadAnnotations:currentPanel];
                    }//end if(displayed)
                }//end if(panelId>0)
            }//end if currentPanel!=null
            
            
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
            

            if(numComicPanels>3)
            {
                for(UIView* subView in panelScrollView.subviews)
                {
                    if(subView.tag!=currentPage && subView.tag!=currentPage+1 && subView.tag!=currentPage-1)
                    //if(subView.tag!=currentPage)
                    {
                        [subView removeFromSuperview];
                    }
                }//end for
                
            }//end if([panels count]>3)

            
        }//end if currentPage>=0
    }//end if _numImages>0
}

-(void)displayPageInPanelScrollView:(int)page
{
    peripheralMode = YES;
    //NSLog(@"displayPageInPanelScrollView.page=%i, [panelScrollView.subviews count]=%i", page, [panelScrollView.subviews count]);
    if(page>=0 && page<[comicPanelList count])
    {
        peripheralPage = page;
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
            BOOL panelDownloaded = [[downloadedPanels objectAtIndex:page] boolValue];
            //NSLog(@"displayPageInPanelScrollView.panel#%i displayed=%d., panelDownloaded=%d", page, displayed, panelDownloaded);
            Panel* panel = [comicPanelList objectAtIndex:page];
            peripheralPanel = panel;
            
            if(!panelDownloaded)
            {
                //Download annotations and placements of the panel
                [panelsLoader submitRequestGetPanelWithId:peripheralPanel.panelId];
            }

            //NSLog(@"displayPageInPanelScrollView.objectAtIndex:page");
            //Panel* panel = [comicPanelList objectAtIndex:page];
            //NSLog(@"displayPageInPanelScrollView.page=%i,currentPage=%i, panelId=%i", page, currentPage, panel.panelId);
            else if(panelDownloaded)
            {
                if(peripheralPanel!=nil)
                {
                    UIImageView *imageView = [[UIImageView alloc] init];
                    //[imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
                    
                    NSFileManager* fileMgr = [NSFileManager defaultManager];
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
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
                             //NSLog(@"displayPageinPanelScrollView.saving image=%@ for panel[%i], currentPage=%i", imageName, currentPanel.panelId, currentPage);
                             NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                             [data1 writeToFile:currentFile atomically:YES];
                             
                         }];
                    }//end if(!fileExists)
                    else if(fileExists)
                    {
                        
                        //NSData *imgData = UIImagePNGRepresentation(image);
                        //NSLog(@"addComicPanelToComicScrollView.Size of Image%i (bytes):%d",currentPage, [imgData length]);
                        
                        unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:currentFile error:nil] fileSize];
                        
                        //Check if corrupt image is not downloaded. E.g size less than 640x640 (=409600) bytes
                        if(fileSize>=409600)
                        {
                            //NSLog(@"addComicPanelToComicScrollView.Loading image from corrupted file=%@", imageName);
                            UIImage* image = [UIImage imageWithContentsOfFile:currentFile];
                            [imageView setImage:image];
                        }//end if([imgData length]>409600)
                        else if(fileSize<409600)
                        {
                            //If corrupt image downloaded earlier, download full image from the server and save it locally
                            [imageView setImageWithURL:[NSURL URLWithString:[panel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                      placeholderImage:nil
                                             completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                             {
                                 //NSLog(@"addComicPanelToComicScrollView.saving image=%@ for panel[%i], currentPage=%i", imageName, currentPanel.panelId, currentPage);
                                 NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                 [data1 writeToFile:currentFile atomically:YES];
                                 
                             }];
                            
                        }//end else if([imgData length]<409600)
                        
                        
                        //NSLog(@"displayPageinPanelScrollView. Loading image from file=%@", imageName);
                        //[imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                        //[imageView setImage:[UIImage imageNamed:currentFile]];
                    }//end if(fileExists)

                    imageView.frame = CGRectMake(page*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                    imageView.tag = page;	// tag our images for later use when we place them in serial fashion
                    imageView.clipsToBounds= YES;
                    [imageView setContentMode:UIViewContentModeScaleAspectFill];
                    // add images to the panel scrollview
                    
                    //NSLog(@"displayPageinPanelScrollView. PanelScrollView addSubview. Panel#%i", page);
                    [panelScrollView addSubview:imageView];
                }//end if panel!=nil
                
            }//end if(panelDownloaded)

        }//end if(!displayed)
        else
        {
            //NSLog(@"displayPageInPanelScrollView.panel#%i already displayed.", page);
        }
        
    }//end if(page>=0 && page<[panels count])
}



-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndScrollingAnimation");
    [self alignPageInPanelScrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating");
    [self alignPageInPanelScrollView];
}


-(void)newImageNotification
{
    //NSLog(@"newImageNotification.");
    [self removeAllBubbles];
    [self removeAllResources];
    [self updateScrollViews];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
        if([[segue identifier] isEqualToString:@"detailToEdit"])
        {
            ComicEditViewController *cpvc = (ComicEditViewController *)[segue destinationViewController];
            cpvc.comicId = self.comicId;
            cpvc.comicName = comicName;
            //NSLog(@"ComicDetailView.comicName=%@", comicName);
        }//end if([[segue identifier] isEqualToString:@"detailToEdit"])
}


-(void)addComicPanelToComicScrollView:(Panel*)panel
{
    if(panel!=nil)
    {
        //NSLog(@"addComicPanelToPanelScrollViews. panel=%i, comicPanelCounter=%i, currentPage=%i", panel.panelId, comicPanelCounter, currentPage);
        
        BOOL displayed= NO;
        //Check if the panel is already displayed in the panel scrollview
        for(UIView* subView in panelScrollView.subviews)
        {
            if(subView.tag==currentPage && [subView isMemberOfClass:[UIImageView class]])
            {
                displayed=YES;
                //[subView removeFromSuperview];
                break;
            }//end if
        }//end for
        
        //Check that a panel is not added twice
        //if(comicPanelCounter==0 || (currentPage>=comicPanelCounter))
        if(!displayed)
        {
            UIImageView *imageView = [[UIImageView alloc] init];
            //[imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
            
            NSFileManager* fileMgr = [NSFileManager defaultManager];
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", panel.photo.photoId];
            NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
            BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
            
            //NSLog(@"addComicPanelToComicScrollView. Panel[%i].[%@] File exists=%d", panel.panelId, imageName, fileExists);
            if(!fileExists)
            {
                //[imageView setImageWithURL:[NSURL URLWithString:[panel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                
                [imageView setImageWithURL:[NSURL URLWithString:[panel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                          placeholderImage:nil
                                 completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                 {
                     //NSLog(@"addComicPanelToComicScrollView.saving image=%@ for panel[%i], currentPage=%i", imageName, currentPanel.panelId, currentPage);
                     NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                     [data1 writeToFile:currentFile atomically:YES];
                     
                 }];
            }//end if(!fileExists)
            else if(fileExists)
            {
                

                //NSData *imgData = UIImagePNGRepresentation(image);
                //NSLog(@"addComicPanelToComicScrollView.Size of Image%i (bytes):%d",currentPage, [imgData length]);
                
                unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:currentFile error:nil] fileSize];
                //Check if corrupt image is not downloaded. E.g size less than 640x640 (=409600) bytes
                if(fileSize>=409600)
                {
                    //NSLog(@"addComicPanelToComicScrollView.Loading image from corrupted file=%@", imageName);
                    UIImage* image = [UIImage imageWithContentsOfFile:currentFile];
                    [imageView setImage:image];
                }//end if([imgData length]>409600)
                else if(fileSize<409600)
                {
                    //If corrupt image downloaded earlier, download full image from the server and save it locally
                    [imageView setImageWithURL:[NSURL URLWithString:[panel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                              placeholderImage:nil
                                     completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                     {
                         //NSLog(@"addComicPanelToComicScrollView.saving image=%@ for panel[%i], currentPage=%i", imageName, currentPanel.panelId, currentPage);
                         NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                         [data1 writeToFile:currentFile atomically:YES];
                         
                     }];
                    
                }//end else if([imgData length]<409600)

                
                //NSLog(@"addComicPanelToComicScrollView. Loading image from file=%@", imageName);
                //[imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                //[imageView setImage:[UIImage imageNamed:currentFile]];
            }//end if(fileExists)

            
            imageView.frame = CGRectMake(currentPage*panelWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
            imageView.tag = currentPage;
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            imageView.clipsToBounds= YES;

            //[activityIndicator stopAnimating];
            
            //NSLog(@"panelScrollView addSubview. currentPage=%i", currentPage);
            // add images to the thumbnail scrollview
            [panelScrollView addSubview:imageView];
            
            if(!initialized)
            {
                initialized = YES;
                [self alignPageInPanelScrollView];
            }
            //[panelScrollView scrollItemToVisible:currentPage];

            //Update comicPanelCounter
            //comicPanelCounter++;
            
           // [self updateScrollViews];
        }//end if(!displayed)

    }//end if panel!=nil
    
}


-(NSArray*)arrayByReplacingObject:(NSArray*)array andObjectIndex:(int)index andNewObject:(Panel*)panel
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray replaceObjectAtIndex:index withObject:panel];
    //[newArray addObject:object];
    return [NSArray arrayWithArray:newArray];
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


#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error{
    
}

//-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel forObject:(id)obj
-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel*)panel
{
    if(panel!=nil)
    {
        if(!peripheralMode)
        {
            //NSLog(@"After comic loaded, didLoadPanel.Panel downloaded.%i", panel.panelId);
            currentPanel = panel;
            if(currentPage<[downloadedPanels count])
            {
                //Check if the panel alongwith placements and annotations have already been downloaded
                BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                //NSLog(@"ComicDetailsViewController. didLoadPanel.Panel#%i downloaded.%d, peripheralMode=%d", currentPage, panelDownloaded, peripheralMode);
                if(!panelDownloaded)
                {
                    
                    //Replace the panel in the panels array with the downloaded panel that contains annotations and placements
                    comicPanelList = [self arrayByReplacingObject:comicPanelList andObjectIndex:currentPage andNewObject:currentPanel];
                    
                    panelId = panel.panelId;
                    urlImageString = panel.photo.imageURL;
                    //NSLog(@"Panel downloaded. urlImageString=%@", urlImageString);
                    
                    if(panel.placements!=nil)
                    {
                        //NSLog(@"didLoadPanel.panel.panelId=%i has %i placements", panel.panelId, [panel.placements count]);
                        
                        placementList = panel.placements;
                        numPlacements = [panel.placements count];
                        placementCounter = 0;
                        panel.resources = [[NSMutableArray alloc] init];
                        
                        if(numPlacements>0)
                        {
                            if(placementCounter<numPlacements)
                            {
                                currentPlacement = [panel.placements objectAtIndex:placementCounter];
                                if(currentPlacement!=nil)
                                {
                                    int resourceId = currentPlacement.resourceId;
                                    [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                                }
                            }
                            
                        }//end if
                        else if(numPlacements==0)
                        {
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
                                }//end for
                            }//end if(panel.annotations!=nil)
                            
                            NSNumber* yesObj = [NSNumber numberWithBool:YES];
                            
                            //Check if the panel alongwith placements and annotations have already been downloaded
                            //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                            if(!panelDownloaded)
                                [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                            
                            /*
                             if(!initialized)
                             {
                             initialized = YES;
                             [self addComicPanelToComicScrollView:panel];
                             }
                             else{
                             //[self alignPageInPanelScrollView];
                             [panelScrollView scrollItemToVisible:currentPage];
                             }
                             */
                            //[panelScrollView scrollItemToVisible:currentPage];
                            [self addComicPanelToComicScrollView:panel];
                            
                            
                        }//end else if(numPlacements==0)
                    }//end if(panel.placements!=nil)
                    
                }//end if(!panelDownloaded)
            }//end if(currentPage<[downloadedPanels count])
            
        }//end if(!peripheralMode)

        else if(peripheralMode)
        {
            //NSLog(@"After comic loaded, didLoadPanel.Panel downloaded.%i", panel.panelId);
            peripheralPanel = panel;
            
            //Replace the panel in the panels array with the downloaded panel that contains annotations and placements
            comicPanelList = [self arrayByReplacingObject:comicPanelList andObjectIndex:peripheralPage andNewObject:peripheralPanel];
            
            if(peripheralPage<[downloadedPanels count])
            {
                //Check if the panel alongwith placements and annotations have already been downloaded
                BOOL panelDownloaded = [[downloadedPanels objectAtIndex:peripheralPage] boolValue];
                //NSLog(@"ComicDetailsViewController. didLoadPanel.Panel#%i downloaded.%d, peripheralMode=%d", peripheralPage, panelDownloaded, peripheralMode);

                BOOL displayed= NO;
                //Check if the panel is already displayed in the panel scrollview
                for(UIView* subView in panelScrollView.subviews)
                {
                    if(subView.tag==peripheralPage && [subView isMemberOfClass:[UIImageView class]])
                    {
                        displayed=YES;
                        //[subView removeFromSuperview];
                        break;
                    }//end if
                }//end for
                
                //Check that a panel is not added twice
                if(!displayed)
                {
                    UIImageView *imageView = [[UIImageView alloc] init];
                    NSFileManager* fileMgr = [NSFileManager defaultManager];
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
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
                             //NSLog(@"didloadPanel.saving image=%@ for panel[%i], currentPage=%i", imageName, currentPanel.panelId, currentPage);
                             NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                             [data1 writeToFile:currentFile atomically:YES];
                             
                         }];
                    }//end if(!fileExists)
                    else if(fileExists)
                    {

                        //NSData *imgData = UIImagePNGRepresentation(image);
                        //NSLog(@"didloadPanel.Size of Image%i (bytes):%d",currentPage, [imgData length]);
                        unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:currentFile error:nil] fileSize];
                        
                        //Check if corrupt image is not downloaded. E.g size less than 640x640 (=409600) bytes
                        if(fileSize>=409600)
                        {
                            //NSLog(@"ComicDetailsViewController. didloadPanel.Loading image from corrupted file=%@", imageName);
                            UIImage* image = [UIImage imageWithContentsOfFile:currentFile];
                            [imageView setImage:image];
                        }//end if([imgData length]>409600)
                        else if(fileSize<409600)
                        {
                            //If corrupt image downloaded earlier, download full image from the server and save it locally
                            [imageView setImageWithURL:[NSURL URLWithString:[panel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                      placeholderImage:nil
                                             completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                             {
                                 //NSLog(@"ComicDetailsViewController. didloadPanel.saving image=%@ for panel[%i], currentPage=%i", imageName, currentPanel.panelId, currentPage);
                                 NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                 [data1 writeToFile:currentFile atomically:YES];
                                 
                             }];
                            
                        }//end else if([imgData length]<409600)
                        
                        //NSLog(@"didLoadPanel. Loading image from file=%@", imageName);
                        //[imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
                        //[imageView setImage:[UIImage imageNamed:currentFile]];
                    }//end if(fileExists)
                    
                    imageView.frame = CGRectMake(peripheralPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                    imageView.tag = peripheralPage;	// tag our images for later use when we place them in serial fashion
                    imageView.clipsToBounds= YES;
                    [imageView setContentMode:UIViewContentModeScaleAspectFill];
                    // add images to the panel scrollview
                    
                    //NSLog(@"didLoadPanel. PanelScrollView addSubview. Panel#%i", peripheralPage);
                    [panelScrollView addSubview:imageView];
                    
                }//end if(!displayed)
                
                if(panel.placements!=nil)
                {
                    //NSLog(@"didLoadPanel.panel.panelId=%i has %i placements", panel.panelId, [panel.placements count]);
                    
                    placementList = panel.placements;
                    numPlacements = [panel.placements count];
                    placementCounter = 0;
                    panel.resources = [[NSMutableArray alloc] init];
                    
                    if(numPlacements>0)
                    {
                        if(placementCounter<numPlacements)
                        {
                            currentPlacement = [panel.placements objectAtIndex:placementCounter];
                            if(currentPlacement!=nil)
                            {
                                int resourceId = currentPlacement.resourceId;
                                [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                            }
                        }
                        
                    }//end if
                    else if(numPlacements==0)
                    {
                        
                        NSNumber* yesObj = [NSNumber numberWithBool:YES];
                        
                        //Check if the panel alongwith placements and annotations have already been downloaded
                        //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                        if(!panelDownloaded)
                            [downloadedPanels replaceObjectAtIndex:peripheralPage withObject:yesObj];
                        
                        //[self displayPageInPanelScrollView:peripheralPage];
                        //[self addComicPanelToComicScrollView:panel];
                        
                    }//end else if(numPlacements==0)
                }//end if(panel.placements!=nil)
                   
            }//end if(peripheralPage<[downloadedPanels count])
            
        }//end else if(peripheralMode)

                       
        //[self addComicPanelToComicScrollView:panel];
        
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
    
    if (resource != nil)
    {
        if(!peripheralMode)
        {
            if(currentPanel.resources!=nil)
            {
                //Add resource to the panel object's resources array.
                [currentPanel.resources addObject:resource];
                
                NSString* type = resource.type;
                float scale = 1.0;
                float angle = 0.0;
                
                //NSString* urlImageString = resource.imageURL;
                //NSLog(@"resource.imageURL=%@",resource.imageURL);
                CGRect resourceFrame= CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                if([type isEqual:@"d"])
                {
                    resourceFrame = CGRectMake(currentPlacement.xOffset, currentPlacement.yOffset, decoratorWidth, decoratorHeight);
                    scale = currentPlacement.scale;
                    angle = currentPlacement.angle;
                }
                if([type isEqual:@"f"])
                {
                    resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                }
                
                //ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andURL:urlImageString andType:type];
                //ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andURL:resource.imageURL andType:resource.type andId:resource.resourceId];
                
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
                        int resourceId = currentPlacement.resourceId;
                        [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                    }
                }
                else if(placementCounter==(numPlacements-1))
                {
                    //Declaring a panel downloaded after all placements are downloaded
                    NSNumber* yesObj = [NSNumber numberWithBool:YES];
                    if(currentPage<[downloadedPanels count])
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
                        }//end if(panel.annotations!=nil)
                        
                        //Check if the panel alongwith placements and annotations have already been downloaded
                        BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                        if(!panelDownloaded)
                            [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                        
                        //[panelScrollView scrollItemToVisible:(currentPage)];
                        [self addComicPanelToComicScrollView:currentPanel];
                    }
                    return;
                }
                
            }//end if currentPanel.resources!=nil

        }//end if(!peripheralMode)

        else if(peripheralMode)
        {
            if(peripheralPanel.resources!=nil)
            {
                //Add resource to the panel object's resources array.
                [peripheralPanel.resources addObject:resource];
                
                               
                
                if(placementCounter<(numPlacements-1))
                {
                    placementCounter++;
                    currentPlacement = [peripheralPanel.placements objectAtIndex:placementCounter];
                    if(currentPlacement!=nil)
                    {
                        int resourceId = currentPlacement.resourceId;
                        [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                    }
                }
                else if(placementCounter==(numPlacements-1))
                {
                    //Declaring a panel downloaded after all placements are downloaded
                    NSNumber* yesObj = [NSNumber numberWithBool:YES];
                    if(peripheralPage<[downloadedPanels count])
                    {
                        //Check if the panel alongwith placements and annotations have already been downloaded
                        BOOL panelDownloaded = [[downloadedPanels objectAtIndex:peripheralPage] boolValue];
                        if(!panelDownloaded)
                            [downloadedPanels replaceObjectAtIndex:peripheralPage withObject:yesObj];
                        
                        //[panelScrollView scrollItemToVisible:(currentPage)];
                        //[self addComicPanelToComicScrollView:peripheralPanel];
                    }
                    return;
                }
                
            }//end if currentPanel.resources!=nil
        }//end if(!peripheralMode)
         
        

    }//end if resource!=nil
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



#pragma ComicLoader methods.

-(void)ComicLoader:(ComicLoader*)loader didFailWithError:(NSError*)error{
    //NSLog(@"Comic failed to load.");
}

-(void)ComicLoader:(ComicLoader*)loader didLoadComic:(Comic*)comic
{
    //NSLog(@"ComicDetailsViewController. didLoadComic. comic.comicId=%i", comic.comicId);
    if(comic!=nil)
    {
        comicPanelList = comic.panels;
        numComicPanels = [comic.panels count];
        panelScrollView.numItems = numComicPanels;
        
        

       
        //NSLog(@"ComicDetailsViewController.numComicPanels=%i", numComicPanels);
        
        self.comicNameLabel.text = comic.name;
        self.comicNameLabel.numberOfLines = 0; //will wrap text in new line
        [self.comicNameLabel sizeToFit];
        
        //NSLog(@"didLoadComic.comic.name=%@", comic.name);
        
        comicPanelCounter = 0;
        
        if([comic.panels count]>0)
        {
            [self updateScrollViews];
            for (int i=0; i<numComicPanels;i++)
            {
                NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
                [downloadedPanels addObject:panelDownloaded];
            }
            
            //Download the first panel of the comic
            Panel* panel = [comic.panels objectAtIndex:0];
            if(panel!=nil && panel.panelId>0)
            {
                [panelsLoader submitRequestGetPanelWithId:panel.panelId];
            }
        }


    }//end if comic!=nil
}


-(IBAction)comicsButtonCicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
