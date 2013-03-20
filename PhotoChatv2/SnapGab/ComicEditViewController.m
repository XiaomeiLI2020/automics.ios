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
@synthesize panelList;
@synthesize comicPanelList;
@synthesize panelArray;
@synthesize downloadedPanels;
@synthesize postButton;

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

NSArray *resourceList;
NSArray *placementList;

NSString* urlImageString;
UILabel* clickLabel;




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



-(void)addLabel
{
    clickLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(0, 40, 320, 320)];
    clickLabel.textColor = [UIColor whiteColor];
    clickLabel.backgroundColor = [UIColor blackColor];
    //clickLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(36.0)];
    clickLabel.text = [NSString stringWithFormat: @"Click a thumbnail to add to the comic."];
    [self.view addSubview:clickLabel];
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

-(void)addNewPanelToComic:(int)page
{
    if(page>=0 && page<[panelList count])
    {
        Panel* panel = [panelList objectAtIndex:page];
        if(panel!=nil)
        {
            if([comicPanelList count]==0)
            {
                [clickLabel removeFromSuperview];
                [self.view addSubview:panelScrollView];
                panelScrollView.numItems = 0;
                postButton.enabled = YES;
            }
            
            //NSLog(@"addNewPanelToComic.panel.panelId=%i", panel.panelId);
            
            //Update the number of items in comic scrollview
            panelScrollView.numItems++;
            //Display images in comic scrollview
            [panelScrollView layoutItems];
            
            
            //NSLog(@"addNewPanelToComic.panelScrollView.numItems=%i and [comicPanelList count]=%i", panelScrollView.numItems, [comicPanelList count]);


            //UIImage *image = [UIImage imageNamed:panel.photo.imageURL];
            //Add image to the imageview
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
            imageView.frame = CGRectMake(([comicPanelList count])*panelScrollObjWidth, 0.0, panelScrollObjWidth, panelScrollObjHeight);
            imageView.tag = [comicPanelList count];	// tag our images for later use when we place them in serial fashion
            
            // add image to the panel scrollview
            [panelScrollView addSubview:imageView];
 


            //Add panel to the comic panelList
            comicPanelList = [self arrayByAddingObject:comicPanelList andObject:panel];
            
            NSNumber* yesObj = [NSNumber numberWithBool:YES];
            [downloadedPanels addObject:yesObj];

           
            numComicPanels= [comicPanelList count];

            currentPanel = panel;
            
            //Update the panel index being highlighted in the comic
            currentPage = [comicPanelList count]-1;
            
            //Scroll to the most recently added panel in the comicScrollView
            [panelScrollView scrollItemToVisible:currentPage];
            
            //Add bubbles and resources to the new panel's view
            //[panelsLoader submitRequestGetPanelWithId:panel.panelId];
         
            //comicPanelCounter++;
            
        }
    }//end if page>=0
     
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


- (void)updateComicScrollViews
{
    if([comicPanelList count]>0) {
        
        panelScrollView.numItems = [comicPanelList count];
        [panelScrollView layoutItems];
        
    }//end if([comicPanelList count]>0)
    
    
}

- (void)updateThumbnailScrollViews
{
    if([panelList count]>0) {

        thumbnailScrollView.numItems = [panelList count];
        [thumbnailScrollView layoutItems];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        singleTap.cancelsTouchesInView = NO;
        [thumbnailScrollView addGestureRecognizer:singleTap];
        
    }//end if([panelList count]>0)
    
}


- (void)updateScrollViews
{
    [self updateThumbnailScrollViews];
    [self updateComicScrollViews];
    
}//end updateScrollViews

-(void)alignPageInPanelScrollView
{

    
    if([comicPanelList count]>0)
    {
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        //NSLog(@"alignPage.page=%i", page);
        
        [self removeAllBubbles];
        [self removeAllResources];
        
        currentPage= page;

        //NSLog(@"alignPage. currentPage=%i, and [comicPanelList count]=%i", currentPage, [comicPanelList count]);
        if(currentPage>=0 && currentPage<[comicPanelList count])
        {
            currentPanel = [comicPanelList objectAtIndex:currentPage];
            if(currentPanel!=nil)
            {
                panelId = currentPanel.panelId;
                if(panelId>0)
                {
                    [panelsLoader submitRequestGetPanelWithId:panelId];
                }

            }
        }
        
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
        NSLog(@"[comicPanelList count]=%i", [comicPanelList count]);
        if([comicPanelList count]>0)
        {
            ComicPosterViewController *cpvc = (ComicPosterViewController *)[segue destinationViewController];
            cpvc.comicContents = [[NSMutableArray alloc] init];
            
            NSUInteger i;
            for(i=0; i<[comicPanelList count]; i++)
            {
                Panel* panel = [comicPanelList objectAtIndex:i];
                if(panel!=nil)
                {
                    int panelId = panel.panelId;
                    if(panelId>0)
                        [cpvc.comicContents addObject:[NSNumber numberWithInt:panelId]];
                }
            }

        }//end if panelList count > 0

    } //end if
}


-(void)deletePanelConfirmed
{
    if([comicPanelList count] >0)
    {
        //NSLog(@"deletePanelConfirmed. numComicPanels=%i and currentPage=%i", [comicPanelList count],  currentPage);
        if(currentPage>=0 && currentPage<[comicPanelList count])
        {
            int itemReplaced = 0;
            int itemRemoved= currentPage;
            
            Panel* panel = [comicPanelList objectAtIndex:itemRemoved];
            if(panel!=nil)
            {
                
                int panelId = panel.panelId;
                //NSLog(@"deletePanelConfirmed. panelId= %i", panelId);
                
                for (UIView *subview in panelScrollView.subviews)
                {
                    //NSLog(@" deletePanelConfirmed. subview.tag=%i",  subview.tag);
                    if([subview isKindOfClass:[UIImageView class]] && subview.tag==itemRemoved)
                    {
                        //NSLog(@"comicScrollView.numItems before deletion %i", comicScrollView.numItems);
                        //NSLog(@"[panelList count] before %i", [panelList count]);
                        
                        [subview removeFromSuperview];
                        [self removeAllBubbles];
                        [self removeAllResources];

                        comicPanelList = [self arrayByRemovingObject:comicPanelList andObjectIndex:itemRemoved];
                        [downloadedPanels removeObjectAtIndex:itemRemoved];
                        
                        if(currentPage>0)
                            currentPage--;
                        
    
                        
                        if([comicPanelList count]==0)
                        {
                            //NSLog(@"post-deletion [comicPanelList count] %i", [comicPanelList count]);
                            [panelScrollView removeFromSuperview];
                            
                            [self removeAllBubbles];
                            [self removeAllResources];
                            [self addLabel];
                            currentPage = 0;
                            postButton.enabled = NO;
                            
                        }
                        else
                        {
                            if(itemRemoved==[comicPanelList count])
                            {
                                //itemReplaced=itemRemoved-1;
                                itemReplaced=[comicPanelList count]-1;
                            }
                            else if(itemRemoved < [comicPanelList count])
                            {
                                itemReplaced = itemRemoved;
                            }
                            
                            //NSLog(@"itemReplaced %i", itemReplaced);
                            panelScrollView.numItems = [comicPanelList count];
                            [panelScrollView layoutItems];
                            [panelScrollView scrollItemToVisible:(itemReplaced)];
                            
                            currentPage = itemReplaced;
                            Panel* nextCurrentPanel = [comicPanelList objectAtIndex:itemReplaced];
                            if(nextCurrentPanel!=nil)
                            {
                                currentPanel = nextCurrentPanel;
                                panelId = nextCurrentPanel.panelId;
                                [panelsLoader submitRequestGetPanelWithId:panelId];
                            }
                            
                            //NSLog(@"panelScrollView.numItems=%i", panelScrollView.numItems);
                        } //end else
                        
                        //NSLog(@"currentPage=%i", currentPage);
                        break;
                    }//end if comicPanelCounter>0
                    
                    
                }//end for
                
                comicPanelCounter = 0;
                //currentPage = 0;
                numComicPanels = [comicPanelList count];
                
              
                //Reassing the tags of images in the comic strip
                if([comicPanelList count]>0)
                {
                    for (UIView *subview in panelScrollView.subviews)
                    {
                        if([subview isKindOfClass:[UIImageView class]])
                        {
                            subview.tag = comicPanelCounter;
                            comicPanelCounter++;
                        }//end if
                    }//end for subviews
                    
                    /*
                    [downloadedPanels removeAllObjects];
                    for(int i=0; i<[comicPanelList count]; i++)
                    {
                        NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
                        [downloadedPanels addObject:panelDownloaded];
                    }//end for
                    */
                }//end if
                 

            }//end if panel!=nil
        } //end if currentPage < [comicPanelList count]
        
    }//end if [comicPanelList count] > 0
    
    
}



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


-(NSArray*)arrayByRemovingObject:(NSArray*)array andObjectIndex:(int)index
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray removeObjectAtIndex:index];
    return [NSArray arrayWithArray:newArray];
}

