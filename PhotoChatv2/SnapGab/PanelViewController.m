//
//  PanelViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 01/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "PanelEditViewController.h"
#import "PanelViewController.h"
#import "UIImageView+WebCache.h"
#import "SpeechBubbleView.h"
#import "ResourceView.h"
#import "PanelLoader.h"
#import "ResourceLoader.h"
#import "ResourceImageView.h"
#import "ImageDownloader.h"
#import "GUIConstant.h"
#import "Annotation.h"

@interface PanelViewController ()

@end

@implementation PanelViewController



@synthesize panelScrollView;
@synthesize thumbnailScrollView;

@synthesize _groupName;
@synthesize currentPage;
@synthesize currentPanel;
@synthesize currentPanelId;
@synthesize numPanels;

@synthesize panels;



BOOL _bubblesAdded;
BOOL _resourcesAdded;


PanelLoader *panelsLoader;
PanelLoader *panelLoader;
ResourceLoader *resourceLoader;

NSString* urlImageString;

int panelId;
int panelCounter;


int numPlacements;
int placementCounter;


Panel* currentPanel;
Placement* currentPlacement;

NSArray *panelList;
NSArray *resourceList;
NSArray *placementList;



- (void)updateScrollViews
{
    
    NSLog(@"updateScrollViews.numPanels=%i", numPanels);
    if(numPanels>0)
    {
        panelScrollView.numItems = numPanels;
        thumbnailScrollView.numItems = numPanels;
        
        
        panelScrollView.numItems = 5;
        thumbnailScrollView.numItems = 5;
        
        // place the panels in serial layout within the scrollview
        [panelScrollView layoutItems];
        
        // place the thumbnail in serial layout within the scrollview
        [thumbnailScrollView layoutItems];
        

        //currentPage = numPanels-1;
        currentPage = panelScrollView.numItems-1;
        currentPage = 0;
        
        NSLog(@"updateScrollViews.currentPage=%i", currentPage);
        //currentPanel = [[Panel alloc] init];
        //currentPanel = [self.panels objectAtIndex:([self.panels count]-1)];
        currentPanel = [self.panels objectAtIndex:(currentPage)];
        if(currentPanel!=nil)
            NSLog(@"updateScrollViews.currentPanel.panelId=%i", currentPanel.panelId);



        //Scroll to the last added panel in the serial layout within the scrollview
        [panelScrollView scrollItemToVisible:(currentPage)];
        
        //Scroll to the last added thumbnail in the serial layout within the scrollview
        [thumbnailScrollView scrollItemToVisible:(currentPage)];

        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        singleTap.cancelsTouchesInView = NO;
        [thumbnailScrollView addGestureRecognizer:singleTap];

        
    }//end if(numPanels>0)
    
}//end updateScrollViews


- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    
    //UIButton *clicked = (UIButton *) sender;
    //int styleId = clicked.tag;
    // Determine the position of clicked thumbnail
    CGPoint touchPoint=[gesture locationInView:thumbnailScrollView];
    CGFloat pos = (CGFloat)touchPoint.x / thumbnailWidth;
    //CGFloat pos = (CGFloat)self.thumbnailScrollView.contentOffset.x / thumbnailWidth;
    int page = round(ceilf(pos));
    NSLog(@"singleTap. touchPoint.x = %f", (CGFloat)touchPoint.x);
    NSLog(@"singleTap. page= %i", page);
    NSLog(@"singleTap. numPanels= %i", numPanels);
    
    //Remove bubbles and resources from the current view
    [self removeAllBubbles];
    [self removeAllResources];
    
    // Scroll to the most rcently added panel in panel scrollview
    CGRect panelFrame = panelScrollView.frame;
    panelFrame.origin.x = panelScrollObjWidth * (page - 1);
    //NSLog(@"panelframe.origin.x = %f", panelFrame.origin.x);
    panelFrame.origin.y = 0;
    [panelScrollView scrollRectToVisible:panelFrame animated:YES];
/*
    //Add bubbles and resources to the new panel's view after scrolling
    //if(page>=2)
    {
        currentPanel = [self.panels objectAtIndex:(page-1)];
    }
    //else
      //  currentPanel = [self.panels objectAtIndex:0];
    NSLog(@"singleTap. currentPanel.panelId= %i", currentPanel.panelId);
    
    [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
*/
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
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

    }
    return self;
}

