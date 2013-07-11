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
#import "ThumbnailView.h"
#import "Comic.h"
#import "GUIConstant.h"
#import "ResourceImageView.h"
#import "ImageDownloader.h"
#import "Annotation.h"

@interface ComicEditViewController ()

@end

@implementation ComicEditViewController

@synthesize comicId;
@synthesize thumbPage;
@synthesize panelScrollView;
@synthesize thumbnailScrollView;
@synthesize currentPage;
@synthesize panelList;
@synthesize comicPanelList;
@synthesize panelArray;
@synthesize downloadedPanels;
@synthesize downloadedPhotos;
@synthesize postButton;
@synthesize activityIndicator;
@synthesize downloadedComicPanels;
@synthesize resourceList;
@synthesize placementList;
@synthesize lastContentOffsetX;
@synthesize comicName;
@synthesize comicPanelThumbnailIds;

BOOL _bubblesAdded;
BOOL _resourcesAdded;
BOOL _thumbnailsAdded;
BOOL thumbMode;
BOOL initialized;

int panelId;
int numPanels;
int panelCounter;
int numComicPanels;
int comicPanelCounter;
int numPlacements;
int placementCounter;
int thumbnailIndex;

PanelLoader* panelsLoader;
ComicLoader* comicLoader;
ResourceLoader* resourceLoader;

Panel* currentPanel;
Comic* currentComic;
Placement* currentPlacement;


NSString* urlImageString;
UILabel* clickLabel;

-(void) initiateDataSet
{
    //NSLog(@"initiateDataset");
    
    currentPage = 0;
    thumbPage = 0;
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
    downloadedComicPanels = [[NSMutableArray alloc] init];
    downloadedPhotos = [[NSMutableArray alloc] init];
    
    panelsLoader = [[PanelLoader alloc] init];
    panelsLoader.delegate = self;
    
    
    resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate = self;
    
    comicLoader = [[ComicLoader alloc] init];
    comicLoader.delegate = self;
    
    
    _bubblesAdded = NO;
    _resourcesAdded = NO;
    _thumbnailsAdded = NO;
    thumbMode = NO;
    initialized = NO;
    lastContentOffsetX = 0.0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self setComicTextField:nil];
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
    
    if(page<[downloadedPhotos count])
    {
        NSNumber* yesObj = [NSNumber numberWithBool:YES];
        [downloadedPhotos replaceObjectAtIndex:page withObject:yesObj];
    }

    //NSLog(@"singleTap. page= %i", page);
    //Remove bubbles and resources from the current view
    [self removeAllBubbles];
    [self removeAllResources];
    
    /*
    //remove clickLabel if there are panels in thumbnail scrollView
    if([comicPanelList count]==0)
    {
        [clickLabel removeFromSuperview];
    }
     */
    //Add a panel to the comic
    [self addNewPanelToComic:page];
}

