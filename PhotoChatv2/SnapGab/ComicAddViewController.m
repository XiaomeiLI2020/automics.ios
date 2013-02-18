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

@interface ComicAddViewController ()

@end

@implementation ComicAddViewController

@synthesize comicScrollView;
@synthesize thumbnailScrollView;
@synthesize _groupName;
@synthesize currentPage;

@synthesize panelArray;
@synthesize panelCounter;

int _numImages;
BOOL _bubblesAdded;
BOOL _resourcesAdded;


UILabel *clickLabel;
NSMutableArray *panelList;

UILongPressGestureRecognizer *longPressGesture;

const CGFloat comicScrollXOrigin= 0.0;
const CGFloat comicScrollYOrigin= 40.0;
const CGFloat comicScrollObjHeight= 360.0;
const CGFloat comicScrollObjWidth= 320.0;
const CGFloat comicWidth= 320.0;
const CGFloat comicHeight= 320.0;

const CGFloat thumbnailScrollXOrigin3= 0.0;
const CGFloat thumbnailScrollYOrigin3= 410.0;
const CGFloat thumbnailScrollObjHeight3= 80.0;
const CGFloat thumbnailScrollObjWidth3= 320.0;
const CGFloat thumbnailWidth3= 80.0;
const CGFloat thumbnailHeight3= 80.0;

- (void)updateNumImages
{
    
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
    
    //Check if there are images uploaded to the group
    if(_numImages>0) {
        
        //Show lable if no image has been added to the comic
        if([panelList count]==0)
            [self addLabel];
        
        // Add comic scrollview
        [self addComicScrollView];

        
        // Add thumbnail scrollview
        [self addThumbnailScrollView];
        
        // load all the images from our group and add them to the scroll views
        [self addImagesToScrollView];
        
        //Action on clicking a thumbnail image
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        //Default value for cancelsTouchesInView is YES, which will prevent buttons to be clicked
        singleTap.cancelsTouchesInView = NO;
        [thumbnailScrollView addGestureRecognizer:singleTap];
        
    }//end if(_numImages>0)
    
}//end updateNumImages


-(void)addLabel
{
    clickLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(0, 40, 320, 320)];
    clickLabel.textColor = [UIColor whiteColor];
    clickLabel.backgroundColor = [UIColor blackColor];
    //clickLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(36.0)];
    clickLabel.text = [NSString stringWithFormat: @"Click a thumbnail to add to the comic."];
    [self.view addSubview:clickLabel];
}

-(void)addComicScrollView
{
    CGRect panelFrame = CGRectMake(comicScrollXOrigin, comicScrollYOrigin, comicScrollObjWidth, comicScrollObjHeight);
    CGSize comicSize = CGSizeMake(comicWidth, comicHeight);
    comicScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:comicSize andNumItems:_numImages];
    [self.view addSubview:comicScrollView];
}

-(void)addThumbnailScrollView
{
    CGRect thumbFrame = CGRectMake(thumbnailScrollXOrigin3, thumbnailScrollYOrigin3, thumbnailScrollObjWidth3, thumbnailScrollObjHeight3);
    CGSize thumbnailSize = CGSizeMake(thumbnailWidth3, thumbnailHeight3);
    thumbnailScrollView = [[MainScrollSelector alloc] initWithFrame:thumbFrame andItemSize:thumbnailSize  andNumItems:_numImages];
    [self.view addSubview:thumbnailScrollView];
}

-(void)addImagesToScrollView
{
    NSUInteger i;
    for (i=1; i <=_numImages; i++)
    {
        //Download image
        NSString* urlImageString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/thumbs/%d.jpg",_groupName, i];
        UIImage *image = [UIImage imageNamed:urlImageString];
        
        //Add image to thumbnail scrollview
        UIImageView *thumbnailView = [[UIImageView alloc] initWithImage:image];
        [thumbnailView setImageWithURL:[NSURL URLWithString:urlImageString]
                      placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
        CGRect rect1 = thumbnailView.frame;
        rect1.size.height = thumbnailScrollObjHeight3;
        //rect1.size.width = thumbnailScrollObjWidth3;
        rect1.size.width = thumbnailWidth3;
        thumbnailView.frame = rect1;
        thumbnailView.tag = i;	// tag our images for later use when we place them in serial fashion
        
        // add images to the thumbnail scrollview
        [thumbnailScrollView addSubview:thumbnailView];
        
    }//end for
    
    // place the thumbnail in serial layout within the scrollview
    [thumbnailScrollView layoutItems];
    //Scroll to the last added thumbnail in the serial layout within the scrollview
    [thumbnailScrollView scrollItemToVisible:(_numImages)];
}

//Called on clicking a thumbnail image
- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    // Determine the position of clicked thumbnail
    CGPoint touchPoint=[gesture locationInView:thumbnailScrollView];
    CGFloat pos = (CGFloat)touchPoint.x / thumbnailWidth3;
    int page = round(ceilf(pos));
    //NSLog(@"singleTap. page= %i", page);
    
    //Remove bubbles and resources from the current view
    [self removeAllBubbles];
    [self removeAllResources];
    
    //remove clickLabel
    if([panelList count]==0)
    {
        [clickLabel removeFromSuperview];
    }
    //Add a panel to the comic
    [self addPanelToComic:page];

}