-(void) initiateDataSet
{
    NSLog(@"initiateDataset");
    
    numPanels = 0;
    panelCounter = 0;
    
    numPlacements = 0;
    placementCounter = 0;
    
    panels = [[NSArray alloc] init];
    panelList = [[NSArray alloc] init];
    resourceList = [[NSArray alloc] init];
    placementList = [[NSArray alloc] init];
    
    currentPanel = [[Panel alloc] init];
    
    panelsLoader = [[PanelLoader alloc] init];
    panelsLoader.delegate = self;
    
    resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate = self;
    
    _bubblesAdded = NO;
    _resourcesAdded = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //NSLog(@"viewDidLoad");
    [self initiateDataSet];
    
    [self initiateScrollViews];
    
    [panelsLoader submitRequestGetPanelsForGroup:1];

    //[self updateScrollViews];
  
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    //[panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];

    [self loadPanelsToScrollViews];
   // [self updateScrollViews];
    

}

/*
-(void)viewWillAppear:(BOOL)animated
{
    
    NSLog(@"viewWillAppear");
    //[panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
    //[self updateScrollViews];
}
 */

-(void)initiateScrollViews
{
    NSLog(@"initiateScrollView.numPanels=%i", numPanels);
    // Add panels scrollview
    CGRect panelFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
    CGSize panelSize = CGSizeMake(panelWidth, panelHeight);
    //panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize andNumItems:numPanels];
    panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize];
    panelScrollView.delegate=self;
    [self.view addSubview:panelScrollView];
    
    // Add thumbnails scrollview
    CGRect thumbFrame = CGRectMake(thumbnailScrollXOrigin, thumbnailScrollYOrigin, thumbnailScrollObjWidth, thumbnailScrollObjHeight);
    CGSize thumbnailSize = CGSizeMake(thumbnailWidth, thumbnailHeight);
    //thumbnailScrollView = [[MainScrollSelector alloc] initWithFrame:thumbFrame andItemSize:thumbnailSize andNumItems:numPanels];
    thumbnailScrollView = [[MainScrollSelector alloc] initWithFrame:thumbFrame andItemSize:thumbnailSize];
    [self.view addSubview:thumbnailScrollView];
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
    NSLog(@"scrollViewWillBeginDragging");
    //Remove bubbles and resources from the panel when the scrolling starts
    [self removeAllBubbles];
    [self removeAllResources];
}