-(void)didReceiveMemoryWarning{
    //NSLog(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

-(void)addNewPanelToComic:(int)page
{
    //NSLog(@"addNewPanelToComic. page= %i", page);
    if(page>=0 && page<[panelList count])
    {
        Panel* panel = [panelList objectAtIndex:page];
        if(panel!=nil)
        {
            if([comicPanelList count]==0)
            {
                if(postButton.enabled == NO)
                {
                    //NSLog(@"panelScrollView added.");
                    [clickLabel removeFromSuperview];
                    //[self.view addSubview:panelScrollView];
                    postButton.enabled = YES;
                }
            }
            
            //NSLog(@"addNewPanelToComic.panel.panelId=%i", panel.panelId);
            
            //Update the number of items in comic scrollview
            panelScrollView.numItems++;
            //Display images in comic scrollview
            [panelScrollView layoutItems];
            
            //Add panel to the comic panelList
            comicPanelList = [self arrayByAddingObject:comicPanelList andObject:panel];
            comicPanelThumbnailIds = [self arrayByAddingObject:comicPanelThumbnailIds andObject:[NSNumber numberWithInt:page]];
            
            //Add boolean object to the downloadedPanels panelList
            //NSNumber* noObj = [NSNumber numberWithBool:NO];
            //[downloadedPanels addObject:noObj];

            numComicPanels= [comicPanelList count];

            currentPanel = panel;
            
            //Update the panel index being highlighted in the comic
            currentPage = [comicPanelList count]-1;
            
            //Scroll to the most recently added panel in the comicScrollView
            [panelScrollView scrollItemToVisible:currentPage];
            
            if(panel.placements==nil && panel.annotations==nil)
                [panelsLoader submitRequestGetPanelWithId:panel.panelId];
            else
            {
                UIImageView *imageView = [[UIImageView alloc] init];
                [imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:nil];
                imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion
                
                // add images to the panel scrollview
                [panelScrollView addSubview:imageView];

                //NSLog(@"annotations already downloaded are added.");
                [self loadAnnotations:currentPanel];
                if(currentPanel.placements!=nil)
                {
                    if(currentPanel.resources!=nil)
                    {
                        if([currentPanel.placements count]==[currentPanel.resources count])
                        {
                            [self loadPlacements:currentPanel];
                        }//end if
                        
                    }//end if
                    else
                    {
                        [self addResources:currentPanel];
                    }
                    
                }//end if
            }//end else
        
            //comicPanelCounter++;
            
            if([comicPanelList count]==1)
            {
                [self alignPageInPanelScrollView];
            }
            
            if([comicPanelList count]>1)
            {
                [self displayPageInPanelScrollView:currentPage-1];
            }
        }//end if(panel!=nil)
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
    
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
	activityIndicator.center = self.view.center;
	[self.view addSubview: activityIndicator];
    [activityIndicator startAnimating];
    
    if(comicId>0)
    {
        [comicLoader submitRequestGetComicWithId:comicId];
    }
    if(comicName!=nil)
    {
        self.comicTextField.text = comicName;
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
    panelScrollView.tag=0;
    [self.view addSubview:panelScrollView];
    
    // Add thumbnails scrollview
    CGRect thumbFrame = CGRectMake(thumbnailScrollXOrigin, thumbnailScrollYOrigin, thumbnailScrollObjWidth, thumbnailScrollObjHeight);
    CGSize thumbnailSize = CGSizeMake(thumbnailWidth, thumbnailHeight);
    thumbnailScrollView = [[MainScrollSelector alloc] initWithFrame:thumbFrame andItemSize:thumbnailSize];
    thumbnailScrollView.tag=1;
    thumbnailScrollView.delegate=self;
    [self.view addSubview:thumbnailScrollView];
}

- (void)updateComicScrollViews
{
    if([comicPanelList count]>0)
    {
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


- (BOOL)textFieldShouldReturn:(UITextField*)theTextField {
    //NSLog(@"textFieldShouldReturn");
    if (theTextField == self.comicTextField) {
        [theTextField resignFirstResponder];
    }
    
    return YES;
}

-(void)alignPageInPanelScrollView
{
    thumbMode = NO;
    if([comicPanelList count]>0)
    {
        [activityIndicator startAnimating];
        
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        //NSLog(@"alignPage. page=%i, and panelScrollView.numItems=%i", page, panelScrollView.numItems);
        
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
                    int selectedThumbnailIndex = [[comicPanelThumbnailIds objectAtIndex:currentPage] intValue];
                    BOOL panelDownloaded = [[downloadedPanels objectAtIndex:selectedThumbnailIndex] boolValue];
                    //NSLog(@"alignPageInPanelScrollView.thumbMode=%d. Panel#%i downloaded=%d.", thumbMode, currentPage, panelDownloaded);
                   */

                    //Check if the panel alongwith placements and annotations have already been downloaded
                    if(currentPanel.placements==nil && currentPanel.annotations==nil)
                    {
                        //Download annotations and placements of the panel
                        [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
                    }
                    else
                    {
                        //NSLog(@"assets already downloaded");
                        
                        UIImageView *imageView = [[UIImageView alloc] init];
                        [imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL] placeholderImage:nil];
                        imageView.frame = CGRectMake(currentPage*panelScrollObjWidth, 0, panelScrollObjWidth, panelScrollObjHeight);
                        imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion
                        
                        // add images to the panel scrollview
                        [panelScrollView addSubview:imageView];
                        
                        [activityIndicator stopAnimating];
                        [self loadAnnotations:currentPanel];
                        if(currentPanel.placements!=nil)
                        {
                            if(currentPanel.resources!=nil)
                            {
                                if([currentPanel.placements count]==[currentPanel.resources count])
                                {
                                    [self loadPlacements:currentPanel];
                                }//end if
                                
                            }//end if
                            else
                            {
                                [self addResources:currentPanel];
                            }
                            
                        }//end if

                    }//end else
                    
                    
                }//end if panelId>0
            }//end if currentPanel!=nil

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

            
            //if([comicPanelList count]>3)
            {
                for(UIView* subView in panelScrollView.subviews)
                {
                    if(subView.tag!=currentPage && subView.tag!=currentPage+1 && subView.tag!=currentPage-1)
                    //    if(subView.tag!=currentPage)
                    {
                        [subView removeFromSuperview];
                    }
                }//end for
                
            }//end if([panels count]>3)
            
        }//end ifcurrentPage>=0
    }//end if _numImages>0
}

-(void)alignPageInPanelScrollView2
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
        
        //NSLog(@"alignPageInPanelScrollView.currentPage=%i", currentPage);
        
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
                //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
                //NSLog(@"alignPageInPanelScrollView.thumbMode=%d. Panel#%i downloaded=%d.", thumbMode, currentPage, panelDownloaded);
                //if(!panelDownloaded)
                if(currentPanel.annotations==nil && currentPanel.placements==nil)
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

-(void)alignPageInThumbnailScrollView
{
    thumbMode = YES;
    if(numPanels>0)
    {
        CGFloat pos = (CGFloat)self.thumbnailScrollView.contentOffset.x / thumbnailWidth;
        int page = round(ceilf(pos));
        //NSLog(@"alignPageInThumbnailScrollView.page=%i", page);
        
        if(lastContentOffsetX == self.thumbnailScrollView.contentOffset.x)
        {
            NSLog(@"ComicEditViewController.panels refreshed");
            //[panelsLoader submitRequestRefreshGetPanelsForGroup];
        }
        
        lastContentOffsetX = self.thumbnailScrollView.contentOffset.x;

        
        thumbPage = page;
        //Add bubbles and resources to a panel after scrolling
        if(page>=0 && page<[panelList count])
        {
            thumbnailIndex = thumbPage;
            [self generateThumbails];
        }//end if page>=0 && page<[self.panels count]
        
    }//end if _numImages>0
}

-(void)generateThumbails
{
    //thumbnailIndex = thumbPage;
    thumbMode = YES;
    //Load new panel after scrolling
    if(thumbnailIndex<[self.panelList count])
    {
        //NSLog(@"generateThumbnails. self.panels objectAtIndex:currentPage.currentPage=%i, [self.panels count]=%i", currentPage, [self.panelList count]);
        Panel* thumbnailPanel = [self.panelList objectAtIndex:(thumbnailIndex)];
        if(thumbnailPanel.placements==nil && thumbnailPanel.annotations==nil)
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
    /*
     for(UIView* subView in self.view.subviews)
     {
     if([subView isMemberOfClass:[ UIActivityIndicatorView class]])
     {
     UIActivityIndicatorView* aIndicator = (UIActivityIndicatorView*) subView;
     [aIndicator stopAnimating];
     //[subView stopAnimating];
     //[subView removeFromSuperview];
     }//end if
     }//end for
     */
    //NSLog(@"displayThumbails.thumbMode=%d, thumbPage=%i, thumbnailIndex=%i", thumbMode, thumbPage, thumbnailIndex);
    for(int index=thumbPage; index<thumbPage+4; index++)
    {
        if(index<[self.panelList count])
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
            
            //NSLog(@"displayThumbails. self.panels objectAtIndex:currentPage.currentPage=%i, index=%i, [self.panels count]=%i", currentPage, index, [self.panelList count]);
            Panel* thumbnailPanel = [self.panelList objectAtIndex:index];
            BOOL panelDownloaded = [[downloadedPanels objectAtIndex:index] boolValue];
            //NSLog(@"displayThumbnails. PanelIndex=%i is downloaded=%d has placements=%i", index, panelDownloaded, [thumbnailPanel.placements count]);
            if(thumbnailPanel!=nil && panelDownloaded)
            //if(thumbnailPanel!=nil)
            {
                //NSLog(@"displayThumbnails. PanelIndex=%i is downloaded=%d has placements=%i", index, panelDownloaded, [thumbnailPanel.placements count]);
               
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

    if([self.panelList count]>4)
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
    if(page>=0 && page<[self.panelList count])
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
            Panel* panel = [self.panelList objectAtIndex:page];
            //BOOL photoDownloaded = [[downloadedPhotos objectAtIndex:page] boolValue];
            //NSLog(@"displayPageInPanelScrollView.page=%i,currentPage=%i, panelId=%i, photoDownloaded=%d", page, currentPage, panel.panelId, photoDownloaded);
            if(panel!=nil)
            {
                UIImageView *imageView = [[UIImageView alloc] init];
                //if(!photoDownloaded)
                if(panel.placements==nil && panel.annotations==nil)
                    [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
                else
                    [imageView setImage:panel.thumbnail];
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
            
            //NSLog(@"loadPlacements.[currentPanel.resources count]=%i", [currentPanel.resources count]);
            //NSLog(@"loadPlacements.[currentPanel.placements count]=%i", [currentPanel.placements count]);
            
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
                        }//end if
                        if([type isEqual:@"f"])
                        {
                            resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                        }
                        
                        
                        ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andResource:resource andScale:defaultScale andAngle:defaultAngle];
                        rv.userInteractionEnabled = NO;
                        [self.view addSubview:rv];
                        
                    }//end if resource!=nil
                    else{
                        NSLog(@"resource is nil");
                    }
                     
                }//end for
            }//end if
            _resourcesAdded = YES;
         }//end  if(panel.placements!=nil)
         
    }//end if panel!=null
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

    if([[segue identifier] isEqualToString:@"editPost"])
    {
        NSLog(@"ComicEditViewController.segue.[comicPanelList count]=%i", [comicPanelList count]);
        if([comicPanelList count]>0)
        {
            ComicPosterViewController *cpvc = (ComicPosterViewController *)[segue destinationViewController];
            cpvc.comicContents = [[NSMutableArray alloc] init];
            comicName = self.comicTextField.text;
            cpvc.comicName = comicName;

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
                
                //int panelId = panel.panelId;
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
                        //[downloadedPanels removeObjectAtIndex:itemRemoved];
                        
                        if(currentPage>0)
                            currentPage--;
                        

                        if([comicPanelList count]==0)
                        {
                            //NSLog(@"post-deletion [comicPanelList count] %i", [comicPanelList count]);
                            //[panelScrollView removeFromSuperview];
                            
                            //[self removeAllBubbles];
                            //[self removeAllResources];
                            [self addLabel];
                            currentPage = 0;
                            postButton.enabled = NO;
                            
                        }
                        else if([comicPanelList count]>0)
                        {
                            //If last panel was removed
                            if(itemRemoved==[comicPanelList count])
                            {
                                itemReplaced=[comicPanelList count]-1;
                            }
                            else if(itemRemoved < [comicPanelList count])
                            {
                                itemReplaced = itemRemoved;
                            }
                            
                            //NSLog(@"itemReplaced %i", itemReplaced);
                            panelScrollView.numItems = [comicPanelList count];
                            //NSLog(@"panelScrollView.numItems %i", panelScrollView.numItems);
                            [panelScrollView layoutItems];
                            
                            /*
                            [panelScrollView scrollItemToVisible:(itemReplaced)];
                            
                          
                            currentPage = itemReplaced;
                            Panel* nextCurrentPanel = [comicPanelList objectAtIndex:itemReplaced];
                            if(nextCurrentPanel!=nil)
                            {
                                currentPanel = nextCurrentPanel;
                                //panelId = nextCurrentPanel.panelId;
                                
                                ///////
                                UIImageView *imageView = [[UIImageView alloc] init];
                                [imageView setImageWithURL:[NSURL URLWithString:currentPanel.photo.imageURL]
                                          placeholderImage:nil];
                                imageView.frame = CGRectMake(currentPage*panelScrollObjHeight, 0.0, panelScrollObjWidth, panelScrollObjHeight);
                                imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion
                                // add images to the thumbnail scrollview
                                [panelScrollView addSubview:imageView];
                                
                                [self loadAnnotations:currentPanel];
                                if(currentPanel.placements!=nil)
                                {
                                    if(currentPanel.resources!=nil)
                                    {
                                        if([currentPanel.placements count]==[currentPanel.resources count])
                                        {
                                            [self loadPlacements:currentPanel];
                                        }//end if
                                        
                                    }//end if
                                    else
                                    {
                                        [self addResources:currentPanel];
                                    }

                                }//end if

                                ////////////////////////////////////////
                                
                                //NSNumber* yesObj = [NSNumber numberWithBool:YES];
                                //[downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                                //[panelsLoader submitRequestGetPanelWithId:panelId];
                            }
                            
                            //NSLog(@"panelScrollView.numItems=%i", panelScrollView.numItems);
                        } //end else
                        
                        //NSLog(@"currentPage=%i", currentPage);
                             */
                        
                        }//end if comicPanelCounter>0
                        break;
                    }//end if([subview isKindOfClass:[UIImageView class]] && subview.tag==itemRemoved)
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
                }//end if
            [self alignPageInPanelScrollView];
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
        NSLog(@"addComicPanelToComicScrollView.panel=%i, currentPage=%i, imageView.tag=comicPanelCounter=%i, panel.photo.imageURL=%@", panel.panelId, currentPage, comicPanelCounter, panel.photo.imageURL);
        
        //if(currentPage>=0 && currentPage<[comicPanelList count])
        {
            //BOOL panelDownloaded = [[downloadedPanels objectAtIndex:currentPage] boolValue];
            //If panel not already downloaded, add it to the panelScrollView, and download placements and annotations
            //if(!panelDownloaded)
            {
                //UIImage* image = [UIImage imageNamed:panel.photo.imageURL];
                //UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                UIImageView *imageView = [[UIImageView alloc] init];
                [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                          placeholderImage:nil];
                imageView.frame = CGRectMake(currentPage*panelScrollObjHeight, 0.0, panelScrollObjWidth, panelScrollObjHeight);
                imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion
                
                [activityIndicator stopAnimating];
                // add images to the thumbnail scrollview
                [panelScrollView addSubview:imageView];
                
                //[self addResources:currentPanel];
                //[self addSpeechBubbles:currentPanel];
                
                //Keep track what panels has been downloaded and added to the panelscrollview
                //NSNumber* yesObj = [NSNumber numberWithBool:YES];
                //[downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                
            }
            
            //else
            {
                //[self loadAnnotations:currentPanel];
                //NSLog(@"addComicPanelToComicScrollView.placements already downloaded.");
                //[self loadPlacements:currentPanel];
                //[self addResources:currentPanel];
            }
            
            
            /*
            // After all comic panels downloaded and added to the comic scrollview
            //if(comicPanelCounter == (numComicPanels))
            if(!_thumbnailsAdded)
            {
                currentPanel = [comicPanelList objectAtIndex:currentPage];
                //Download panels for thumbnailviews
                [panelsLoader submitRequestGetPanelsForGroup:1];
                _thumbnailsAdded = YES;
            }
            */
            
        }//end if(currentPage>=0 && currentPage<[comicPanelList count])
        
          
    }//end if panel!=nil
    
    thumbMode = YES;
    //[panelsLoader submitRequestGetPanelsForGroup:1];
    [panelsLoader submitRequestGetPanelsForGroup];
    
}


