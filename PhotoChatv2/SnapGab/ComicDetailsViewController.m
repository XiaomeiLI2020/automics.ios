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

@interface ComicDetailsViewController ()

@end

@implementation ComicDetailsViewController

@synthesize comicId;
@synthesize _groupName;


@synthesize panelScrollView;
//@synthesize panelImage;
@synthesize thumbnailScrollView;
//@synthesize thumbnailImage;

@synthesize addImage;


@synthesize currentPage;
@synthesize imagePicker;
@synthesize newMedia;

int _numImages;
BOOL _bubblesAdded;
BOOL _resourcesAdded;
int panelId;
NSMutableArray *panelList;


const CGFloat panelScrollXOrigin5= 0.0;
const CGFloat panelScrollYOrigin5= 40.0;
const CGFloat panelScrollObjHeight5= 360.0;
const CGFloat panelScrollObjWidth5= 320.0;
const CGFloat panelWidth5= 320.0;
const CGFloat panelHeight5= 320.0;

const CGFloat thumbnailScrollXOrigin5= 0.0;
const CGFloat thumbnailScrollYOrigin5= 410.0;
const CGFloat thumbnailScrollObjHeight5= 80.0;
const CGFloat thumbnailScrollObjWidth5= 320.0;
const CGFloat thumbnailWidth5= 80.0;
const CGFloat thumbnailHeight5= 80.0;


