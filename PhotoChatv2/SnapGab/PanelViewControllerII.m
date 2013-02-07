//
//  PanelViewControllerII.m
//  PhotoChat
//
//  Created by Umar Rashid on 01/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "PanelEditViewControllerII.h"
#import "PanelViewControllerII.h"
#import "CameraViewController.h"
#import "UIImageView+WebCache.h"
#import "SpeechBubbleView.h"
#import "ResourceView.h"

@interface PanelViewControllerII ()

@end

@implementation PanelViewControllerII

@synthesize panelScrollView;
//@synthesize panelImage;
@synthesize thumbnailScrollView;
//@synthesize thumbnailImage;

NSString* _groupname;
int _numImages;
int currentPage;

const CGFloat panelScrollXOrigin= 0.0;
const CGFloat panelScrollYOrigin= 40.0;
const CGFloat panelScrollObjHeight= 360.0;
const CGFloat panelScrollObjWidth= 320.0;
const CGFloat panelWidth= 320.0;
const CGFloat panelHeight= 320.0;

const CGFloat thumbnailScrollXOrigin= 0.0;
const CGFloat thumbnailScrollYOrigin= 410.0;
const CGFloat thumbnailScrollObjHeight= 80.0;
const CGFloat thumbnailScrollObjWidth= 320.0;
const CGFloat thumbnailWidth= 80.0;
const CGFloat thumbnailHeight= 80.0;

- (void)updateNumImages
{
    
    //NSURLRequestReloadIgnoringLocalCacheData does not seem to work for 3G
    NSString* urlString = [NSString stringWithFormat:
                           @"http://www.automics.net/automics/userfiles/%@/last.txt?%d",_groupname,arc4random()];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if(!requestError) _numImages = [[[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding] intValue];
    
    
    //NSLog(@"updateImages. _numImages is %i", _numImages);
    
    if(_numImages>0) {
        
        // Add panels to the scrollview
        CGRect panelFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, panelScrollObjWidth, panelScrollObjHeight);
        CGSize panelSize = CGSizeMake(panelWidth, panelHeight);
        panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize andNumItems:_numImages];
        [self.view addSubview:panelScrollView];
        
        // Add thumbnails to the scrollview
        CGRect thumbFrame = CGRectMake(thumbnailScrollXOrigin, thumbnailScrollYOrigin, thumbnailScrollObjWidth, thumbnailScrollObjHeight);
        CGSize thumbnailSize = CGSizeMake(thumbnailWidth, thumbnailHeight);
        thumbnailScrollView = [[MainScrollSelector alloc] initWithFrame:thumbFrame andItemSize:thumbnailSize  andNumItems:_numImages];
        [self.view addSubview:thumbnailScrollView];
        
        // load all the images from our bundle and add them to the scroll views
        NSUInteger i;
        for (i=1; i <=_numImages; i++)
        {
            
            NSString* urlImageString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/thumbs/%d.jpg",_groupname, i];
            

            //NSLog(@"updateImages. urlImageString %@", urlImageString);
            //NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlImageString]];
            //UIImage* image = [[UIImage alloc] initWithData:imageData];
            //UIImageView *imageView = [UIImageView alloc];
            //[imageView setImage:image];
            UIImage *image = [UIImage imageNamed:urlImageString];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [imageView setImageWithURL:[NSURL URLWithString:urlImageString]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];


            
            // setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
            CGRect rect = imageView.frame;
            rect.size.height = panelScrollObjHeight;
            rect.size.width = panelScrollObjWidth;
            imageView.frame = rect;
            imageView.tag = i;	// tag our images for later use when we place them in serial fashion
            
            // add images to the panel scrollview
            [panelScrollView addSubview:imageView];

            // UIImageView *thumbnailView = [UIImageView alloc];
            //[thumbnailView setImage:image];
            UIImageView *thumbnailView = [[UIImageView alloc] initWithImage:image];
            [thumbnailView setImageWithURL:[NSURL URLWithString:urlImageString]
                          placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
            
            CGRect rect1 = thumbnailView.frame;
            rect1.size.height = thumbnailScrollObjHeight;
            //rect1.size.width = thumbnailScrollObjWidth;
            rect1.size.width = thumbnailWidth;
            thumbnailView.frame = rect1;
            thumbnailView.tag = i;	// tag our images for later use when we place them in serial fashion
            
            // add images to the thumbnail scrollview
            [thumbnailScrollView addSubview:thumbnailView];

        }//end for
        
        // place the panels in serial layout within the scrollview
        [panelScrollView layoutItems];
        //Scroll to the last added panel in the serial layout within the scrollview
        [panelScrollView scrollItemToVisible:(_numImages)];
        
       
        // place the thumbnail in serial layout within the scrollview
        [thumbnailScrollView layoutItems];
        //Scroll to the last added thumbnail in the serial layout within the scrollview
        [thumbnailScrollView scrollItemToVisible:(_numImages)];
        currentPage = _numImages;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        singleTap.cancelsTouchesInView = NO;
        [thumbnailScrollView addGestureRecognizer:singleTap];
        
    }//end if(_numImages>0)
    
}//end updateNumImages

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint=[gesture locationInView:thumbnailScrollView];
    CGFloat pos = (CGFloat)touchPoint.x / thumbnailWidth;
    int page = round(ceilf(pos));
    //NSLog(@"singleTap. page= %i", page);
    
    
    [self removeAllBubbles];
    [self removeAllResources];
    
    // Scroll to the most rcently added panel in panel scrollview
    CGRect panelFrame = panelScrollView.frame;
    panelFrame.origin.x = panelScrollObjWidth * (page-1);
    //NSLog(@"panelframe.origin.x = %f", panelFrame.origin.x);
    panelFrame.origin.y = 0;
    [panelScrollView scrollRectToVisible:panelFrame animated:YES];
    
    
    
    //Add bubbles and resources to a panel after scrolling
    [self addBubblesForPage:page-1];
    [self addResourcesForPage:page-1];
}



