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

NSString* urlImageString;
UILabel* clickLabel;
NSMutableArray* downloadedPanels;

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
}

-(void)addNewPanelToComic:(int)page
{
    //NSLog(@"addNewPanelToComic.currentPage=%i", currentPage);
    [activityIndicator startAnimating];
    
    Panel* panel = [panelList objectAtIndex:page];
    if(panel!=nil)
    {
        //Add panel to the comic panelList
        comicPanelList = [self arrayByAddingObject:comicPanelList andObject:panel];
        
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
                postButton.enabled = YES;
            }
            
        }
        
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
                  placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
        imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjWidth);
        imageView.tag = currentPage;
        
        [activityIndicator stopAnimating];
        // add image to the panel scrollview
        [panelScrollView addSubview:imageView];
        
        NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
        [downloadedPanels addObject:panelDownloaded];
        
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
    
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
	activityIndicator.center = self.view.center;
	[self.view addSubview: activityIndicator];
    
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
                    /*
                    if(currentPanel.annotations==nil && currentPanel.placements==nil)
                    {
                        [panelsLoader submitRequestGetPanelWithId:panelId];
                    }
                    else{
                        //NSLog(@"already loaded annotations and placements.");
                        [self addSpeechBubbles:currentPanel];
                        [self addResources:currentPanel];
                    }
                     */
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
                        
                        // add images to the panel scrollview
                        [panelScrollView addSubview:imageView];
                        
                        //NSLog(@"annotations already downloaded are added.");
                        [self loadAnnotations:currentPanel];
                        //NSLog(@"placements already downloaded.");
                        [self loadPlacements:currentPanel];
                    }//end else
                }//end if panelId>0
            }//end if currentPanel!=nil
            
            if([comicPanelList count]>3)
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
    //NSLog(@"alignPageInThumbnailScrollView.numPanels=%i", numPanels);
    if(numPanels>0)
    {
        //NSLog(@"alignPage. numPanels= %i", numPanels);
        
        CGFloat pos = (CGFloat)self.thumbnailScrollView.contentOffset.x / thumbnailWidth;
        int page = round(ceilf(pos));
        
        
        //NSLog(@"alignPageInThumbnailScrollView.page=%i", page);
        
        //Add bubbles and resources to a panel after scrolling
        if(page>=0 && page<[panelList count])
        {
            
            for(int index=page; index<page+4; index++)
            {
                //Load new panel after scrolling
                Panel* thumbnailPanel = [panelList objectAtIndex:(index)];
                if(thumbnailPanel!=nil)
                {
                    //NSLog(@"panel downloaded.");
                    //Add to panelscrollview
                    UIImageView *imageView = [[UIImageView alloc] init];
                    [imageView setImageWithURL:[NSURL URLWithString:thumbnailPanel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                    imageView.frame = CGRectMake(index*thumbnailWidth, 0, thumbnailWidth, thumbnailScrollObjHeight);
                    imageView.tag = index;
                    // add images to the thumbnail scrollview
                    [thumbnailScrollView addSubview:imageView];
                    
                }//end if
            }//end for
            
            if([panelList count]>4)
            {
                for(UIView* subView in thumbnailScrollView.subviews)
                {
                    if(subView.tag>page+3 || subView.tag<page)
                    {
                        [subView removeFromSuperview];
                    }
                }//end for
                
            }//end if([panels count]>3)
            
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
            //int panelId = [[comicPanelList objectAtIndex:itemRemoved] panelId];
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
                    [downloadedPanels removeObjectAtIndex:itemRemoved];
                    
                    if(currentPage>0)
                        currentPage--;
                    
                    //NSLog(@"[panelList count] after %i", [panelList count]);
                    if([comicPanelList count]==0)
                    {
                        //[panelScrollView removeFromSuperview];
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
                        
                        [self removeAllBubbles];
                        [self removeAllResources];
                        
                        //NSLog(@"itemReplaced %i", itemReplaced);
                        panelScrollView.numItems = [comicPanelList count];
                        [panelScrollView layoutItems];
                        [panelScrollView scrollItemToVisible:(itemReplaced)];
                        Panel* panel = [comicPanelList objectAtIndex:itemReplaced];
                        //panelId = panel.panelId;
                        
                        
                        [self loadAnnotations:panel];
                        [self loadPlacements:panel];
                        
                        //[panelsLoader submitRequestGetPanelWithId:panelId];
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
        //if(comicPanelCounter==0 || (currentPage >= comicPanelCounter))
        {
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
            imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
            imageView.tag = currentPage;
            // add images to the thumbnail scrollview
            [panelScrollView addSubview:imageView];
            
            NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
            [downloadedPanels addObject:panelDownloaded];
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
        //NSLog(@"After thumbnail clicked, didLoadPanel.Panel id downloaded.%i, currentPage=%i, [comicPanelList count]=%i", panel.panelId, currentPage, [comicPanelList count]);
        currentPanel = panel;
        
        
        //Replace the panel in the panels array with the downloaded panel that contains annotations and placements
        comicPanelList = [self arrayByReplacingObject:comicPanelList andObjectIndex:currentPage andNewObject:currentPanel];
        
        panelId = panel.panelId;
        urlImageString = panel.photo.imageURL;
        //NSLog(@"Panel downloaded. urlImageString=%@", urlImageString);

        //Download speech bubbles
        if(panel.annotations!=nil)
        {
            if([panel.annotations count]>0)
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
                panel.resources = [[NSMutableArray alloc] init];
                currentPlacement = [panel.placements objectAtIndex:placementCounter];
                if(currentPlacement!=nil)
                {
                    int resourceId = currentPlacement.resourceId;
                    if(resourceId>0)
                        [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                }
                
            }//end if
            else{
                
                NSNumber* yesObj = [NSNumber numberWithBool:YES];
                [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
            }//end else
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