-(void)addPanelToComic:(int)page
{
    // Download the panel image corresponding to the clicked thumbnail
    NSString* urlImageString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/thumbs/%d.jpg",_groupName,
                                page];
    UIImage *image = [UIImage imageNamed:urlImageString];
    
    //Add image to the imageview
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setImageWithURL:[NSURL URLWithString:urlImageString]
              placeholderImage:[UIImage imageNamed:@"placeholder-542x542.png"]];
    
    // setup imageview's frame to a height and width
    CGRect rect = imageView.frame;
    rect.size.height = comicScrollObjHeight;
    rect.size.width = comicScrollObjWidth;
    imageView.frame = rect;
    imageView.tag = page;	// tag our images for later use when we place them in serial fashion
    
    // add image to the panel scrollview
    [comicScrollView addSubview:imageView];
    
    if([panelList count]==0)
    {
        [clickLabel removeFromSuperview];
        [self.view addSubview:comicScrollView];
    }
    
    //Add panel to the panelList
    [panelList addObject:[NSNumber numberWithInteger:page]];
    
    //Update the panel index being highlighted in the comic
    currentPage = [panelList count];
    
    //Update the number of items in comic scrollview
    comicScrollView.numItems = [panelList count];
    
    //Display images in comic scrollview
    [comicScrollView layoutItems];
    
    //Scroll to the most recently added panel in the comicScrollView
    [comicScrollView scrollItemToVisible:([panelList count])];
    
    //Add bubbles and resources to the new panel's view
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
    
    panelList = [[NSMutableArray alloc] init];
    panelArray = [[NSMutableArray alloc] init];
    panelCounter=0;
    _bubblesAdded = NO;
    _resourcesAdded = NO;
    
    [self updateNumImages];
    self.comicScrollView.delegate=self;
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
    //NSLog(@"alignRowInPhotoTableView. currentPage was %i", currentPage);
    int itemPosition;
    if([panelList count]>0)
    {
        //Constrain horizontal page position and add bubbles and resources
        CGFloat pos = (CGFloat)self.comicScrollView.contentOffset.x / comicWidth;
        int page = round(ceilf(pos));
        //NSLog(@"alignPage. page= %i", page);
        
        currentPage = page;
        //currentPage = page+1;
        if(page==0)
            itemPosition = 0;
        else
            itemPosition = page-1;
        
        int panelId = [[panelList objectAtIndex:page] integerValue];
        //NSLog(@"alignPage. panelId= %i", panelId);
        
        //Add bubbles and resources to a panel after scrolling
        [self addBubblesForPage:panelId-1];
        [self addResourcesForPage:panelId-1];
        
        //NSLog(@"alignRowInPhotoTableView. currentPage changed to %i", currentPage);
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
    
    if([[segue identifier] isEqualToString:@"comicPosterView"])
    {
        if([panelList count] >0)
        {
            
        ComicPosterViewController *cpvc = (ComicPosterViewController *)[segue destinationViewController];
        
        cpvc.comicContents = [[NSMutableArray alloc] init];
        
        NSUInteger i;
        for(i=0; i<[panelList count]; i++)
        {
            int panelId = [[panelList objectAtIndex:i] integerValue];
            NSDictionary* panel =
            [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                 [NSNumber numberWithInt:i],
                                                 [NSNumber numberWithInt:panelId],
                                                 nil]
                                        forKeys:
             [NSArray arrayWithObjects:@"placement",@"panel_id", nil]];
            //[panelArray addObject:panel];
            [cpvc.comicContents addObject:panel];
        }
                
        }//end if panelList count > 0
    } //end if

    
    if([[segue identifier] isEqualToString:@"editComic"])
    {
    }//end if
    
    
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
    
    NSString* urlBubbleString = [NSString stringWithFormat:@"http://www.automics.net/automics/userfiles/%@/%d.bub",_groupName,
                                 page+1];
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
            //Look for category:bubble in JSON
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
- (IBAction)deletePanel:(id*)sender
{
    if([panelList count] >0)
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
    if([panelList count] >0)
    {
        
        
        //NSLog(@" currentPage=%i",  currentPage);
        int itemReplaced;
        int itemRemoved= currentPage;
        //if(currentPage==0)
        //    itemRemoved = currentPage;
        int panelId = [[panelList objectAtIndex:itemRemoved] integerValue];
        //NSLog(@"alignPage. panelId= %i", panelId);
        
        for (UIView *subview in comicScrollView.subviews)
        {
            
            if([subview isKindOfClass:[UIImageView class]] && panelId==subview.tag)
            {
                //NSLog(@"comicScrollView.numItems before deletion %i", comicScrollView.numItems);
                //NSLog(@"[panelList count] before %i", [panelList count]);
                
                [subview removeFromSuperview];
                [self removeAllBubbles];
                [self removeAllResources];
                [panelList removeObjectAtIndex:itemRemoved];
                
                if(currentPage>1)
                    currentPage--;
                
                //NSLog(@"[panelList count] after %i", [panelList count]);
                if([panelList count]==0)
                {
                    [comicScrollView removeFromSuperview];
                    [self removeAllBubbles];
                    [self removeAllResources];
                    [self.view addSubview:clickLabel];

                }
                else
                {
                    if(itemRemoved==[panelList count])
                    {
                        //itemReplaced=itemRemoved-1;
                        itemReplaced=[panelList count]-1;
                    }
                    else if(itemRemoved < [panelList count])
                    {
                        itemReplaced = itemRemoved;
                    }
                    
                    //NSLog(@"itemReplaced %i", itemReplaced);
                    comicScrollView.numItems = [panelList count];
                    [comicScrollView layoutItems];
                    [comicScrollView scrollItemToVisible:(itemReplaced+1)];
                    panelId = [[panelList objectAtIndex:itemReplaced] integerValue];
                    [self addBubblesForPage:panelId-1];
                    [self addResourcesForPage:panelId-1];
                } //end else
                break;
            }//end if panelCounter>0
            
            
        }//end for
    }//end if
    
    
}
@end
