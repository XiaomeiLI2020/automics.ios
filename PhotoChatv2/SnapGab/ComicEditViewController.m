//
//  ComicEditViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 13/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ComicEditViewController.h"
#import "ComicPosterViewController.h"
#import "UIImageView+WebCache.h"
#import "SpeechBubbleView.h"
#import "ResourceView.h"

#import "Comic.h"
#import "GUIConstant.h"

#import "ResourceImageView.h"
#import "ImageDownloader.h"
#import "Annotation.h"

@interface ComicEditViewController ()

@end

@implementation ComicEditViewController

@synthesize comicId;
@synthesize panelScrollView;
@synthesize thumbnailScrollView;
@synthesize currentPage;

@synthesize panelArray;

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
UILabel* clickLabel;



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



-(void)addLabel
{
    clickLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(0, 40, 320, 320)];
    clickLabel.textColor = [UIColor whiteColor];
    clickLabel.backgroundColor = [UIColor blackColor];
    //clickLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(36.0)];
    clickLabel.text = [NSString stringWithFormat: @"Click a thumbnail to add to the comic."];
    [self.view addSubview:clickLabel];
}

-(void)addNewPanelToComic:(int)page
{
    NSLog(@"add panel to comic. comicPanelCounter=%i", comicPanelCounter);
    Panel* panel = [panelList objectAtIndex:page];
    if(panel!=nil)
    {
        UIImage *image = [UIImage imageNamed:panel.photo.imageURL];
        
        //Add image to the imageview
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                  placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
        
        // setup imageview's frame to a height and width
        CGRect rect = imageView.frame;
        rect.size.height = panelScrollObjHeight;
        rect.size.width = panelScrollObjWidth;
        imageView.frame = rect;
        imageView.tag = [comicPanelList count];	// tag our images for later use when we place them in serial fashion
        
        // add image to the panel scrollview
        [panelScrollView addSubview:imageView];
        
        /*
        if([comicPanelList count]==0)
        {
            [clickLabel removeFromSuperview];
            [self.view addSubview:panelScrollView];
        }
        */
        
        //Add panel to the comic panelList
        comicPanelList = [self arrayByAddingObject:comicPanelList andObject:panel];
        
        //Update the panel index being highlighted in the comic
        currentPage = [comicPanelList count] - 1;
        
        //Update the number of items in comic scrollview
        panelScrollView.numItems = [comicPanelList count];
        
        //Display images in comic scrollview
        [panelScrollView layoutItems];
        
        //Scroll to the most recently added panel in the comicScrollView
        [panelScrollView scrollItemToVisible:currentPage];
        
        //Add bubbles and resources to the new panel's view
        //[panelsLoader submitRequestGetPanelWithId:panel.panelId];
        
        //comicPanelCounter++;

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
    
    //NSLog(@"singleTap. page= %i", page);
    //Remove bubbles and resources from the current view
    [self removeAllBubbles];
    [self removeAllResources];
    
    //remove clickLabel if there are panels in thumbnail scrollView
    if([comicPanelList count]>0)
    {
        [clickLabel removeFromSuperview];
    }
    //Add a panel to the comic
    [self addNewPanelToComic:page];
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
    
    [self initiateScrollViews];
    

    
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
    
    [panelsLoader submitRequestGetPanelsForGroup:1];
    /*
     [panelsLoader submitRequestGetPanelsForGroup:1];
     
     if(comicId>0)
     {
     [comicLoader submitRequestGetComicWithId:comicId];
     }
     */
    

    
    [self updateScrollViews];
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
        
        panelScrollView.numItems = numComicPanels;
        thumbnailScrollView.numItems = numPanels;
        
        [panelScrollView layoutItems];
        [thumbnailScrollView layoutItems];
        
        currentPage = 0;
        
        currentPanel= [comicPanelList objectAtIndex:currentPage];
        
         UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
         //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
         singleTap.cancelsTouchesInView = NO;
         [thumbnailScrollView addGestureRecognizer:singleTap];
        
    }//end if(numPanels>0)
    
}//end updateScrollViews

