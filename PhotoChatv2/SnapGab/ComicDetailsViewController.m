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
    
    NSLog(@"viewDidLoad");
    
    [self initiateScrollViews];
    
    
    //[panelsLoader submitRequestGetPanelsForGroup:1];
    
    if(comicId>0)
    {
        [comicLoader submitRequestGetComicWithId:comicId];
    }
    

}




- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    
    
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
    NSLog(@"initiateDataset");
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
    
    // Add thumbnails scrollview
    CGRect thumbFrame = CGRectMake(thumbnailScrollXOrigin, thumbnailScrollYOrigin, thumbnailScrollObjWidth, thumbnailScrollObjHeight);
    CGSize thumbnailSize = CGSizeMake(thumbnailWidth, thumbnailHeight);
    thumbnailScrollView = [[MainScrollSelector alloc] initWithFrame:thumbFrame andItemSize:thumbnailSize];
    [self.view addSubview:thumbnailScrollView];
}




- (void)updateScrollViews
{
    
    if(numPanels>0) {
        
        // Add panels to the scrollview
        //[self addImagesForComic:comicId];
        //NSLog(@"panelScrollView layoutItems.numPanels=%i", numPanels);
        [panelScrollView layoutItems];
        [thumbnailScrollView layoutItems];
        //currentPage = numPanels;
        
        /*
         UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
         //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
         singleTap.cancelsTouchesInView = NO;
         [thumbnailScrollView addGestureRecognizer:singleTap];
         */

    }//end if(_numImages>0)
    
}//end updateScrollViews
/*
- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    // Determine the position of clicked thumbnail
    CGPoint touchPoint=[gesture locationInView:thumbnailScrollView];
    CGFloat pos = (CGFloat)touchPoint.x / thumbnailWidth;
    int page = round(ceilf(pos));
    //NSLog(@"singleTap. page= %i", page);
    
    //Remove bubbles and resources from the current view
    [self removeAllBubbles];
    [self removeAllResources];
    
}
*/

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
        
        if(page>=[comicPanelList count])
        {
            page= [comicPanelList count] - 1;
        }
        panelId = [[comicPanelList objectAtIndex:page] panelId];
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

-(void)addPanelsToComic:(Comic*)comic
{

    if(comic!=nil)
    {
        //if(comic.panels!=nil)
        {
            NSLog(@"addPanelsToComic.panels.count=%i", [comic.panels count]);
            for(Panel* panel in comic.panels)
            {
                if(panel!=nil)
                {
                    [panelsLoader submitRequestGetPanelWithId:panel.panelId];
                }
                //NSLog(@"panel.panelId=%i", panel.panelId);

            }
        }
    }

}

