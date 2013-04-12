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

@interface ComicDetailsViewController ()

@end

@implementation ComicDetailsViewController

@synthesize comicId;
@synthesize panelScrollView;
@synthesize currentPage;
@synthesize activityIndicator;


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
Comic* currentComic;
Placement* currentPlacement;

NSArray *panelList;
NSArray *comicPanelList;
NSArray *resourceList;
NSArray *placementList;
NSMutableArray* downloadedPanels;

NSString* urlImageString;


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
        [self initiateDataSet];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //NSLog(@"viewDidLoad");
    
    [self initiateScrollViews];
    
    
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
	activityIndicator.center = self.view.center;
	[self.view addSubview: activityIndicator];
    [activityIndicator startAnimating];
    
    if(comicId>0)
    {
        [comicLoader submitRequestGetComicWithId:comicId];
    }
    

}




- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"viewDidAppear");
    
    
    _bubblesAdded = NO;
    _resourcesAdded = NO;
    
    /*
    [panelsLoader submitRequestGetPanelsForGroup:1];
    
    if(comicId>0)
    {
        [comicLoader submitRequestGetComicWithId:comicId];
    }
    */
    [self updateScrollViews];
}


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
}

-(void)initiateScrollViews
{
    //NSLog(@"initiateScrollView.numPanels=%i", numPanels);
    // Add panels scrollview
    CGRect panelFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
    CGSize panelSize = CGSizeMake(panelWidth, panelHeight);
    panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize];
    panelScrollView.delegate=self;
    [self.view addSubview:panelScrollView];
    
}


- (void)updateScrollViews
{
    
    if(numComicPanels>0) {
        
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


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewWillBeginDragging");
    //Remove bubbles and resources from the panel when the scrolling starts
    [self removeAllBubbles];
    [self removeAllResources];
}

-(void)alignPageInPanelScrollView
{
    if(numComicPanels>0)
    {
        [activityIndicator startAnimating];
        
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        //NSLog(@"alignPageInPanelScrollView. page= %i", page);
        
        [self removeAllBubbles];
        [self removeAllResources];
        
        currentPage= page;
        if(currentPage>=0 && currentPage<[comicPanelList count])
        {
            currentPanel = [comicPanelList objectAtIndex:currentPage];
            if(currentPanel!=nil)
            {
                
                panelId = currentPanel.panelId;
                if(panelId>0)
                {
                    //Check if the panel alongwith placements and annotations have already been downloaded
                    BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                    if(!panelDownloaded)
                    {
                        //Download annotations and placements of the panel
                        [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
                    }
                    else
                    {
                        UIImageView *imageView = [[UIImageView alloc] init];
                        [imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                        imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                        imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion
                        
                        [activityIndicator stopAnimating];
                        // add images to the panel scrollview
                        [panelScrollView addSubview:imageView];
                        //NSLog(@"annotations already downloaded are added.");
                        [self loadAnnotations:currentPanel];
                        //NSLog(@"placements already downloaded.");
                        [self loadPlacements:currentPanel];
                    }//end else
                }

            }//end if currentPanel!=null
            
           
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
            
            
        }
    
}


-(void)addComicPanelToComicScrollView:(Panel*)panel
{
    if(panel!=nil)
    {
        //NSLog(@"addComicPanelToPanelScrollViews. panel=%i, comicPanelCounter=%i, currentPage=%i", panel.panelId, comicPanelCounter, currentPage);
        
        //Check that a panel is not added twice
        //if(comicPanelCounter==0 || (currentPage>=comicPanelCounter))
        {
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
            imageView.frame = CGRectMake(currentPage*panelWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
            imageView.tag = currentPage;

            [activityIndicator stopAnimating];
            
            // add images to the thumbnail scrollview
            [panelScrollView addSubview:imageView];

            //Update comicPanelCounter
            comicPanelCounter++;
            
           // [self updateScrollViews];
        }
    }//end if panel!=nil
    
}


-(NSArray*)arrayByReplacingObject:(NSArray*)array andObjectIndex:(int)index andNewObject:(Panel*)panel
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray replaceObjectAtIndex:index withObject:panel];
    //[newArray addObject:object];
    return [NSArray arrayWithArray:newArray];
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


-(void)addResources:(Panel*)panel{
    
    if(panel!=nil)
    {
        currentPanel = panel;
        //Download placements
        if(panel.placements!=nil)
        {
            //NSLog(@"didLoadPanel.panel.panelId=%i has %i placements", panel.panelId, [panel.placements count]);
            
            placementList = panel.placements;
            numPlacements = [currentPanel.placements count];
            placementCounter = 0;
            
            
            //Load placements of a panel
            if(numPlacements>0)
            {
                if(placementCounter<numPlacements)
                {
                    currentPlacement = [currentPanel.placements objectAtIndex:placementCounter];
                    if(currentPlacement!=nil)
                    {
                        int resourceId = currentPlacement.resourceId;
                        [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                    }//end if
                }//end if
            }//end if
        }//end if
        
    }//end if
    
}

#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error{
    
}


-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel{
    if (panel != nil)
    {
        //NSLog(@"After comic loaded, didLoadPanel.Panel downloaded.%i", panel.panelId);
        currentPanel = panel;
        
        //Replace the panel in the panels array with the downloaded panel that contains annotations and placements
        comicPanelList = [self arrayByReplacingObject:comicPanelList andObjectIndex:currentPage andNewObject:currentPanel];
        
        panelId = panel.panelId;
        urlImageString = panel.photo.imageURL;
        //NSLog(@"Panel downloaded. urlImageString=%@", urlImageString);
        

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
        }

        
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
        }//end if
        
        [self addComicPanelToComicScrollView:panel];
        
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
            else
            {
                //Declaring a panel downloaded after all placements are downloaded
                NSNumber* yesObj = [NSNumber numberWithBool:YES];
                [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                return;
            }
            
        }//end if currentPanel.resources!=nil

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
    //NSLog(@"Comic Loaded.");
    if(comic!=nil)
    {
        comicPanelList = comic.panels;
        numComicPanels = [comic.panels count];
        panelScrollView.numItems = numComicPanels;
        
        comicPanelCounter = 0;
        
        if([comic.panels count]>0)
        {
            
            for (int i=0; i<numComicPanels;i++)
            {
                NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
                [downloadedPanels addObject:panelDownloaded];
            }
            
            //Download the first panel of the comic
            Panel* panel = [comic.panels objectAtIndex:comicPanelCounter];
            if(panel!=nil)
            {
                [panelsLoader submitRequestGetPanelWithId:panel.panelId];
            }
        }


    }//end if comic!=nil
}



@end