-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        _groupname = [prefs objectForKey:@"groupname"];
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
    [self updateNumImages];
    self.panelScrollView.delegate=self;
    
    /*
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"submit.png"]
                                   style:UIBarButtonItemStyleBordered
                                   target:nil
                                   action:nil];
 
    
    [[self navigationItem] setBackBarButtonItem:backButton];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
     */
     
    //[super viewDidLoad];
	// Do any additional setup after loading the view.
}


BOOL _bubblesAdded2 = NO;
-(void)removeAllBubbles
{
    for (UIView *subview in self.view.subviews)
    {
        if([subview isMemberOfClass:[SpeechBubbleView class]])
        {
            [subview removeFromSuperview];
        }
    }
    _bubblesAdded2 = NO;
}

-(void)addBubblesForPage:(int)page
{
    
    if(_bubblesAdded2) return;
    
    _bubblesAdded2 = YES;
    
    NSString* urlBubbleString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/%d.bub",_groupname,
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


BOOL _resourcesAdded2 = NO;
-(void)removeAllResources
{
    for (UIView *subview in self.view.subviews)
    {
        if([subview isMemberOfClass:[ResourceView class]])
        {
            [subview removeFromSuperview];
        }
    }
    _resourcesAdded2 = NO;
}

-(void)addResourcesForPage:(int)page
{
    
    if(_resourcesAdded2) return;
    
    _resourcesAdded2 = YES;
    
    NSString* urlResourceString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/%d.bub",_groupname, page+1];
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
                // [[bubble objectForKey:@"w"] floatValue],
                // [[bubble objectForKey:@"h"] floatValue]);
                
                
                
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
    //NSLog(@"alignRowInPhotoTableView. _numImages is %i", _numImages);
    if(_numImages>0)
    {
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth;
        int page = round(ceilf(pos));
        //if( row == _numImages) row--;
        //NSLog(@"alignPage. page= %i", page);
        
        //if(_numImages!=page) [self addBubblesForRow:page]; //Don't load images for placeholder (hack1)
        
        //Add bubbles and resources to a panel after scrolling
        [self addBubblesForPage:page];
        [self addResourcesForPage:page];
        
        currentPage = page+1;
        
        // Scroll to the current page's thumbnail in thumbnail scrollview
        [thumbnailScrollView scrollItemToVisible:(page+1)];
        /*
        CGRect thumbnailFrame = thumbnailScrollView.frame;
        thumbnailFrame.origin.x = thumbnailScrollObjWidth1 * (page-1);
        //NSLog(@"thumbframe.origin.x = %f", thumbnailFrame.origin.x);
        thumbnailFrame.origin.y = 0;
        [thumbnailScrollView scrollRectToVisible:thumbnailFrame animated:YES];
        */
    }//end if _numImages>0
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndScrollingAnimation");
    //[self alignPageInPanelScrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating");
    [self alignPageInPanelScrollView];
}


-(void)newImageNotification
{
    [self removeAllBubbles];
    [self removeAllResources];
    [self updateNumImages];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    if([[segue identifier] isEqualToString:@"editPanel"])
    {
        PanelEditViewControllerII *ebvc = (PanelEditViewControllerII *)[segue destinationViewController];
        /*
        PhotoTableViewCell *cell = (PhotoTableViewCell*)sender;
        NSIndexPath *indexPath = [self.photoTableView indexPathForCell:cell];
        */
        NSString* urlString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/%d.jpg",_groupname, currentPage];
        NSLog(@"segue. currentPage %i", currentPage);
        NSLog(@"segue. urlString %@", urlString);
        ebvc.url = [NSURL URLWithString:urlString];
        
        for (UIView *subview in self.view.subviews)
        {
            //Add Speech Bubbles
            if([subview isMemberOfClass:[SpeechBubbleView class]])
            {
                SpeechBubbleView* sbv =(SpeechBubbleView*)subview;
                SpeechBubbleView *new_sbv = [[SpeechBubbleView alloc] initWithFrame:sbv.frame andText:sbv.textView.text andStyle:sbv.styleId];
                new_sbv.userInteractionEnabled = YES;
                new_sbv.alpha = 0;
                [ebvc.view addSubview:new_sbv];
            }
            
            //Add Resources
            if([subview isMemberOfClass:[ResourceView class]])
            {
                ResourceView* sbv =(ResourceView*)subview;
                
                ResourceView *new_sbv = [[ResourceView alloc] initWithFrame:sbv.frame andStyle:sbv.styleId];
                new_sbv.userInteractionEnabled = YES;
                new_sbv.alpha = 0;
                [ebvc.view addSubview:new_sbv];
            }
        }
       
        ebvc.startWithCamera = NO;
    }


}


@end