-(void)alignPageInPanelScrollView
{
    //NSLog(@"alignPageInPhotoTableView.numPanels=%i", numPanels);

    if(numPanels>0)
    {
        //NSLog(@"alignPage. numPanels= %i", numPanels);
        
        // Determine the position of clicked thumbnail
        //CGPoint touchPoint=[gesture locationInView:panelScrollView];
        //CGFloat pos = (CGFloat)touchPoint.x / panelWidth;
        
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        NSLog(@"alignPage. self.panelScrollView.contentOffset.x= %f", self.panelScrollView.contentOffset.x);
        NSLog(@"alignPage. page= %i", page);
        

        //Add bubbles and resources to a panel after scrolling
        if(page>=0)
        {
            currentPanel = [self.panels objectAtIndex:(page)];
            if(currentPanel!=nil)
            {
                NSLog(@"alignPage.currentPanel.panelId= %i", currentPanel.panelId);
                NSLog(@"alignPage.currentPanel.photo.imageURL= %@", currentPanel.photo.imageURL);
                //[self updateScrollViews];
                [panelsLoader submitRequestGetPanelWithId:currentPanel.panelId];
                
                /*
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
                        
                    }
                }
                
                if(currentPanel.placements!=nil)
                {
                    numPlacements = [currentPanel.placements count];
                    placementCounter = 0;
                    //for(Placement* placement in panel.placements)
                    if(numPlacements > 0)
                    {
                        //CGRect xywh = CGRectMake(placement.xOffset, placement.yOffset,200,200);
                        //int resourceId = [panel.placements objectAtIndex:0];
                        int resourceId = [[currentPanel.placements objectAtIndex:placementCounter] resourceId];
                        
                        [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
                        
                        
                    }//end if
                }//end if
                 */

            }

            
            currentPage = page;
            NSLog(@"alignPage. new currentPage= %i", currentPage);
            // Scroll to the current page's thumbnail in thumbnail scrollview
            [thumbnailScrollView scrollItemToVisible:(currentPage)];
        }
         

    }//end if _numImages>0
     
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndScrollingAnimation");
    [self alignPageInPanelScrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
    [self alignPageInPanelScrollView];
}


-(void)newImageNotification
{
    //NSLog(@"newImageNotification.");
    [self removeAllBubbles];
    [self removeAllResources];
    [panelsLoader submitRequestGetPanelsForGroup:1];
    //[self updateNumImages];
    [self updateScrollViews];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    if([[segue identifier] isEqualToString:@"editPanel"])
    {
        if(numPanels>0)
        {
            NSLog(@"editPanel.currentPage=%i", currentPage);
            /*
            if(currentPage==0)
            {
                currentPage=1;
            }
             */
            
            Panel *panel = [self.panels objectAtIndex:(currentPage)];
            NSLog(@"editPanel.panel.panelId=%i", panel.panelId);
            NSLog(@"panel.imageURL=%@", panel.photo.imageURL);
            
            
            PanelEditViewController *pevc = (PanelEditViewController *)[segue destinationViewController];
            
            pevc._groupName = _groupName;
            pevc.url = [NSURL URLWithString:panel.photo.imageURL];
            pevc.currentPanel = panel;
            
            for (UIView *subview in self.view.subviews)
            {
                //Add Speech Bubbles
                if([subview isMemberOfClass:[SpeechBubbleView class]])
                {
                    SpeechBubbleView* sbv =(SpeechBubbleView*)subview;
                    SpeechBubbleView *new_sbv = [[SpeechBubbleView alloc] initWithFrame:sbv.frame andText:sbv.textView.text andStyle:sbv.styleId];
                    new_sbv.userInteractionEnabled = YES;
                    new_sbv.alpha = 0;
                    [pevc.view addSubview:new_sbv];
                }
                
                //Add Resources
                if([subview isMemberOfClass:[ResourceView class]])
                {
                    ResourceView* sbv =(ResourceView*)subview;
                    
                    //ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andStyle:sbv.styleId];
                    ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andURL:sbv.urlImageString andType:sbv.type];
                    new_sbv.userInteractionEnabled = YES;
                    new_sbv.alpha = 0;
                    [pevc.view addSubview:new_sbv];
                }
            }//end for
            
        }//end if numPanels>0
    }//end if
}