-(NSArray*)arrayByAddingObject:(NSArray*)array andObject:(id)object
{
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
    [newArray addObject:object];
    return [NSArray arrayWithArray:newArray];
}

-(void)addComicPanelToComicScrollView:(Panel*)panel
{
    if(panel!=nil)
    {
        //NSLog(@"addComicPanelToComicScrollView.panel=%i, currentPage=%i, imageView.tag=comicPanelCounter=%i, panel.photo.imageURL=%@", panel.panelId, currentPage, comicPanelCounter, panel.photo.imageURL);
        
        BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
        //If panel not already downloaded, add it to the panelScrollView, and download placements and annotations
        if(!panelDownloaded)
        {
            //UIImage* image = [UIImage imageNamed:panel.photo.imageURL];
            //UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
            imageView.frame = CGRectMake(currentPage*panelScrollObjHeight, 0.0, panelScrollObjWidth, panelScrollObjHeight);
            imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion
            // add images to the thumbnail scrollview
            [panelScrollView addSubview:imageView];

            [self addResources:currentPanel];
            [self addSpeechBubbles:currentPanel];
            
            //Keep track what panels has been downloaded and added to the panelscrollview
            NSNumber* yesObj = [NSNumber numberWithBool:YES];
            [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];

        }
        else
        {
            [self addResources:currentPanel];
            [self addSpeechBubbles:currentPanel];
        }
        
        // After all comic panels downloaded and added to the comic scrollview
        //if(comicPanelCounter == (numComicPanels))
        if(currentPage == 0)
        {
            currentPanel = [comicPanelList objectAtIndex:currentPage];
            //Download panels for thumbnailviews
            [panelsLoader submitRequestGetPanelsForGroup:1];
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
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
        thumbnailView.frame = CGRectMake(panelCounter*thumbnailWidth, 0, thumbnailWidth, thumbnailScrollObjHeight);
        thumbnailView.tag = panelCounter;	// tag our images for later use when we place them in serial fashion

        // add images to the thumbnail scrollview
        [thumbnailScrollView addSubview:thumbnailView];
    }
    
    panelCounter++;
    
    //All panels downloaded and added to thumbnail scrollviews
    /*
    if(panelCounter==numPanels)
    {
        //NSLog(@"addPanelToThumbnailScrollViews.updateScrollViews. thumbnail.subviews.count=%i", [[thumbnailScrollView subviews] count]);
        
        thumbnailScrollView.numItems = numPanels;
        [thumbnailScrollView layoutItems];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        singleTap.cancelsTouchesInView = NO;
        [thumbnailScrollView addGestureRecognizer:singleTap];

        [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
    }
     */
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
                currentPlacement = [placementList objectAtIndex:placementCounter];
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

#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"Panel failed to load.");
}

-(void)PanelLoader:(PanelLoader *)loader didLoadPanels:(NSArray*)panels{
    
    panelList = panels;
    numPanels = [panels count];
    
    thumbnailScrollView.numItems = numPanels;
    [thumbnailScrollView layoutItems];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
    singleTap.cancelsTouchesInView = NO;
    [thumbnailScrollView addGestureRecognizer:singleTap];
    
    
    //NSLog(@"didLoadPanels.numPanels=%i", numPanels);
    if(numPanels>0)
    {
        for (Panel *panel in panels)
        {
            if (panel.photo.photoId>0)
            {
                [self addPanelToThumbnailScrollViews:panel];
            }//end if
        }//end for
    }//end if
}

-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel{
    
    if (panel != nil)
    {
        currentPanel = panel;
        
        //Replace the panel in the panels array with the downloaded panel that contains annotations and placements
        comicPanelList = [self arrayByReplacingObject:comicPanelList andObjectIndex:currentPage andNewObject:currentPanel];
        
        [self addComicPanelToComicScrollView:panel];

    }//end if panel!=nil
    
}

#pragma mark ResourceLoader functions.
-(void)ResourceLoader:(ResourceLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"resource failed to load.");
    
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResources:(NSArray*)resources{
    //NSLog(@"Resources loaded.");
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResource:(Resource*)resource
{
    //NSLog(@"didLoadResource.Resource downloaded %i", placementCounter);
    
    if (resource != nil)
    {
        
        NSString* type = resource.type;
        float scale = 1.0;
        float angle = 0.0;
        
        CGRect resourceFrame;
        if([type isEqual:@"d"])
        {
            resourceFrame = CGRectMake(currentPlacement.xOffset, currentPlacement.yOffset, decoratorWidth, decoratorHeight);
            scale = currentPlacement.scale;
            angle= currentPlacement.angle;
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
            currentPlacement = [placementList objectAtIndex:placementCounter];
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

#pragma ComicLoader methods.

-(void)ComicLoader:(ComicLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"Comic failed to load.");
}


-(void)ComicLoader:(ComicLoader*)loader didLoadComic:(Comic*)comic
{
    //NSLog(@"ComicEditView.Comic Loaded.");
    if(comic!=nil)
    {
        comicPanelList = comic.panels;
        numComicPanels = [comic.panels count];
        panelScrollView.numItems = numComicPanels;
                
        if([comic.panels count]>0)
        {
            
            panelScrollView.numItems = [comicPanelList count];
            [panelScrollView layoutItems];
            
            //Initialize downloadedpanels array to BOOL NO
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
        }//end if([comic.panels count]>0)
    }//end if comic!=nil
}


#pragma mark ImageLoader functions.
-(void)imageDownloader:(ImageDownloader*)imageDownloader didLoadImage:(UIImage*)image{
    
    
    if (image){
        //NSLog(@"Image downloaded successfully.");
        //if(panelCounter<numPanels)
        {
            //NSLog(@"currentPanel=self.panels[%i]=%i",panelCounter, panel.panelId);
            //panelId = panel.panelId;
            
            //Add image to scrollviews if it has not been already added to the scrollview.
            [self addImageToPanelScrollView:image];
            
        }
        //ResourceImageView* resourceImage = [[ResourceImageView alloc] initWithFrame:CGRectMake(0.0,40,320,320) image:image];
        //[panelScrollView addSubview:resourceImage];
        //[self.view addSubview:resourceImage];
    }
    
}

-(void)imageDownloader:(ImageDownloader *)imageDownloader didFailWithError:(NSError*)error{
    NSLog(@"Error in image downloaded.");
}


@end
