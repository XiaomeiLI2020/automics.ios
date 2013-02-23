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
#import "ResourceImageView.h"
#import "ImageDownloader.h"
#import "GUIConstant.h"

@interface PanelViewController ()

@end

@implementation PanelViewController

@synthesize panelScrollView;
@synthesize thumbnailScrollView;

@synthesize _groupName;
@synthesize currentPage;

int _numImages;
BOOL _bubblesAdded;
BOOL _resourcesAdded;


PanelLoader *panelsLoader;
PanelLoader *panelLoader;
NSString* urlImageString;
int panelId;

- (void)updateNumImages
{

    //NSLog(@"updateNumImages.numPanels=%i", numPanels);
    if(numPanels>0)
    {
        // place the panels in serial layout within the scrollview
        [panelScrollView layoutItems];
        
        currentPage = numPanels;
        
        //Scroll to the last added panel in the serial layout within the scrollview
        [panelScrollView scrollItemToVisible:(currentPage)];
        

        // place the thumbnail in serial layout within the scrollview
        [thumbnailScrollView layoutItems];
        //Scroll to the last added thumbnail in the serial layout within the scrollview
        [thumbnailScrollView scrollItemToVisible:(currentPage)];
        
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        singleTap.cancelsTouchesInView = NO;
        [thumbnailScrollView addGestureRecognizer:singleTap];
           
    }//end if(numPanels>0)
       
}//end updateNumImages

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
    
    // Scroll to the most rcently added panel in panel scrollview
    CGRect panelFrame = panelScrollView.frame;
    panelFrame.origin.x = panelScrollObjWidth * (page-1);
    //NSLog(@"panelframe.origin.x = %f", panelFrame.origin.x);
    panelFrame.origin.y = 0;
    [panelScrollView scrollRectToVisible:panelFrame animated:YES];
    
    //Add bubbles and resources to the new panel's view after scrolling
    [self addBubblesForPage:page-1];
    [self addResourcesForPage:page-1];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //NSLog(@"viewDidLoad");

    panelsLoader = [[PanelLoader alloc] init];
    panelsLoader.delegate = self;
    [panelsLoader submitRequestGetPanelsForGroup:1];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"viewDidAppear");
    [self updateNumImages];
    
    //self.panelScrollView.delegate=self;
    
    _bubblesAdded = NO;
    _resourcesAdded = NO;
    
    //Add bubbles and resources to a panel after scrolling
    [self addBubblesForPage:currentPage-1];
    [self addResourcesForPage:currentPage-1];
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

-(void)addBubblesForPage:(int)page
{
    //NSLog(@"addBubblesForPage._bubblesAdded.%d", _bubblesAdded);
    if(_bubblesAdded) return;
    
    _bubblesAdded = YES;
    
    NSString* urlBubbleString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/%d.bub",_groupName,
                                 page+1];
    //NSLog(@"urlBubbleString %@", urlBubbleString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlBubbleString]
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:50];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if(response)
    {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&parseError];
        
        for(NSDictionary* bubble in jsonObject)
        {
            
            NSString* category = [bubble objectForKey:@"c"];
            if([category isEqualToString:@"bubble"])
            {
                CGRect xywh = CGRectMake([[bubble objectForKey:@"x"] floatValue],
                                         [[bubble objectForKey:@"y"] floatValue],0,0);
                // [[bubble objectForKey:@"w"] floatValue],
                // [[bubble objectForKey:@"h"] floatValue]);
                NSString* text = [bubble objectForKey:@"t"];
                int styleId = [[bubble objectForKey:@"s"] intValue];
                
                SpeechBubbleView* sbv = [[SpeechBubbleView alloc] initWithFrame:xywh andText:text andStyle:styleId];
                sbv.userInteractionEnabled = NO;
                sbv.alpha = 0.0f;
                [self.view addSubview:sbv];
                [UIView transitionWithView:self.view
                                  duration:0.25
                                   options:UIViewAnimationOptionLayoutSubviews
                                animations:^ { sbv.alpha = 1.0f; }
                                completion:nil];
            }//end if category
            
        }//end for
    }//end if response
    
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