-(void)addPanelToThumbnailScrollViews:(Panel*)panel
{
    if(panel!=nil)
    {
        //NSLog(@"panel added to thumbnail scrollviews=%i, and panelCounter=%i", panel.panelId, panelCounter);
        
        UIImageView *thumbnailView = [[UIImageView alloc] init];
        [thumbnailView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:nil];
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
              placeholderImage:nil];
    
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
    
    currentPanel = panel;

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
        if(currentPanel.placements!=nil)
        {
            //NSLog(@"didLoadPanel.panel.panelId=%i has %i placements", panel.panelId, [panel.placements count]);
            
            placementList = currentPanel.placements;
            numPlacements = [currentPanel.placements count];
            placementCounter = 0;
            currentPanel.resources = [[NSMutableArray alloc] init];

          
            //Load placements of a panel
            if(numPlacements>0)
            {
                currentPlacement = [currentPanel.placements objectAtIndex:placementCounter];
                if(currentPlacement!=nil)
                {
                    int resourceId = currentPlacement.resourceId;
                    [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                }

            }//end if
            else{
                //NSLog(@"all resources loaded.");
                //NSNumber* yesObj = [NSNumber numberWithBool:YES];
                //[downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
            }
        }//end if(currentPanel.placements!=nil)
    }//end if(panel!=nil)
    else{
        NSLog(@"panel is nil");
    }

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
    NSMutableArray *newPanels = [[NSMutableArray alloc] initWithArray:panelList];
    [newPanels addObjectsFromArray:panelsLocal];
    
    panelList = newPanels;
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


-(void)PanelLoader:(PanelLoader *)loader didLoadPanels:(NSArray*)panels{
    
    //NSLog(@"ComicEditView.didLoadPanels.");
    panelList = panels;
    numPanels = [panels count];
    if(numPanels>0)
    {
        thumbnailScrollView.numItems = numPanels;
        [thumbnailScrollView layoutItems];
        
        for (int i=0; i<numPanels;i++)
        {
            NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
            [downloadedPanels addObject:panelDownloaded];
            [downloadedPhotos addObject:panelDownloaded];
        }
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        singleTap.cancelsTouchesInView = NO;
        [thumbnailScrollView addGestureRecognizer:singleTap];
        
        [self alignPageInThumbnailScrollView];
    }//end if(numPanels>0)
}

//-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel forObject:(id)obj
-(void)PanelLoader:(PanelLoader*)loader didLoadPanel:(Panel*)panel
{
    if (panel!=nil)
    {
        int index=0;
        if(!thumbMode)
        {
            //NSLog(@"didLoadPanel called");
            currentPanel = panel;
            index = currentPage;
            
            //Replace the panel in the panels array with the downloaded panel that contains annotations and placements
            comicPanelList = [self arrayByReplacingObject:comicPanelList andObjectIndex:currentPage andNewObject:currentPanel];
            
            panelId = panel.panelId;
            urlImageString = panel.photo.imageURL;
            
            //Add image to panel scrollView
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:nil];
            imageView.frame = CGRectMake(currentPage*panelScrollObjHeight, 0.0, panelScrollObjWidth, panelScrollObjHeight);
            imageView.tag = currentPage;	// tag our images for later use when we place them in serial fashion
            
            [activityIndicator stopAnimating];
            // add images to the thumbnail scrollview
            [panelScrollView addSubview:imageView];
            
        }
        else if(thumbMode)
        {

            index = thumbnailIndex;
            panelList = [self arrayByReplacingObject:panelList andObjectIndex:index andNewObject:panel];
        }
        
        //Download speech bubbles
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
                    
                    
                    if(!initialized)
                    {
                        initialized = YES;
                        [self alignPageInPanelScrollView];
                        //[panelsLoader submitRequestGetPanelsForGroup:1];
                        [panelsLoader submitRequestGetPanelsForGroup];
                    }
                    
                    //NSLog(@"didLoadPanel. downloadedPanel turned YES. currentPage=%i", currentPage);
                    // Scroll to the current page's thumbnail in thumbnail scrollview
                    //[thumbnailScrollView scrollItemToVisible:(currentPage)];
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
                    
                }//end if thumbMode
            }//end else if(numPlacements==0)
        }//end if(panel.placements!=nil)
        
    }//end if panel!=nil
}