-(void)addImageToScrollViews:(UIImage*)image
{
    NSLog(@"image added to scrollviews=%i, and panelCounter=%i, urlImage=%@", panelId, panelCounter, urlImageString);
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
    [self.panelScrollView addSubview:imageView];
    
    

    UIImageView *thumbnailView = [[UIImageView alloc] initWithImage:image];
    [thumbnailView setImageWithURL:[NSURL URLWithString:urlImageString]
                  placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
    
    CGRect rect1 = thumbnailView.frame;
    rect1.size.height = thumbnailScrollObjHeight;
    rect1.size.width = thumbnailWidth;
    thumbnailView.frame = rect1;
    thumbnailView.tag = panelCounter;	// tag our images for later use when we place them in serial fashion
    
    
    // add images to the thumbnail scrollview
    [self.thumbnailScrollView addSubview:thumbnailView];
    
    //panelCounter++;
}

-(void)addImageWithURLToScrollViews:(NSString*)imageURL
{
    NSLog(@"image added to scrollviews=%i, and panelCounter=%i, and imageURL=%@", panelId, panelCounter, imageURL);
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setImageWithURL:[NSURL URLWithString:imageURL]
              placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
    
    CGRect rect = imageView.frame;
    rect.size.height = panelScrollObjHeight;
    rect.size.width = panelScrollObjWidth;
    imageView.frame = rect;
    //imageView.tag = panelId;	// tag our images for later use when we place them in serial fashion
    
    imageView.tag = panelCounter;	// tag our images for later use when we place them in serial fashion
    
    // add images to the panel scrollview
    [panelScrollView addSubview:imageView];
    
    
    
    UIImageView *thumbnailView = [[UIImageView alloc] init];
    [thumbnailView setImageWithURL:[NSURL URLWithString:imageURL]
                  placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
    
    CGRect rect1 = thumbnailView.frame;
    rect1.size.height = thumbnailScrollObjHeight;
    rect1.size.width = thumbnailWidth;
    thumbnailView.frame = rect1;
    thumbnailView.tag = panelCounter;	// tag our images for later use when we place them in serial fashion
    
    
    // add images to the thumbnail scrollview
    [thumbnailScrollView addSubview:thumbnailView];
    
    //panelCounter++;
}

-(void)loadPanelsToScrollViews
{
    NSLog(@"loadPanelsToScrollViews. self.panels.count=%i", [self.panels count]);
    for (Panel *panel in self.panels)
    {
        if(panel!=nil)
        {
            
            if(panel.photo!=nil)
            {
                if (panel.photo.photoId > 0)
                {
                    //if(panel.panelId > 85)
                    //    break;
                    urlImageString = panel.photo.imageURL;

                            
                            urlImageString = panel.photo.imageURL;
                            //panelId = panel.panelId;
                            NSLog(@"loadPanelsToScrollViews.panel.panelId=%i and imageurl=%@",panel.panelId, urlImageString);
                            
                            /*
                            
                            UIImage *image = [UIImage imageNamed:resource.thumbURL];
                            
                            NSData *imageURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumb_url]];
                            image = [UIImage imageWithData:imageURL];
                            */
                            
                            //UIImage *image = [UIImage imageNamed:panel.photo.imageURL];
                            
                           
                            
                            
                            ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:panel.photo.imageURL];
                            imageDownloader.delegate = self;
                            if (imageDownloader.image != nil)
                            {
                                NSLog(@"Image is not null");
                            }
                        
                            //if(panel.panelId == 86)
                            //break;
                            //if(panelCounter<numPanels)
                            {
                                //panelId = panel.panelId;
                                
                                //Add image to scrollviews if it has not been already added to the scrollview.
                                //[self addImageWithURLToScrollViews:urlImageString];
                                

                                
                                
                                
                            }
                }
    
            }
        }
    
    }//end for
    
}

#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"Panel failed to load.");
    
}


-(void)PanelLoader:(PanelLoader *)loader didLoadPanels:(NSArray*)panelsLocal{
    

    panels= panelsLocal;
    numPanels = [panelsLocal count];
    
    NSLog(@"didLoadPanels.panels count=%i", [panels count]);
    //NSLog(@"didLoadPanels.numPanels=%i", [self.panels count]);
    
    //[self initiateScrollViews];

    //panelScrollView.numItems = numPanels;
    //thumbnailScrollView.numItems = numPanels;
    //panelScrollView.numItems = 2;
    //thumbnailScrollView.numItems = 2;
    /*
    for (Panel *panel in panels)
    {
        if(panel!=nil)
        {
            
            if(panel.photo!=nil)
            {
                if (panel.photo.photoId > 0)
                {
                    urlImageString = panel.photo.imageURL;
                    //panelId = panel.panelId;
                    //NSLog(@"panel.panelId=%i",panel.panelId);
                    NSLog(@"panel.photo.imageURL=%@",urlImageString);
                  
                    if(panelCounter<numPanels)
                    {
                        panelId = panel.panelId;
                        
                        //Add image to scrollviews if it has not been already added to the scrollview.
                        [self addImageWithURLToScrollViews:urlImageString];
                        panelCounter++;
                        
                    }
                    


                     
                
                }//end if
            }//end if panel.photo!=nil

            
        }//end if panel!=nil

        
    }//end for
*/


/*
 ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:panel.photo.imageURL];
 imageDownloader.delegate = self;
 if (imageDownloader.image != nil)
 {
 NSLog(@"Image is not null");
 }
 */

}