-(void)addResourcesForPage:(int)page
{
    
    if(_resourcesAdded) return;
    
    _resourcesAdded = YES;
    
    NSString* urlResourceString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/%d.bub",_groupName, page+1];
    //NSLog(@"urlResourceString %@", urlResourceString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlResourceString]
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if(response)
    {
        NSError *parseError = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&parseError];
        
        for(NSDictionary* resource in jsonObject)
        {
            
            NSString* category = [resource objectForKey:@"c"];
            if([category isEqualToString:@"resource"])
            {
                /*
                 CGRect xywh = CGRectMake([[resource objectForKey:@"x"] floatValue],
                 [[resource objectForKey:@"y"] floatValue],0,0);
                 */
                CGRect xywh = CGRectMake([[resource objectForKey:@"x"] floatValue],
                                         [[resource objectForKey:@"y"] floatValue],
                                         [[resource objectForKey:@"w"] floatValue],
                                         [[resource objectForKey:@"h"] floatValue]);

                int styleId = [[resource objectForKey:@"s"] intValue];
                
                ResourceView* sbv = [[ResourceView alloc] initWithFrame:xywh andStyle:styleId];
                //NSLog(@"sbv.frame.origin = (%f, %f)", sbv.frame.origin.x, sbv.frame.origin.y);
                //NSLog(@"sbv.frame.size = (%f, %f)", sbv.frame.size.width, sbv.frame.size.height);
                sbv.userInteractionEnabled = NO;
                sbv.alpha = 0.0f;
                [self.view addSubview:sbv];
                [UIView transitionWithView:self.view
                                  duration:0.25
                                   options:UIViewAnimationOptionLayoutSubviews
                                animations:^ { sbv.alpha = 1.0f; }
                                completion:nil];
            }//end if category
        }//end for
    }//end if
    
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
    //NSLog(@"alignRowInPhotoTableView.numPanels=%i", numPanels);
    if(numPanels>0)
    {
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        //NSLog(@"alignPage. page= %i", page);

        //Add bubbles and resources to a panel after scrolling
        [self addBubblesForPage:page];
        [self addResourcesForPage:page];
        
        currentPage = page+1;
        
        // Scroll to the current page's thumbnail in thumbnail scrollview
        [thumbnailScrollView scrollItemToVisible:(page+1)];
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
    [self updateNumImages];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    if([[segue identifier] isEqualToString:@"editPanel"])
    {

        
        NSLog(@"currentPage=%i", currentPage);
        if(currentPage==0)
        {
            currentPage=1;
        }
        Panel *panel = [self.panels objectAtIndex:(currentPage-1)];
        NSLog(@"panel.panelId=%i", panel.panelId);
        NSLog(@"panel.imageURL=%@", panel.imageURL);
        

        PanelEditViewController *pevc = (PanelEditViewController *)[segue destinationViewController];
        pevc.currentPage = currentPage;
        pevc._groupName = _groupName;
        pevc.url = [NSURL URLWithString:panel.imageURL];
        
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
                
                ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andStyle:sbv.styleId];
                new_sbv.userInteractionEnabled = YES;
                new_sbv.alpha = 0;
                [pevc.view addSubview:new_sbv];
            }
        }//end for
         
         
    }//end if
}

-(void)initiateScrollViews
{
    // Add panels scrollview
    CGRect panelFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
    CGSize panelSize = CGSizeMake(panelWidth, panelHeight);
    panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize andNumItems:numPanels];
    panelScrollView.delegate=self;
    [self.view addSubview:panelScrollView];
    
    // Add thumbnails scrollview
    CGRect thumbFrame = CGRectMake(thumbnailScrollXOrigin, thumbnailScrollYOrigin, thumbnailScrollObjWidth, thumbnailScrollObjHeight);
    CGSize thumbnailSize = CGSizeMake(thumbnailWidth, thumbnailHeight);
    thumbnailScrollView = [[MainScrollSelector alloc] initWithFrame:thumbFrame andItemSize:thumbnailSize andNumItems:numPanels];
    [self.view addSubview:thumbnailScrollView];
}


-(void)addImageToScrollViews:(UIImage*)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setImageWithURL:[NSURL URLWithString:urlImageString]
              placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
    
    CGRect rect = imageView.frame;
    rect.size.height = panelScrollObjHeight;
    rect.size.width = panelScrollObjWidth;
    imageView.frame = rect;
    imageView.tag = panelId;	// tag our images for later use when we place them in serial fashion
    
    // add images to the panel scrollview
    [panelScrollView addSubview:imageView];
    
    

    UIImageView *thumbnailView = [[UIImageView alloc] initWithImage:image];
    [thumbnailView setImageWithURL:[NSURL URLWithString:urlImageString]
                  placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
    
    CGRect rect1 = thumbnailView.frame;
    rect1.size.height = thumbnailScrollObjHeight;
    rect1.size.width = thumbnailWidth;
    thumbnailView.frame = rect1;
    thumbnailView.tag = panelId;	// tag our images for later use when we place them in serial fashion
    
    // add images to the thumbnail scrollview
    [thumbnailScrollView addSubview:thumbnailView];
}

#pragma mark PanelLoader functions.
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error{
    
}

-(void)PanelLoader:(PanelLoader *)loader didLoadPanels:(NSArray*)panels{
    
    //NSLog(@"didLoadPanels.numPanels=%i", numPanels);
    self.panels = panels;
    numPanels = [panels count];
    
    [self initiateScrollViews];

    
    for (Panel *panel in panels)
    {
        if (panel.imageURL != nil)
        {
            urlImageString = panel.imageURL;
            panelId = panel.panelId;
            //NSLog(@"panel.imageURL=%@",panel.imageURL);
            //NSLog(@"urlImageString=%@",urlImageString);
            ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:panel.imageURL];
            imageDownloader.delegate = self;
            if (imageDownloader.image != nil)
            {
                NSLog(@"Image is not null");
            }
        }//end if
        
        if (panel.annotations != nil)
        {
            NSLog(@"panel.annotations.count =%i",[panel.annotations count]);

        }//end if

    }//end for
}

-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel{
    NSLog(@"Panel downloaded");
}

-(void)imageDownloader:(ImageDownloader*)imageDownloader didLoadImage:(UIImage*)image{
    if (image){
        //NSLog(@"Image downloaded successfully.");
        //NSLog(@"urlImageString=%@",urlImageString);
        

        [self addImageToScrollViews:image];
        
        //ResourceImageView* resourceImage = [[ResourceImageView alloc] initWithFrame:CGRectMake(0.0,40,320,320) image:image];
        //[panelScrollView addSubview:resourceImage];
        //[self.view addSubview:resourceImage];
    }
}

-(void)imageDownloader:(ImageDownloader *)imageDownloader didFailWithError:(NSError*)error{
    NSLog(@"Error in image downloaded.");
}


@end