#pragma mark ResourceLoader functions.
-(void)ResourceLoader:(ResourceLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"resource failed to load.");
    
}

-(void)ResourceLoader:(ResourceLoader*)loader didLoadResources:(NSArray*)resources{
    //NSLog(@"Resources loaded.");
}

-(void)ResourceLoader:(ResourceLoader*)loader didLoadResource:(Resource*)resource
{
    //NSLog(@"didLoadResource.Resource downloaded %i", placementCounter);
    
    if(resource!=nil)
    {
        Panel* resourcePanel;
        if(!thumbMode)
        {
            resourcePanel = currentPanel;
        }
        else if(thumbMode)
        {
            //NSLog(@"didLoadResource. self.panels objectAtIndex called");
            if(thumbnailIndex<[self.panelList count])
                resourcePanel = [self.panelList objectAtIndex:thumbnailIndex];
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
                    
                    // Scroll to the current page's thumbnail in thumbnail scrollview
                    //[thumbnailScrollView scrollItemToVisible:(currentPage)];
                    
                
                    if(!initialized)
                    {
                        initialized = YES;
                        [self alignPageInPanelScrollView];
                        //[panelsLoader submitRequestGetPanelsForGroup:1];
                        [panelsLoader submitRequestGetPanelsForGroup];
                    }
                    
                }
                
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
                    else{
                        thumbMode = NO;
                        //NSLog(@"didLoadResource.displayThumbails called.");
                        [self displayThumbails];
                    }
                }//end if thumbMode
            }//end else if(placementCounter==(numPlacements-1))
            
        }//end if resourcePanel!=nil
        
        /*
        if(currentPanel.resources!=nil)
        {
            //Add resource to the panel object's resources array.
            //NSLog(@"added resource to to currentPanel.resources");
            [currentPanel.resources addObject:resource];
            
            NSString* type = resource.type;
            float scale = 1.0;
            float angle = 0.0;
            
            CGRect resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
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
                currentPlacement = [currentPanel.placements objectAtIndex:placementCounter];
                if(currentPlacement!=nil)
                {
                    int resourceId = currentPlacement.resourceId;
                    //NSLog(@"next resourceId=%i", resourceId);
                    [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                    
                }//end if(currentPlacement!=nil)
                
            }//end if(placementCounter<(numPlacements-1))
            else
            {
                //NSLog(@"all resources loaded.");
                NSNumber* yesObj = [NSNumber numberWithBool:YES];
                [downloadedPanels replaceObjectAtIndex:currentPage withObject:yesObj];
                return;
            }

        }
        else{
            NSLog(@"currentPanel.resources is nil");
        }
        */ 
        
         
    }//end if(resource!=nil)
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
        
        NSLog(@"ComicEditViewController.numComicPanels=%i", numComicPanels);
                
        if([comic.panels count]>0)
        {
            panelScrollView.numItems = [comicPanelList count];
            [panelScrollView layoutItems];
            
            /*
            for (int i=0;i<numComicPanels;i++)
            {
                NSNumber* panelDownloaded = [NSNumber numberWithBool:NO];
                [downloadedComicPanels addObject:panelDownloaded];
            }
            */
            
            
            //Download the first panel of the comic
            Panel* panel = [comic.panels objectAtIndex:0];
            if(panel!=nil)
            {
                [panelsLoader submitRequestGetPanelWithId:panel.panelId];
            }
             
        }//end if([comic.panels count]>0)
        
        //thumbMode = YES;
        //[panelsLoader submitRequestGetPanelsForGroup:1];
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