-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel{
    NSLog(@"Panel downloaded");
    
    if (panel != nil)
    {
        /*
        currentPanel = panel;
        panelId = panel.panelId;
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
        */
        
        /*
        if(panel.placements!=nil)
        {
            numPlacements = [panel.placements count];
            placementCounter = 0;
            //for(Placement* placement in panel.placements)
            if(numPlacements > 0)
            {
                //CGRect xywh = CGRectMake(placement.xOffset, placement.yOffset,200,200);
                //int resourceId = [panel.placements objectAtIndex:0];
                int resourceId = [[panel.placements objectAtIndex:placementCounter] resourceId];
                
                [resourceLoader submitRequestGetResourceWithResourceId:resourceId];


            }//end for
        }//end if
        */
        
       /*
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:panel.photo.imageURL];
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
    NSLog(@"resources loaded.");
}

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResource:(Resource*)resource
{
    NSLog(@"Resource downloaded");
    
    if (resource != nil)
    {
        NSString* type = resource.type;
        
        //NSString* urlImageString = resource.imageURL;
        //NSLog(@"urlImageString=%@",urlImageString);
        CGRect resourceFrame;
        if([type isEqual:@"d"])
        {
            resourceFrame = CGRectMake([[currentPanel.placements objectAtIndex:placementCounter] xOffset],
                                       [[currentPanel.placements objectAtIndex:placementCounter] yOffset],
                                       decoratorWidth, decoratorHeight);
        }
        if([type isEqual:@"f"])
        {
            resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
        }
        
        //ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andURL:urlImageString andType:type];
        ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andURL:resource.imageURL andType:resource.type andId:resource.resourceId];
        
        rv.userInteractionEnabled = NO;
        [self.view addSubview:rv];
        
      
        if(placementCounter < (numPlacements-1))
        {
            placementCounter++;
            int resourceId = [[currentPanel.placements objectAtIndex:placementCounter] resourceId];
            NSLog(@"resourceId #%i", resourceId);
            [resourceLoader submitRequestGetResourceWithResourceId:resourceId];
        }
      
        
    }//end if
}

#pragma mark ImageLoader functions.
-(void)imageDownloader:(ImageDownloader*)imageDownloader didLoadImage:(UIImage*)image{
    if (image){
        NSLog(@"Image downloaded successfully #%i", panelCounter);
        //NSLog(@"numPanels=%i", [self.panels count]);
        NSLog(@"panelCounter=%i", panelCounter);
        
        
        //if(panelCounter<numPanels)
        if(panelCounter<5)
        {
            Panel* panel = [self.panels objectAtIndex:panelCounter];
            //NSLog(@"currentPanel=self.panels[%i]=%i",panelCounter, panel.panelId);
            panelId = panel.panelId;

                NSLog(@"didloadImage. added to scrollViews.=%i with URL=%@", panelId, panel.photo.imageURL);

                    //UIImage *image = [UIImage imageNamed:panel.photo.imageURL];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                    [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                    
                    CGRect rect = imageView.frame;
                    rect.size.height = panelScrollObjHeight;
                    rect.size.width = panelScrollObjWidth;
                    imageView.frame = rect;
                    //imageView.tag = panelId;	// tag our images for later use when we place them in serial fashion
                    
                    imageView.tag = panelCounter;	// tag our images for later use when we place them in serial fashion
                    
                    // add images to the panel scrollview
                    [panelScrollView addSubview:imageView];
            
                
                    UIImageView *thumbnailView = [[UIImageView alloc] initWithImage:image];
                    [thumbnailView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
                    
                    CGRect rect1 = thumbnailView.frame;
                    rect1.size.height = thumbnailScrollObjHeight;
                    rect1.size.width = thumbnailWidth;
                    thumbnailView.frame = rect1;
                    thumbnailView.tag = panelCounter;	// tag our images for later use when we place them in serial fashion
                    
                    
                    // add images to the thumbnail scrollview
                    [thumbnailScrollView addSubview:thumbnailView];

            //Add image to scrollviews if it has not been already added to the scrollview.
            //[self addImageToScrollViews:image];
            panelCounter++;

            //[self updateScrollViews];
            //[self.panelScrollView layoutItems];
            /*
            if(panelCounter==numPanels)
            {
                //panelScrollView.numItems = 2;
                //thumbnailScrollView.numItems = 2;
                NSLog(@"Scrollviews updated. panelCounter=%i", panelCounter);
                [self.panelScrollView layoutItems];
                [self.thumbnailScrollView layoutItems];
            }
             */
        }
        else
        {
            NSLog(@"No new image added. Scrollviews updated. panelCounter=%i and panelScrollView.numItems=%i", panelCounter,
                  panelScrollView.numItems);
            [self updateScrollViews];
            
            /*
            panelScrollView.numItems = panelCounter;
            [panelScrollView layoutItems];
            
            thumbnailScrollView.numItems = panelCounter;
            [thumbnailScrollView layoutItems];
*/
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

