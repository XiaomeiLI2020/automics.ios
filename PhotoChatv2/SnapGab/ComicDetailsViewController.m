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
@synthesize thumbnailScrollView;
@synthesize currentPage;


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
    
    
    //[panelsLoader submitRequestGetPanelsForGroup:1];
    
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
        [thumbnailScrollView layoutItems];
        
        currentPage = 0;        
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
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        NSLog(@"alignPage. page= %i", page);
        
        [self removeAllBubbles];
        [self removeAllResources];
        
        currentPage= page;
        NSLog(@"alignPage. currentPage= %i", currentPage);
        /*
         if(page>=[comicPanelList count])
         {
         page= [comicPanelList count] - 1;
         }
         */
        
        currentPanel = [comicPanelList objectAtIndex:currentPage];
        panelId = currentPanel.panelId;
        
        NSLog(@"alignPage. panelId= %i", panelId);
        [panelsLoader submitRequestGetPanelWithId:panelId];
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
        //NSLog(@"addPanelToPanelScrollViews. panel=%i, and comicPanelCounter=%i", panel.panelId, comicPanelCounter);
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
        
        CGRect rect1 = imageView.frame;
        rect1.size.height = panelScrollObjHeight;
        rect1.size.width = panelWidth;
        imageView.frame = rect1;
        imageView.tag = comicPanelCounter;
        //thumbnailView.tag = panel.panelId;	// tag our images for later use when we place them in serial fashion
        
        // add images to the thumbnail scrollview
        [panelScrollView addSubview:imageView];
        
        //NSLog(@"addPanelToPanelScrollViews. panel=%i, and comicPanelCounter=%i", panel.panelId, (comicPanelCounter));

        //Update comicPanelCounter
        comicPanelCounter++;
        
        //Download other panels in the comic list.
        if(comicPanelCounter < (numComicPanels))
        {
            Panel* panel = [comicPanelList objectAtIndex:comicPanelCounter];
            if(panel!=nil)
            {
                if(panel.panelId>0)
                    [panelsLoader submitRequestGetPanelWithId:panel.panelId];
            }
            
        }
        else
        {
            NSLog(@"no new panel added to the comic.");
            [self updateScrollViews];
        }
        

        
        //NSLog(@"addPanelToPanelScrollViews. After panel added, comicpanelCounter=%i and numComicPanel=%i",comicPanelCounter, numComicPanels);
        /*
        if(comicPanelCounter < (numComicPanels -1))
        {
            comicPanelCounter++;
            Panel* panel = [comicPanelList objectAtIndex:comicPanelCounter];
            if(panel!=nil)
            {
                NSLog(@"To be added. panelId=%i", panel.panelId);
                [panelsLoader submitRequestGetPanelWithId:panel.panelId];
                //panelScrollView.numItems++;
            }
        }
        else
        {
            [panelScrollView layoutItems];
        }
         */

    }//end if panel!=nil
    
}


-(void)addPanelToScrollViews:(Panel*)panel
{
    if(panel!=nil)
    {
        //NSLog(@"panel added to thumbnail scrollviews=%i, and panelCounter=%i", panel.panelId, panelCounter);
        
        UIImageView *thumbnailView = [[UIImageView alloc] init];
        [thumbnailView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
        
        CGRect rect1 = thumbnailView.frame;
        rect1.size.height = thumbnailScrollObjHeight;
        rect1.size.width = thumbnailWidth;
        thumbnailView.frame = rect1;
        thumbnailView.tag = panelCounter;	// tag our images for later use when we place them in serial fashion
        
        
        // add images to the thumbnail scrollview
        [thumbnailScrollView addSubview:thumbnailView];
    }
    
    panelCounter++;
}



#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error{
    
}


-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel{
    if (panel != nil)
    {
        //NSLog(@"After comic loaded, didLoadPanel.Panel downloaded.%i", panel.panelId);
        currentPanel = panel;
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
           
            if(numPlacements > 0)
            {
                //CGRect xywh = CGRectMake(placement.xOffset, placement.yOffset,200,200);
                //int resourceId = [panel.placements objectAtIndex:0];
                int resourceId = [[panel.placements objectAtIndex:placementCounter] resourceId];
                [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
            }//end for
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

        NSString* type = resource.type;
        
        //NSString* urlImageString = resource.imageURL;
        //NSLog(@"resource.imageURL=%@",resource.imageURL);
        CGRect resourceFrame;
        if([type isEqual:@"d"])
        {
            resourceFrame = CGRectMake(currentPlacement.xOffset, currentPlacement.yOffset, decoratorWidth, decoratorHeight);
        }
        if([type isEqual:@"f"])
        {
            resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
        }
        
        //ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andURL:urlImageString andType:type];
        ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andURL:resource.imageURL andType:resource.type andId:resource.resourceId];
        
        rv.userInteractionEnabled = NO;
        [self.view addSubview:rv];
        

        if(placementCounter<(numPlacements-1))
        {
            placementCounter++;
            int resourceId = [[placementList objectAtIndex:placementCounter] resourceId];
            //NSLog(@"next resourceId=%i", resourceId);
            [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
        }
        else
        {
            //NSLog(@"all resources loaded.");
            return;
        }
        
    }//end if
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
    
}

-(void)ComicLoader:(ComicLoader*)loader didLoadComics:(NSArray*)comics{
    
}

-(void)ComicLoader:(ComicLoader*)loader didLoadComic:(Comic*)comic
{
    NSLog(@"Comic Loaded.");
    if(comic!=nil)
    {
        comicPanelList = comic.panels;
        numComicPanels = [comic.panels count];
        panelScrollView.numItems = numComicPanels;
        
        comicPanelCounter = 0;
        
        //Download the first panel of the comic
        Panel* panel = [comic.panels objectAtIndex:comicPanelCounter];
        if(panel!=nil)
        {
            [panelsLoader submitRequestGetPanelWithId:panel.panelId];
        }

    }//end if comic!=nil
}



@end
