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

@interface ComicAddViewController ()

@end

@implementation ComicAddViewController


@synthesize thumbnailScrollView;
@synthesize panelScrollView;
@synthesize _groupName;
@synthesize currentPage;
@synthesize postButton;

@synthesize panelArray;
@synthesize panelCounter;

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

    Panel* panel = [panelList objectAtIndex:page];
    if(panel!=nil)
    {
        //NSLog(@"add panel.panelId=%i to comic. comicPanelCounter=%i", panel.panelId, comicPanelCounter);
        
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
        //imageView.tag = panel.panelId;
        imageView.tag = comicPanelCounter;
        
        // add image to the panel scrollview
        [panelScrollView addSubview:imageView];
        
        //Add panel to the comic panelList
        comicPanelList = [self arrayByAddingObject:comicPanelList andObject:panel];
        
        numComicPanels= [comicPanelList count];
        
        if(numComicPanels>0)
        {
            [clickLabel removeFromSuperview];
            [self.view addSubview:panelScrollView];
            postButton.enabled = YES;
        }
        
        //Update the panel index being highlighted in the comic
        currentPage = [comicPanelList count] - 1;
        
        //Update the number of items in comic scrollview
        panelScrollView.numItems = [comicPanelList count];
        
        //Display images in comic scrollview
        [panelScrollView layoutItems];
        
        //Scroll to the most recently added panel in the comicScrollView
        [panelScrollView scrollItemToVisible:currentPage];
        
        //Add bubbles and resources to the new panel's view
        [panelsLoader submitRequestGetPanelWithId:panel.panelId];
        
        comicPanelCounter++;
        
    }
    
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
    
    if(numComicPanels==0)
    {
        [self addLabel];
        postButton.enabled = NO;
    }
    //Load panels in thumbnailscrollViews
    [panelsLoader submitRequestGetPanelsForGroup:1];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"viewDidAppear");
    
    
    _bubblesAdded = NO;
    _resourcesAdded = NO;

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
        
        //currentPage = 0;
        
        //currentPanel= [comicPanelList objectAtIndex:currentPage];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        singleTap.cancelsTouchesInView = NO;
        [thumbnailScrollView addGestureRecognizer:singleTap];
        
    }//end if(numPanels>0)
    
}//end updateScrollViews

-(void)alignPageInPanelScrollView
{
    
    if([comicPanelList count]>0)
    {
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        //NSLog(@"alignPage. page= %i", page);
        
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
                    if(currentPanel.annotations==nil && currentPanel.placements==nil)
                    {
                        [panelsLoader submitRequestGetPanelWithId:panelId];
                    }
                    else{
                        //NSLog(@"already loaded annotations and placements.");
                        [self addSpeechBubbles:currentPanel];
                        [self addResources:currentPanel];
                    }

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
    
    if([[segue identifier] isEqualToString:@"comicPosterView"])
    {
        if([panelList count] >0)
        {
            
            ComicPosterViewController *cpvc = (ComicPosterViewController *)[segue destinationViewController];
            
            cpvc.comicContents = [[NSMutableArray alloc] init];
            
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
        //NSLog(@"Button 1 was selected.");
        [self deletePanelConfirmed];
    }
    if([title isEqualToString:@"Cancel"])
    {
        //NSLog(@"Button 2 was selected.");
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
        
        if(currentPage < [comicPanelList count])
        {
            int panelId = [[comicPanelList objectAtIndex:itemRemoved] panelId];
            //NSLog(@"deletePanelConfirmed. panelId= %i", panelId);
            
            for (UIView *subview in panelScrollView.subviews)
            {
                //NSLog(@" deletePanelConfirmed. subview.tag=%i",  subview.tag);
                if([subview isKindOfClass:[UIImageView class]] && currentPage==subview.tag)
                {
                    //NSLog(@"comicScrollView.numItems before deletion %i", comicScrollView.numItems);
                    //NSLog(@"[panelList count] before %i", [panelList count]);
                    
                    [subview removeFromSuperview];
                    [self removeAllBubbles];
                    [self removeAllResources];
                    //[panelList removeObjectAtIndex:itemRemoved];
                    comicPanelList = [self arrayByRemovingObject:comicPanelList andObjectIndex:itemRemoved];
                    
                    if(currentPage>0)
                        currentPage--;
                    
                    //NSLog(@"[panelList count] after %i", [panelList count]);
                    if([comicPanelList count]==0)
                    {
                        [panelScrollView removeFromSuperview];
                        [self removeAllBubbles];
                        [self removeAllResources];
                        [self.view addSubview:clickLabel];
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
                        panelId = [[comicPanelList objectAtIndex:itemReplaced] panelId];
                        
                        [panelsLoader submitRequestGetPanelWithId:panelId];
                    } //end else
                    break;
                }//end if comicPanelCounter>0
                
                
            }//end for
            
            comicPanelCounter = 0;
            for (UIView *subview in panelScrollView.subviews)
            {
                if([subview isKindOfClass:[UIImageView class]])
                {
                    subview.tag = comicPanelCounter;
                    comicPanelCounter++;
                }//end if
            }//end for subviews 

            
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
        if(comicPanelCounter==0 || (currentPage >= comicPanelCounter))
        {
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
            
            CGRect rect1 = imageView.frame;
            rect1.size.height = panelScrollObjHeight;
            rect1.size.width = panelWidth;
            imageView.frame = rect1;
            imageView.tag = comicPanelCounter;
            //imageView.tag = panel.panelId;	// tag our images for later use when we place them in serial fashion
            
            // add images to the thumbnail scrollview
            [panelScrollView addSubview:imageView];
            
            //Update comicPanelCounter
            comicPanelCounter++;
            
            [self updateScrollViews];

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
    
}

-(void)PanelLoader:(PanelLoader *)loader didLoadPanels:(NSArray*)panels{
    
    //NSLog(@"didLoadPanels.numPanels=%i", numPanels);
    panelList = panels;
    numPanels = [panels count];
    
    if(numPanels>0)
    {
        for (Panel *panel in panels)
        {
            if (panel.photo.photoId > 0)
            {
                //urlImageString = panel.photo.imageURL;
                [self addPanelToThumbnailScrollViews:panel];
            }//end if
            
        }//end for
        
    }//end if
}

-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel{
    
    if (panel != nil)
    {
        //NSLog(@"After thumbnail clicked, didLoadPanel.Panel id downloaded.%i", panel.panelId);
        currentPanel = panel;
        
        //Replace the panel in the panels array with the downloaded panel that contains annotations and placements
        comicPanelList = [self arrayByReplacingObject:comicPanelList andObjectIndex:currentPage andNewObject:currentPanel];
        
        panelId = panel.panelId;
        urlImageString = panel.photo.imageURL;
        //NSLog(@"Panel downloaded. urlImageString=%@", urlImageString);
        
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
                    if(resourceId>0)
                        [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                }
                
            }//end for
        }//end if
        
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
        float scale = 1.0;
        float angle = 0.0;
        
        //NSString* urlImageString = resource.imageURL;
        //NSLog(@"resource.imageURL=%@",resource.imageURL);
        CGRect resourceFrame;
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
            currentPlacement = [placementList objectAtIndex:placementCounter];
            if(currentPlacement!=nil)
            {
                int resourceId=currentPlacement.resourceId;
                if(resourceId>0)
                    [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
            }
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



@end
