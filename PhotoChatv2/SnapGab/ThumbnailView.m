//
//  ThumbnailView.m
//  PhotoChat
//
//  Created by Umar Rashid on 09/04/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ThumbnailView.h"
#import "GUIConstant.h"
#import "SpeechBubbleView.h"
#import "Annotation.h"
#import "Placement.h"
#import "ResourceView.h"
#import "UIImageView+WebCache.h"
#import "Panel.h"
#import <QuartzCore/QuartzCore.h>
#import "APIWrapper.h"

@implementation ThumbnailView
@synthesize imageDownloader;
@synthesize image;
@synthesize panelLoader;
@synthesize resourceLoader;
@synthesize panel;
@synthesize snapshot;
@synthesize thumbnailFile;
@synthesize thumbnailPhoto;

int numPlacements;
int placementCounter;

- (id)initWithFrame:(CGRect)frame andPanel:(Panel*)panelRecieved{
    
    self = [super initWithFrame:frame];
    if (self) {

        
        panel = panelRecieved;
        //NSLog(@"ThumbnailView.initWithFrame. panel.photo.imageURL=%@", panel.photo.imageURL);
        if(panel!=nil)
        {

            NSFileManager* fileMgr = [NSFileManager defaultManager];
            //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString* imageName = [NSString stringWithFormat:@"thumbPhoto%i.png", panel.photo.photoId];
            self.thumbnailFile = [documentsDirectory stringByAppendingPathComponent:imageName];
            BOOL fileExists = [fileMgr fileExistsAtPath:thumbnailFile];
            //NSLog(@"ThumbnailView. Panel[%i].[%@] File exists=%d", panel.panelId, imageName, fileExists);

            if(!fileExists)
            {
                PhotoLoader* photoLoader = [[PhotoLoader alloc] init];
                photoLoader.delegate = self;
                [photoLoader submitRequestGetPhotoWithId:panel.photo.photoId];
            }//end if
            else if(fileExists)
            {
                UIImageView *imageView = [[UIImageView alloc] init];
                UIImage* imageDownloaded = [UIImage imageWithContentsOfFile:thumbnailFile];
                [imageView setImage:imageDownloaded];
                image = imageDownloaded;

                imageView.frame = CGRectMake(0.0, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                [self addSubview:imageView];
                
                [self loadPlacements:panel];
                [self loadAnnotations:panel];
                snapshot = [self imageWithView:self];
    
            }//end else if(fileExists)
    

           /*
            __weak UIImageView* _imageView = imageView;

            NSFileManager* fileMgr = [NSFileManager defaultManager];
            //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", panel.photo.photoId];
            NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
            BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
            //NSLog(@"ThumbnailView. Panel[%i].[%@] File exists=%d", panel.panelId, imageName, fileExists);
            */
            //if(!fileExists)
            {
                /*
                [_imageView setImageWithURL:[NSURL URLWithString:[panel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
                
                [self loadPlacements:panel];
                [self loadAnnotations:panel];
                snapshot = [self imageWithView:self];

                imageDownloader = [[ImageDownloader alloc] initWithImageURL:panel.photo.imageURL];
                imageDownloader.delegate = self;
                imageDownloader.obj = currentFile;
                if(imageDownloader.image==nil)
                {
                    //NSLog(@"imageDownloader.image is nil.");
                }
                else{
                    //NSLog(@"imageDownloader.image is not nil");
                }
                */
                
                /*
                [_imageView setImageWithURL:[NSURL URLWithString:[panel.photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                           placeholderImage:nil
                                  completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
                 {
                     image = imageDownloaded;
                     _imageView.frame = CGRectMake(0.0, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                     [self addSubview:_imageView];
                     
                     
                     NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                     [data1 writeToFile:currentFile atomically:YES];
                     //NSLog(@"ThumbnailView. File saved [%@]", imageName);
                     
                 }];
                

                [self loadPlacements:panel];
                [self loadAnnotations:panel];
                snapshot = [self imageWithView:self];
                 */
                
            }//end if(!fileExists)
             /*
            //else if(fileExists)
            {

                UIImage* imageDownloaded = [UIImage imageWithContentsOfFile:currentFile];
                [imageView setImage:imageDownloaded];
                image = imageDownloaded;
                
                
                
                imageView.frame = CGRectMake(0.0, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
                [self addSubview:imageView];
                
                [self loadPlacements:panel];
                [self loadAnnotations:panel];
                snapshot = [self imageWithView:self];
                
            }//end if(fileExists)
              */
 
           
        }//end if panel!=nil

    }//end if(self)
    return self;
}

- (id)initWithFrame:(CGRect)frame andURL:(NSString*)imageURL{
    
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
        imageView.frame = CGRectMake(0.0, 0.0, thumbnailWidth, thumbnailHeight);
        [self addSubview:imageView];

        
    }//end if
    return self;
}