-(void)addPanelToPanelScrollViews:(Panel*)panel
{
    if(panel!=nil)
    {
        NSLog(@"addPanelToPanelScrollViews. panel=%i, and comicPanelCounter=%i", panel.panelId, comicPanelCounter);
        
        UIImageView *thumbnailView = [[UIImageView alloc] init];
        [thumbnailView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
        
        CGRect rect1 = thumbnailView.frame;
        rect1.size.height = panelScrollObjHeight;
        rect1.size.width = panelWidth;
        thumbnailView.frame = rect1;
        thumbnailView.tag = panel.panelId;	// tag our images for later use when we place them in serial fashion
        
        if(comicPanelCounter < (numComicPanels))
        {
            // add images to the thumbnail scrollview
            [panelScrollView addSubview:thumbnailView];
            comicPanelCounter++;
        }
        [panelScrollView layoutItems];
        
        NSLog(@"addPanelToPanelScrollViews. After panel added, comicpanelCounter=%i and numComicPanel=%i",comicPanelCounter, numComicPanels);
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


-(void)addImageToScrollViews:(UIImage*)image
{
    //NSLog(@"image added to scrollviews=%i, and panelCounter=%i", panelId, panelCounter);
    NSLog(@"image added to panel scrollview");
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setImageWithURL:[NSURL URLWithString:urlImageString]
              placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
    
    CGRect rect = imageView.frame;
    rect.size.height = panelScrollObjHeight;
    rect.size.width = panelScrollObjWidth;
    imageView.frame = rect;
    //imageView.tag = panelId;	// tag our images for later use when we place them in serial fashion
    
    imageView.tag = panelCounter;	// tag our images for later use when we place them in serial fashion
    
    // add images to the panel scrollview
    [panelScrollView addSubview:imageView];
    
}




#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error{
    
}

-(void)PanelLoader:(PanelLoader *)loader didLoadPanels:(NSArray*)panels{
    
    NSLog(@"didLoadPanels.numPanels=%i", numPanels);
    panelList = panels;
    numPanels = [panels count];
 
    //[self initiateScrollViews];
    
    if(numPanels>0)
    {
        for (Panel *panel in panels)
        {
            if (panel.photo.photoId > 0)
            {
                
                urlImageString = panel.photo.imageURL;
                
                [self addPanelToScrollViews:panel];
                
                /*
                ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:panel.imageURL];
                imageDownloader.delegate = self;
                if (imageDownloader.image != nil)
                {
                    NSLog(@"Image is not null");
                }
                 */
                
            }//end if
            
        }//end for
        
        //[thumbnailScrollView layoutItems];
        
    }//end if



}

-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel{
    if (panel != nil)
    {
        NSLog(@"After comic loaded, didLoadPanel.Panel downloaded.%i", panel.panelId);
        currentPanel = panel;
        panelId = panel.panelId;

        //urlImageString = panel.imageURL;

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
            NSLog(@"didLoadPanel.panel.panelId=%i has %i placements", panel.panelId, [panel.placements count]);
            
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
        

        [self addPanelToPanelScrollViews:panel];
        /*
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:panel.imageURL];
        imageDownloader.delegate = self;
        if (imageDownloader.image != nil)
        {
            NSLog(@"Image is not null");
        }
         */
 
        
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
    NSLog(@"Resource downloaded %i", placementCounter);
    
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
            NSLog(@"next resourceId=%i", resourceId);
            [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
        }
        else
        {
            NSLog(@"all resources loaded.");
            return;
        }
        
    }//end if
}

#pragma mark ImageLoader functions.
-(void)imageDownloader:(ImageDownloader*)imageDownloader didLoadImage:(UIImage*)image{
    

if (image){
        NSLog(@"Image downloaded successfully.");
        //NSLog(@"numPanels=%i", [self.panels count]);
        //NSLog(@"panelCounter=%i", panelCounter);
        //if(panelCounter<numPanels)
        {
            //Panel* panel = [self.panels objectAtIndex:panelCounter];
            //NSLog(@"currentPanel=self.panels[%i]=%i",panelCounter, panel.panelId);
            //panelId = panel.panelId;
            
            //Add image to scrollviews if it has not been already added to the scrollview.
            [self addImageToScrollViews:image];
            
            //panelCounter++;
            
        }
        //ResourceImageView* resourceImage = [[ResourceImageView alloc] initWithFrame:CGRectMake(0.0,40,320,320) image:image];
        //[panelScrollView addSubview:resourceImage];
        //[self.view addSubview:resourceImage];
    }

}

-(void)imageDownloader:(ImageDownloader *)imageDownloader didFailWithError:(NSError*)error{
    NSLog(@"Error in image downloaded.");
}



#pragma ComicLoader methods.

-(void)ComicLoader:(ComicLoader*)loader didFailWithError:(NSError*)error{
    
}

-(void)ComicLoader:(ComicLoader*)loader didLoadComics:(NSArray*)comics{
    
    //comicPanelList = comics;
    //numComics = [comics count];
    //NSLog(@"didLoadComics.numComics=%i", numComics);
    
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
        
        //[panelsLoader submitRequestGetPanelWithId:64];
        
        Panel* panel = [comic.panels objectAtIndex:comicPanelCounter];
        if(panel!=nil)
        {
            [panelsLoader submitRequestGetPanelWithId:panel.panelId];
        }

        /*
        //currentComic = comic;
        //[self addPanelsToComic:comic];
            //if(comic.panels!=nil)
            {
                //NSLog(@"addPanelsToComic.panels.count=%i", [comic.panels count]);
                for(Panel* panel in comic.panels)
                {
                    if(panel!=nil)
                    {
                        [panelsLoader submitRequestGetPanelWithId:panel.panelId];
                        //NSLog(@"panel.panelId=%i", panel.panelId);
                        //NSLog(@"panel.URL=%i", panel.imageURL);
                        break;
                    }
                    
                }
            }
         */
    }//end if comic!=nil
}



@end