-(void)alignPageInPanelScrollView
{
    if(numComicPanels>0)
    {
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        //NSLog(@"alignPage. page= %i", page);
        
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

    if([[segue identifier] isEqualToString:@"editPost"])
    {
        if([comicPanelList count] >0)
        {
            
        ComicPosterViewController *cpvc = (ComicPosterViewController *)[segue destinationViewController];
        
        cpvc.comicContents = [[NSMutableArray alloc] init];
        
        NSUInteger i;
        for(i=0; i<[comicPanelList count]; i++)
        {
            int panelId = [[comicPanelList objectAtIndex:i] panelId];
            /*
            NSDictionary* panel =
            [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithInt:i],
                                                 [NSNumber numberWithInt:panelId],
                                                 nil]
                                        forKeys:
             [NSArray arrayWithObjects:@"placement",@"panel_id", nil]];
            */
             //[panelArray addObject:panel];
           [cpvc.comicContents addObject:[NSNumber numberWithInt:panelId]];
            //[cpvc.comicContents addObject:panel];
        }
        }//end if panelList count > 0

    } //end if

    
}


-(void)deletePanelConfirmed
{
    //Check if a panel is added to the comic
    if([comicPanelList count] >0)
    {
        //Get the identifier of current image in the comic
        NSLog(@"current page=%i", currentPage);
        int itemReplaced = 0;
        //int itemRemoved= currentPage-1;
        int itemRemoved = currentPage;
        //if(currentPage==0)
           // itemRemoved = currentPage;

        //int panelId = [[panelList objectAtIndex:itemRemoved] integerValue];
        
        NSLog(@"panelScrollView.subviews.count=%i", [panelScrollView.subviews count]);
        
        if([panelScrollView.subviews count]== 0)
        {
            for(int i=0; i<[comicPanelList count]; i++)
                comicPanelList = [self arrayByRemovingObject:comicPanelList andObjectIndex:i];
            
            [panelScrollView removeFromSuperview];
            [self removeAllBubbles];
            [self removeAllResources];
            [self addLabel];
        }
        else{
            
            //Iterate the images in the scrollview to find the current image
            for (UIView *subview in panelScrollView.subviews)
            {
                NSLog(@"subview.tag=%i", subview.tag);
                
                if([subview isKindOfClass:[UIImageView class]] && currentPage==subview.tag)
                {
                    //NSLog(@"subview.tag=%i", subview.tag);
                    //Remove image from the comic
                    [subview removeFromSuperview];
                    [self removeAllBubbles];
                    [self removeAllResources];
                    
                    //Remove the image identifier from the panelList
                    //[panelList removeObjectAtIndex:itemRemoved];
                    NSLog(@"comicPanelList before deletion=%i", [comicPanelList count]);
                    comicPanelList = [self arrayByRemovingObject:comicPanelList andObjectIndex:itemRemoved];
                    NSLog(@"comicPanelList after deletion=%i", [comicPanelList count]);
                    
                    //Update currentpage
                    if(currentPage>0)
                        currentPage--;
                    
                    //If all images deleted from the comic, add clickLabel
                    if([comicPanelList count]==0)
                    {
                        [panelScrollView removeFromSuperview];
                        [self removeAllBubbles];
                        [self removeAllResources];
                        [self addLabel];
                        //[self.view addSubview:clickLabel];
                        
                    }
                    //Otherwise highlight the next image in the comic
                    else
                    {
                        //If last panel was removed, replace it with the 2nd last panel
                        if(itemRemoved==[comicPanelList count])
                        {
                            itemReplaced=[comicPanelList count]-1;
                        }
                        else if(itemRemoved < [comicPanelList count])
                        {
                            itemReplaced = itemRemoved;
                        }
                        
                        NSLog(@"itemReplaced=%i", itemReplaced);
                        NSLog(@"itemReplaced. panelId=%i", [[comicPanelList objectAtIndex:itemReplaced] panelId]);
                        panelScrollView.numItems = [comicPanelList count];
                        numComicPanels = [comicPanelList count];
                        [panelScrollView layoutItems];
                        [panelScrollView scrollItemToVisible:(itemReplaced)];
                        //panelId = [[panelList objectAtIndex:itemReplaced] integerValue];
                        
                        
                        //[self addBubblesForPage:panelId-1];
                        //[self addResourcesForPage:panelId-1];
                    } //end else
                    
                    //break the loop
                    break;
                }//end if panelCounter>0
                
                
            }//end for

            
        }//end else
    
    }//end if comicPanelList>0
    
    
}//end deletePanelConfirmed

- (IBAction)deletePanel:(id)sender {
    if([comicPanelList count] >0)
    {
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Delete Image"
                                                          message:@"Delete image from the comic."
                                                         delegate:self
                                                cancelButtonTitle:@"Delete"
                                                otherButtonTitles:@"Cancel", nil];
        [message show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Delete"])
    {
        [self deletePanelConfirmed];
    }
    if([title isEqualToString:@"Cancel"])
    {
        return;
    }
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



-(void)addComicPanelToComicScrollView:(Panel*)panel
{
    if(panel!=nil)
    {
        NSLog(@"addPanelToComicScrollView.panel=%i, and imageView.tag=comicPanelCounter=%i", panel.panelId, comicPanelCounter);
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
        
        CGRect rect1 = imageView.frame;
        rect1.size.height = panelScrollObjHeight;
        rect1.size.width = panelWidth;
        imageView.frame = rect1;
        imageView.tag = comicPanelCounter;	// tag our images for later use when we place them in serial fashion
        //imageView.tag = panel.panelId;	// tag our images for later use when we place them in serial fashion
        // add images to the thumbnail scrollview
        [panelScrollView addSubview:imageView];
        
        //Download other panels in the comic list.
        comicPanelCounter++;
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
       
        
        //NSLog(@"addPanelToPanelScrollView.After panel added, comicpanelCounter=%i and numComicPanel=%i",comicPanelCounter, numComicPanels);

        
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
    
    if(panelCounter==numPanels)
            [self updateScrollViews];
}



-(void)addImageToPanelScrollView:(UIImage*)image
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
    
    NSLog(@"didLoadPanels.numPanels=%i", numPanels);
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
        NSLog(@"After comic loaded, didLoadPanel.Panel id downloaded.%i", panel.panelId);
        currentPanel = panel;
        panelId = panel.panelId;
        urlImageString = panel.photo.imageURL;
        //NSLog(@"Panel downloaded. urlImageString=%@", urlImageString);
        
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
        
        if(panel.placements!=nil)
        {
            //NSLog(@"didLoadPanel.panel.panelId=%i has %i placements", panel.panelId, [panel.placements count]);
            
            placementList = panel.placements;
            numPlacements = [panel.placements count];
            placementCounter = 0;
            
            if(numPlacements > 0)
            {
                int resourceId = [[panel.placements objectAtIndex:placementCounter] resourceId];
                
                [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                
            }//end for
            
            
        }//end if
        
        [self addComicPanelToComicScrollView:panel];
        //[self addPanelToPanelScrollViews:panel];
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
            [self addImageToPanelScrollView:image];
            
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
    NSLog(@"Comic failed to load.");
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