- (void)updateNumImages
{
    //NSURLRequestReloadIgnoringLocalCacheData does not seem to work for 3G
    
    NSString* urlComicString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/comics/%d.bub",_groupName, comicId];
    
    //NSURLRequestReloadIgnoringLocalCacheData does not seem to work for 3G
    NSString* urlString = [NSString stringWithFormat:
                           @"http://www.automics.net/automics/userfiles/%@/last.txt?%d",_groupName,arc4random()];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if(!requestError) _numImages = [[[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding] intValue];
    
    //NSLog(@"updateImages. urlString is %@", urlString);
    //NSLog(@"updateImages. _numImages is %i", _numImages);
    
    if(_numImages>0) {
        
        // Add panels to the scrollview
        /*
         CGRect panelFrame = CGRectMake(panelScrollXOrigin4, panelScrollYOrigin4, panelScrollObjWidth4, panelScrollObjHeight4);
         CGSize panelSize = CGSizeMake(panelWidth4, panelHeight4);
         panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize andNumItems:_numImages];
         [self.view addSubview:panelScrollView];
         */
        [self addImagesForComic:comicId];
        
        /*
         // Add thumbnails to the scrollview
         CGRect thumbFrame = CGRectMake(thumbnailScrollXOrigin4, thumbnailScrollYOrigin4, thumbnailScrollObjWidth4, thumbnailScrollObjHeight4);
         CGSize thumbnailSize = CGSizeMake(thumbnailWidth4, thumbnailHeight4);
         thumbnailScrollView = [[MainScrollSelector alloc] initWithFrame:thumbFrame andItemSize:thumbnailSize  andNumItems:_numImages];
         [self.view addSubview:thumbnailScrollView];
         */
        
        
        // load all the images from our bundle and add them to the scroll views
        NSUInteger i;
        for (i=1; i <=_numImages; i++)
        {
            
            NSString* urlImageString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/thumbs/%d.jpg",_groupName, i];
            
            
            UIImage *image = [UIImage imageNamed:urlImageString];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [imageView setImageWithURL:[NSURL URLWithString:urlImageString]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
            
            
            /*
             // setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
             CGRect rect = imageView.frame;
             rect.size.height = panelScrollObjHeight4;
             rect.size.width = panelScrollObjWidth4;
             imageView.frame = rect;
             imageView.tag = i;	// tag our images for later use when we place them in serial fashion
             
             // add images to the panel scrollview
             [panelScrollView addSubview:imageView];
             */
            
            // UIImageView *thumbnailView = [UIImageView alloc];
            //[thumbnailView setImage:image];
            UIImageView *thumbnailView = [[UIImageView alloc] initWithImage:image];
            [thumbnailView setImageWithURL:[NSURL URLWithString:urlImageString]
                          placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
            
            /*
             CGRect rect1 = thumbnailView.frame;
             rect1.size.height = thumbnailScrollObjHeight4;
             //rect1.size.width = thumbnailScrollObjWidth;
             rect1.size.width = thumbnailWidth4;
             thumbnailView.frame = rect1;
             thumbnailView.tag = i;	// tag our images for later use when we place them in serial fashion
             
             // add images to the thumbnail scrollview
             [thumbnailScrollView addSubview:thumbnailView];
             */
        }//end for
        
        // place the panels in serial layout within the scrollview
        //[panelScrollView layoutItems];
        
        currentPage = _numImages;
        
        //Scroll to the last added panel in the serial layout within the scrollview
        //  [panelScrollView scrollItemToVisible:(currentPage)];
        /*
         
         // place the thumbnail in serial layout within the scrollview
         [thumbnailScrollView layoutItems];
         //Scroll to the last added thumbnail in the serial layout within the scrollview
         [thumbnailScrollView scrollItemToVisible:(currentPage)];
         
         
         UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
         //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
         singleTap.cancelsTouchesInView = NO;
         [thumbnailScrollView addGestureRecognizer:singleTap];
         */
    }//end if(_numImages>0)
    
}//end updateNumImages

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    // Determine the position of clicked thumbnail
    CGPoint touchPoint=[gesture locationInView:thumbnailScrollView];
    CGFloat pos = (CGFloat)touchPoint.x / thumbnailWidth5;
    int page = round(ceilf(pos));
    //NSLog(@"singleTap. page= %i", page);
    
    //Remove bubbles and resources from the current view
    //[self removeAllBubbles];
    //[self removeAllResources];
    
    /*
     // Scroll to the most rcently added panel in panel scrollview
     CGRect panelFrame = panelScrollView.frame;
     panelFrame.origin.x = panelScrollObjWidth4 * (page-1);
     //NSLog(@"panelframe.origin.x = %f", panelFrame.origin.x);
     panelFrame.origin.y = 0;
     [panelScrollView scrollRectToVisible:panelFrame animated:YES];
     */
    
    
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
    
    //NSLog(@"viewDidLoad.currentPage.%i", currentPage);
    //NSLog(@"viewDidLoad._bubblesAdded.%d", _bubblesAdded);
    
    [self updateNumImages];
    self.panelScrollView.delegate=self;
    
    _bubblesAdded = NO;
    _resourcesAdded = NO;
    
    //Add bubbles and resources to a panel after scrolling
    [self addBubblesForPage:panelId-1];
    [self addResourcesForPage:panelId-1];
}


-(void)addImagesForComic:(int)comicId
{
    
    CGRect panelFrame = CGRectMake(panelScrollXOrigin5, panelScrollYOrigin5, panelScrollObjWidth5, panelScrollObjHeight5);
    CGSize panelSize = CGSizeMake(panelWidth5, panelHeight5);
    panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize andNumItems:_numImages];
    [self.view addSubview:panelScrollView];
    
    panelList = [[NSMutableArray alloc] init];
    
    NSString* urlComicString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/comics/%d.bub",_groupName, comicId];
    
    //NSLog(@"urlBubbleString %@", urlBubbleString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlComicString]
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
            
            int placement = [[bubble objectForKey:@"placement"] intValue];
            int imageId = [[bubble objectForKey:@"panel_id"] intValue];
            //NSLog(@"addImagesforComics. placement= %i", placement);
            //NSLog(@"addImagesforComics. imageId= %i", imageId);
            
            [panelList addObject:[NSNumber numberWithInteger:imageId]];
            //int panelIdL = [[panelIds objectAtIndex:placement] integerValue];
            //NSLog(@"addImagesforComics. panelIdL= %d", panelIdL);
            
            if(placement==0)
                panelId = imageId;
            
            NSString* urlImageString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/thumbs/%d.jpg",_groupName, imageId];
            
            UIImage *image = [UIImage imageNamed:urlImageString];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [imageView setImageWithURL:[NSURL URLWithString:urlImageString]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
            
            
            
            // setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
            CGRect rect = imageView.frame;
            rect.size.height = panelScrollObjHeight5;
            rect.size.width = panelScrollObjWidth5;
            imageView.frame = rect;
            imageView.tag = imageId;	// tag our images for later use when we place them in serial fashion
            
            // add images to the panel scrollview
            [panelScrollView addSubview:imageView];
            
        }//end for
        //NSLog(@"[panelIds count]= %d", [panelIds count]);
        panelScrollView.numItems = [panelList count];
        [panelScrollView layoutItems];
    }//end if response
    
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
    if(_bubblesAdded) return;
    
    _bubblesAdded = YES;
    
    NSString* urlBubbleString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/%d.bub",_groupName, page+1];
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
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
    
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
                
                CGRect xywh = CGRectMake([[resource objectForKey:@"x"] floatValue],
                                         [[resource objectForKey:@"y"] floatValue],
                                         [[resource objectForKey:@"w"] floatValue],
                                         [[resource objectForKey:@"h"] floatValue]);
                
                int styleId = [[resource objectForKey:@"s"] intValue];
                
                ResourceView* sbv = [[ResourceView alloc] initWithFrame:xywh andStyle:styleId];
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
        CGFloat pos = (CGFloat)self.panelScrollView.contentOffset.x / panelWidth5;
        int page = round(ceilf(pos));
        //NSLog(@"alignPage. page= %i", page);
        
        panelId = [[panelList objectAtIndex:page] integerValue];
        //NSLog(@"alignPage. panelId= %i", panelId);
        //Add bubbles and resources to a panel after scrolling
        [self addBubblesForPage:panelId-1];
        [self addResourcesForPage:panelId-1];
        
        //currentPage = page+1;
        
        // Scroll to the current page's thumbnail in thumbnail scrollview
        //[thumbnailScrollView scrollItemToVisible:(page+1)];
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
    
        if([[segue identifier] isEqualToString:@"detailToEdit"])
        {
            ComicEditViewController *cpvc = (ComicEditViewController *)[segue destinationViewController];
            cpvc.comicId = self.comicId;
        }
    
}@end