- (id)initWithURL:(NSString*)imageURL{
    
    //if (self)
    {
        // Initialization code
        imageDownloader = [[ImageDownloader alloc] initWithImageURL:imageURL];
        imageDownloader.delegate = self;
        if (imageDownloader.image != nil)
        {
            NSLog(@"Image is not null");
        }
    }
    return self;
}


-(UIImage*)imageWithView:(UIView*)view
{
    //NSLog(@"ThumbnailView.imageWithView called");
    //UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    //UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    
    CGSize imageSize = [view bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    

    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    //[self setNeedsDisplay];
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage*)imageFromView:(UIView*)view
{
     // Create a graphics context with the target size
     // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
     // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
     CGSize imageSize = [view bounds].size;
     if (NULL != UIGraphicsBeginImageContextWithOptions)
     UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
     else
     UIGraphicsBeginImageContext(imageSize);
     
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     // -renderInContext: renders in the coordinate space of the layer,
     // so we must first apply the layer's geometry to the graphics context
     CGContextSaveGState(context);
     // Center the context around the view's anchor point
     CGContextTranslateCTM(context, [view center].x, [view center].y);
     // Apply the view's transform about the anchor point
     CGContextConcatCTM(context, [view transform]);
     // Offset by the portion of the bounds left of and above the anchor point
     CGContextTranslateCTM(context, -[view bounds].size.width * [[view layer] anchorPoint].x,
     -[view bounds].size.height * [[view layer] anchorPoint].y);
     
     // Render the layer hierarchy to the current context
     [[view layer] renderInContext:context];
     
     // Restore the context
     CGContextRestoreGState(context);
     
     
     // Retrieve the screenshot image
     UIImage *imageWhole = UIGraphicsGetImageFromCurrentImageContext();
     
     UIGraphicsEndImageContext();
     
     return imageWhole;

    
}

-(void)loadAnnotations:(Panel*)thumbnailPanel
{
    if (panel != nil)
    {
        if(panel.annotations!=nil)
        {
            for(Annotation* annotation in panel.annotations)
            {
                //NSLog(@"annotation=%@", annotation.text);
                CGRect xywh = CGRectMake(annotation.xOffset/5.0,
                                         annotation.yOffset/5.0,0,0);
                
                NSString* text = annotation.text;
                int styleId = annotation.bubbleStyle;
                
                
                SpeechBubbleView* sbv = [[SpeechBubbleView alloc] initWithFrame:xywh andText:text andStyle:styleId];
                //sbv.textView.font =  [sbv.textView.font fontWithSize:4];
                /*
                CGRect scrollFrame;
                scrollFrame.origin = sbv.textView.frame.origin;
                scrollFrame.size = CGSizeMake(sbv.textView.frame.size.width/20.0, sbv.textView.frame.size.height/20.0);
                sbv.textView.frame = scrollFrame;
                sbv.frame = scrollFrame;
                */
                
                sbv.transform = CGAffineTransformScale(sbv.transform, 0.2, 0.2);

                
                sbv.userInteractionEnabled = NO;
                sbv.alpha = 0.0f;
                [self addSubview:sbv];
                [UIView transitionWithView:self
                                  duration:0.25
                                   options:UIViewAnimationOptionLayoutSubviews
                                animations:^ { sbv.alpha = 1.0f; }
                                completion:nil];
                
            }
        }//end if
    }//end if panel!=null
}

-(void)loadPlacements:(Panel*)thumbnailPanel
{
    //panel = thumbnailPanel;
    //NSLog(@"loadPlacements.");
    if (panel != nil)
    {
        
        if(panel.placements!=nil)
        {
            numPlacements = [panel.resources count];
            int placementCounter = 0;
            
            //NSLog(@"Thumbnailview. panelId=%i, numPlacements=%i, numResources=%i", panel.panelId, [panel.placements count], [panel.resources count]);
            
            if(numPlacements > 0)
            {
                for(placementCounter=0; placementCounter<numPlacements; placementCounter++)
                {
                    Resource* resource = [panel.resources objectAtIndex:placementCounter];
                    if(resource!=nil)
                    {
                        NSString* type = resource.type;
                        float defaultScale = 1.0;
                        float defaultAngle = 0.0;
                        
                        CGRect resourceFrame = CGRectMake(panelScrollXOrigin, panelScrollYOrigin, frameWidth, frameHeight);
                        if([type isEqual:@"d"])
                        {
                            if(panel.placements!=nil && [panel.placements count]>placementCounter)
                            {
                                Placement* placement = [panel.placements objectAtIndex:placementCounter];
                                if(placement!=nil)
                                {
                                    resourceFrame = CGRectMake(placement.xOffset/4.0,
                                                               placement.yOffset/4.0,
                                                               decoratorWidth, decoratorHeight);
                                    defaultScale = placement.scale/4.0;
                                    defaultAngle = placement.angle;
                                }
                            }
                        }
                        if([type isEqual:@"f"])
                        {
                            resourceFrame = CGRectMake(0, 0, thumbnailWidth, thumbnailScrollObjHeight);
                        }
                        
                        //NSLog(@"resourceFrame=%@", NSStringFromCGRect(resourceFrame));
                        ResourceView *rv = [[ResourceView alloc] initWithFrame:resourceFrame andResource:resource andScale:defaultScale andAngle:defaultAngle];
                        rv.userInteractionEnabled = NO;
                        //if([type isEqual:@"d"])
                        //    rv.transform = CGAffineTransformScale(rv.transform, 0.5, 0.5);
                        [self addSubview:rv];
                        
                        //NSLog(@"Thumbnailview. panelId=%i, resource#%i added =%@", panel.panelId, resource.resourceId, resource.imageURL);
                        //NSLog(@"resource added.%i", placementCounter);
                    }//end if resource!=nil
                    
                }//end for
            }//end if(numPlacements>0)
            //snapshot = [self imageWithView:self];
        }//end if panel.placements!=nil
        
        //snapshot = [self imageWithView:self];
    }//end if panel!=null
}

#pragma mark - PhotoLoaderDelegate
-(void)PhotoLoader:(PhotoLoader *)photoLoader didLoadPhoto:(Photo*)photo;{
    if(photo!=nil)
    {
        self.thumbnailPhoto = photo;
        //NSLog(@"ThumbnailView. didloadPhoto. photo.thumbURL=%@", photo.thumbURL);
        UIImageView *imageView = [[UIImageView alloc] init];
        __weak UIImageView* _imageView = imageView;
        //[imageView setImageWithURL:[NSURL URLWithString:[panel.photo.thumbURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
  
        [imageView setImageWithURL:[NSURL URLWithString:[photo.thumbURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                  placeholderImage:nil
                         completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
         {
             self.image = imageDownloaded;
             _imageView.frame = CGRectMake(0.0, 0.0, thumbnailWidth, thumbnailScrollObjHeight);
             [self addSubview:_imageView];
             
             
             NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
             [data1 writeToFile:self.thumbnailFile atomically:YES];
             //NSLog(@"ThumbnailView. File saved [%@]", self.thumbnailFile);
         }];
        
        
        [self loadPlacements:panel];
        [self loadAnnotations:panel];
        if(self.image!=nil)
        {
            snapshot = [self imageWithView:self];
            //NSLog(@"ThumbnailView. panelPhoto%i image not nill. Snapshot generated.", panel.photo.photoId);
        }
        else
        {
            //NSLog(@"ThumbnailView. panelPhoto%i  image is nil. Snapshot not generated.", panel.photo.photoId);
            snapshot = nil;
        }

        
        
    }//end if(photo!=nil)
}

#pragma mark - ImageDownloaderDelegate
-(void)imageDownloader:(ImageDownloader *)imageDownloader didLoadImage:(UIImage*)image{
    NSLog(@"ThumbnailView. didLoadImage.");
}


@end
