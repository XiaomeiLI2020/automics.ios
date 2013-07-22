//
//  ComicCollectionViewController.m
//  PhotoChat
//
//  Created by horizon on 05/04/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ComicCollectionViewController.h"
#import "Comic.h"
#import "ComicCollectionViewCell.h"
#import "APIWrapper.h"
#import "ComicCollectionViewLayout.h"
#import "ComicDetailsViewController.h"
#import "UIImageView+WebCache.h"

@interface ComicCollectionViewController ()
@property NSArray* comics;
@property NSMutableDictionary *comicImages;
@property NSMutableDictionary *panelLoadersInProgress;
@property NSMutableDictionary *imageDownloadersInProgress;

@end

@implementation ComicCollectionViewController

BOOL segueCalled = NO;
BOOL comicsStored = NO;
NSString *kComicCellID = @"COMIC_CELL";
@synthesize comics;
@synthesize panelLoadersInProgress;
@synthesize imageDownloadersInProgress;
@synthesize comicImages;



- (void)viewDidLoad
{
    //NSLog(@"ComicCollectionViewController.viewDidLoad.");
    [super viewDidLoad];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    
    [self.toolbarView sendSubviewToBack:self.toolbarImage];
    /*
    UIImageView *toolbarImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolbar.png"]];
    [self.toolbarView addSubview:toolbarImage];
    [self.toolbarView sendSubviewToBack:toolbarImage];
    */

    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groupViewBackground"]];
    [self.collectionView setCollectionViewLayout:[[ComicCollectionViewLayout alloc] init]];
    
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;


    [self setupDataDownloadLists];
    //[self loadComics];


}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //[self.collectionView removeFromSuperview];
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groupViewBackground"]];
    [self.collectionView setCollectionViewLayout:[[ComicCollectionViewLayout alloc] init]];
    
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    
    [self setupDataDownloadLists];
     */
    [self loadComics];
    
}


-(id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newComicNotification:)
                                                     name:@"newComicNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newComicNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)newComicNotification:(NSNotification*)note
{
    NSDictionary *theData = [note userInfo];
    if (theData != nil) {
        NSString* message = [theData objectForKey:@"comicnotification"];
        NSLog(@"notification: %@", message);
    }
    else{
        NSLog(@"Nil data. New comic uploaded.");
    }
}


- (void)viewDidUnload
{
    //NSLog(@"viewDidUnload");
    [self cleanupData];
    [super viewDidUnload];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    //[self cancelDownLoadRequests];
    //NSLog(@"viewDidDisappear");
    [self cleanupData];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    //NSLog(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self cleanupData];
}

#pragma mark - DataDownloadList methods.
-(void)setupDataDownloadLists{
    //NSLog(@"setupDataDownloadLists");
    panelLoadersInProgress = [[NSMutableDictionary alloc] init];
    imageDownloadersInProgress = [[NSMutableDictionary alloc] init];
    comicImages = [[NSMutableDictionary alloc] init];
}

-(void)cancelDownLoadRequests{
    [self cancelPanelLoadRequests];
    [self cancelImageDownloadRequests];
}

-(void)cleanupData{
    //NSLog(@"cleanUpData");
    [self cancelDownLoadRequests];
    [comicImages removeAllObjects];
    //[self.collectionView removeFromSuperview];
}

-(void)cancelPanelLoadRequests{
    NSArray *allPanelLoaders = [self.panelLoadersInProgress allValues];
    [allPanelLoaders makeObjectsPerformSelector:@selector(cancelRequest)];
    [self.panelLoadersInProgress removeAllObjects];
}

-(void)cancelPanelLoadRequestForIndexPath:(NSIndexPath*)indexPath{
    //NSLog(@"cancelPanelLoadRequestForIndexPath");
    PanelLoader *panelLoader = [panelLoadersInProgress objectForKey:indexPath];
    [panelLoader cancelRequest];
    [panelLoadersInProgress removeObjectForKey:indexPath];
}

-(void)cancelImageDownloadRequestForIndexPath:(NSIndexPath*)indexPath{
    NSLog(@"cancelImageDownloadRequestForIndexPath");
    ImageDownloader *imageDownloader = [imageDownloadersInProgress objectForKey:indexPath];
    [imageDownloader cancelRequest];
    [imageDownloadersInProgress removeObjectForKey:indexPath];
}

-(void)cancelImageDownloadRequests{
    NSArray *allImageDownloaders = [self.imageDownloadersInProgress allValues];
    [allImageDownloaders makeObjectsPerformSelector:@selector(cancelRequest)];
    [self.imageDownloadersInProgress removeAllObjects];
}

-(void)setDefaultImageForIndexPath:(NSIndexPath*)indexPath{
    NSLog(@"setDefaultImageForIndexPath.[comicImages count]=%i", [comicImages count]);
    UIImage *image = [UIImage imageNamed:@"comicDefaultCellBackground.jpg"];
    [comicImages setObject:image forKey:indexPath];
}

-(void)loadComics{
    //NSLog(@"loadComics");
    ComicLoader *comicLoader = [[ComicLoader alloc] init];
    comicLoader.delegate = self;
    [comicLoader submitRequestGetComicsForGroup];
}


-(void)refreshComics{
    //NSLog(@"loadComics");
    ComicLoader *comicLoader = [[ComicLoader alloc] init];
    comicLoader.delegate = self;
    [comicLoader submitRequestRefreshComicsForGroup];
    //[comicLoader submitRequestGetComicsForGroup];
}

-(void)loadPanelWithId:(int)panelId atIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"loadPanelWithId.panelId=%i", panelId);
    PanelLoader *panelLoader = [[PanelLoader alloc] init];
    panelLoader.delegate = self;
    panelLoader.obj = indexPath;
    [panelLoadersInProgress setObject:panelLoader forKey:indexPath];
    [panelLoader submitRequestGetPanelWithId:panelId];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndScrollingAnimation.scrollView.tag");
    /*if(scrollView.tag==0)
        [self alignPageInPanelScrollView];
    if(scrollView.tag==1)
        [self alignPageInThumbnailScrollView];
     */
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating.scrollView.tag");
    /*if(scrollView.tag==0)
        [self alignPageInPanelScrollView];
    if(scrollView.tag==1)
        [self alignPageInThumbnailScrollView];
     */
}

#pragma mark ComicLoaderDelegate
-(void)ComicLoader:(ComicLoader*)loader didLoadComics:(NSArray *)groupComics{
    //NSLog(@"didLoadComics");
    self.comics = groupComics;
    //NSLog(@"ComicCollectionViewController.didLoadComics.self.comics=%i", [self.comics count]);
    
    //To make sure messages sent to any UIKit object are sent on the main thread.
   
    if([self.comics count]>0)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.collectionView reloadData];
        });
    }//end if([self.comics count]>0)


    //[self.collectionView reloadData];

}

-(void)ComicLoader:(ComicLoader *)loader didFailWithError:(NSError *)error{
    NSLog(@"ComicLoader.didFailWithError");
    /*
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Comics", nil) message:error.description delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
     */
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.comics != nil)
        return [self.comics count];
    else
        return 0;
}



-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ComicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kComicCellID forIndexPath:indexPath];
    Comic* comic = [self.comics objectAtIndex:indexPath.item];
    [cell setComic:comic];
    
    //cell.label.text=@"";
    //NSLog(@"collectionView cellForItemAtIndexPath.[self.comics count]=%i, indexPath.item=%i, comicId=%i, [comicImages count]=%i, [comicImages objectForKey:indexPath]=%@", [self.comics count], indexPath.item, comic.comicId, [comicImages count], [comicImages objectForKey:indexPath]);

    //if([comicImages count]>0)
    {
        if([comicImages objectForKey:indexPath] != nil)
        {
            
            //[cell.activityView stopAnimating];
            
            id object= [comicImages objectForKey:indexPath];
            if([object isKindOfClass:[UIImage class]])
            {
                
                cell.imageView.image = [comicImages objectForKey:indexPath];
            }
            if([object isKindOfClass:[NSString class]])
            {
                //[cell.imageView setImageWithURL:object placeholderImage:nil];
                NSRange rangeValue = [object rangeOfString:@"http://automicsii.cloudapp.net/" options:NSCaseInsensitiveSearch];
                if (rangeValue.length>0)
                {
                    [cell.imageView setImageWithURL:[NSURL URLWithString:object] placeholderImage:nil];
                }
                else{
                    
                    [cell.imageView setImage:[UIImage imageWithContentsOfFile:object]];
                    //[cell.imageView setImage:[UIImage imageNamed:imageURL]];
                }
                
            }
            //NSLog(@"animation stopped. indexPath.item=%i", indexPath.item);
            if(cell.activityView!=nil)
                [cell.activityView stopAnimating];
            //NSLog(@"animation stopped.");
            
            //cell.imageView.image = [comicImages objectForKey:indexPath];
            
            //NSString* imageURL = [comicImages objectForKey:indexPath];
            //NSLog(@"imageURL=%@", imageURL);
            /*
             NSRange rangeValue = [imageURL rangeOfString:@"http://automicsii.cloudapp.net/" options:NSCaseInsensitiveSearch];
             if (rangeValue.length>0)
             {
             [cell.imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil];
             }
             else{
             
             [cell.imageView setImage:[UIImage imageWithContentsOfFile:imageURL]];
             //[cell.imageView setImage:[UIImage imageNamed:imageURL]];
             }
             */
            
            
            //[imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
            //[cell.imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil];
            //[cell.activityView stopAnimating];
            //NSLog(@"animation stopped.imageURL =%@, indexPath.row=%i", imageURL, indexPath.row);
            
        }//end if ([comicImages objectForKey:indexPath] != nil)
        else if([comicImages objectForKey:indexPath] == nil)
        {
            //NSLog(@"[comic.panels count]=%i", [comic.panels count]);
            if([comic.panels count] > 0)
            {
                //if ([panelLoadersInProgress objectForKey:indexPath] == nil && [imageDownloadersInProgress objectForKey:indexPath] == nil)
                if ([panelLoadersInProgress objectForKey:indexPath] == nil)
                {
                    
                    //[cell.activityView startAnimating];
                    
                    //Panel* panel = [comic.panels objectAtIndex:arc4random_uniform([comic.panels count])];
                    Panel* panel = [comic.panels objectAtIndex:0];
                    //NSLog(@"animation started.=panel.panelId=%i, panel.photo.photoId=%i, panel.photo.imageURL=%@", panel.panelId, panel.photo.photoId, panel.photo.imageURL);
                    //Download random panel in the comic.
                    [self loadPanelWithId:panel.panelId atIndexPath:indexPath];
                    //NSLog(@"animation started.=panel.panelId=%i, panel.photo.photoId=%i", panel.panelId, panel.photo.photoId);
                    [cell.activityView startAnimating];
                    
                }//end if ([panelLoadersInProgress objectForKey:indexPath] == nil)
            }//end if([comic.panels count]>0)
            else if([comic.panels count] == 0)
            {
                //NSLog(@"collectionView cellForItemAtIndexPath. [comicImages objectForKey:indexPath] is nil");
                [self setDefaultImageForIndexPath:indexPath];
                //dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                //});
                //[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            }//end else
        }//end if ([comicImages objectForKey:indexPath] == nil)
        
    }//end if([comicImages count]>0)

    return cell;
}



#pragma mark UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"collectionView.didEndDisplayingCell. indexPath.row=%i, indexPath.section=%i", indexPath.row, indexPath.section);
    
    //if([panelLoadersInProgress objectForKey:indexPath]!=nil)
    if(indexPath!=nil && [panelLoadersInProgress objectForKey:indexPath]!=nil)// && [comicImages objectForKey:indexPath]!=nil)
    {
        [self cancelPanelLoadRequestForIndexPath:indexPath];
    }
    //[self cancelPanelLoadRequestForIndexPath:indexPath];
    //[self cancelImageDownloadRequestForIndexPath:indexPath];
}



#pragma mark - ImageDownloaderDelegate
-(void)imageDownloader:(ImageDownloader *)imageDownloader didLoadImage:(UIImage*)image forObject:(NSObject *)obj{
    NSLog(@"didLoadImage.");
    NSIndexPath *indexPath = (NSIndexPath*)obj;
    NSLog(@"imageDownloadersInProgress removeObjectForKey");
    [imageDownloadersInProgress removeObjectForKey:indexPath];
    [comicImages setObject:image forKey:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

-(void)imageDownloader:(ImageDownloader *)imageDownloader didFailWithError:(NSError *)error{
    [self cancelImageDownloadRequests];
}

#pragma mark PanelLoaderDelegate
-(void)PanelLoader:(PanelLoader*)loader didLoadPanel:(Panel*)panel forObject:(id)obj{
    //NSLog(@"didLoadPanel. panel.panelId=%i", panel.panelId);
    NSIndexPath *indexPath = (NSIndexPath*)obj;
    [panelLoadersInProgress removeObjectForKey:indexPath];
    
    //NSLog(@"didLoadPanel. panel.panelId=%i, indexPath.item=%i", panel.panelId, indexPath.item);
    if (panel.photo.imageURL != nil && panel.photo.photoId>0){
        
        UIImageView *imageView = [[UIImageView alloc] init];
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //NSString* imageName = [NSString stringWithFormat:@"%i.png", currentPage];
        NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", panel.photo.photoId];
        NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
        BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
        

        //NSLog(@"didLoadPanel. Panel[%i].[%@] File exists=%d", panel.panelId, imageName, fileExists);
        if(!fileExists)
        {
            [comicImages setObject:panel.photo.imageURL forKey:indexPath];
            
            [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:nil
                               success:^(UIImage *imageDownloaded) {
                                   //UIImageWriteToSavedPhotosAlbum(imageDownloaded, nil, nil, nil);
                                   
                                   //[comicImages setObject:imageDownloaded forKey:indexPath];
                                   
                                   //NSLog(@"alignPageinPanelScrollView.saving image=%@", imageName);
                                   NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                                   [data1 writeToFile:currentFile atomically:YES];
                                   
                               }
                               failure:^(NSError *error) {
                                   NSLog(@"ComicCollectionViewController.Failed to load image");
                               }];
        }//end if(!fileExists)
        else if(fileExists)
        {
            //NSLog(@"alignPageinPanelScrollView. Loading image from file=%@", imageName);
            //NSError* err;
            //[fileMgr removeItemAtPath:currentFile error:&err];
            //[imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
            [comicImages setObject:currentFile forKey:indexPath];
        }//end if(fileExists)
       
        
        /*
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] init];
        [imageDownloadersInProgress setObject:imageDownloader forKey:indexPath];
        UIImageView *imageView = [[UIImageView alloc] init];            
        [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:nil
                               success:^(UIImage *imageDownloaded) {
                                   //imageDownloader.image = imageDownloaded;
                                   [imageDownloadersInProgress removeObjectForKey:indexPath];
                                   [comicImages setObject:imageDownloaded forKey:indexPath];
                                   [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                               }
                               failure:^(NSError *error) {
                                   NSLog(@"ComicCollectionViewController.Failed to load image");
                               }];
       */
        //[comicImages setObject:panel.photo.imageURL forKey:indexPath];
        //[self.collectionView reloadData];
        //[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        
        //To make sure messages sent to any UIKit object are sent on the main thread. 
        dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        });
        
        //ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[APIWrapper getAbsoluteURLUsingImageRelativePath:panel.photo.imageURL]];
        
        /*
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:panel.photo.imageURL];

        imageDownloader.obj = indexPath;
        imageDownloader.delegate = self;
        if(imageDownloader.image == nil)
        {
            NSLog(@"imageDownloader.image is nil. imageDownloadersInProgress setObject");
            [imageDownloadersInProgress setObject:imageDownloader forKey:indexPath];
        }
        else{
            NSLog(@"imageDownloader.image is not nil");
        }
       */
 
        
    }else{
        [self setDefaultImageForIndexPath:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
}


-(void)PanelLoader:(PanelLoader *)loader didFailWithError:(NSError *)error{
    [self cancelPanelLoadRequests];
}




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    /*
    NSLog(@"comicsStored=%d", comicsStored);
    if(!comicsStored)
    {
        ComicLoader* comicLoader = [[ComicLoader alloc] init];
        [comicLoader submitSQLRequestSaveComics:comics];
    }
     */
    
    //[loader submitSQLRequestSaveComics:comics];
    
    if([[segue identifier] isEqualToString:@"COMIC_DETAIL"])
    {
        //[self cancelDownLoadRequests];
        [self cleanupData];
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        Comic* selectedComic = [self.comics objectAtIndex:indexPath.item];
        ComicDetailsViewController *cpvc = (ComicDetailsViewController *)[segue destinationViewController];
        cpvc.comicId = selectedComic.comicId;
        cpvc.comicName = selectedComic.name;
    }

    if([[segue identifier] isEqualToString:@"comicstomenu1"])
    {
        NSLog(@"prepareForSegue.comicstomenu1");
        //[self cleanupData];
        //[self.collectionView removeFromSuperview];
        

        [self.collectionView performBatchUpdates:^{
            [self cleanupData];
            
            //Couldn't find a better way to prevent app crashing, so used this.
            [self.collectionView removeFromSuperview];

        } completion:nil];

        
        //[self viewDidDisappear:YES];
        //[self cancelPanelLoadRequests];
        //[self cancelDownLoadRequests];
    }
    
    if([[segue identifier] isEqualToString:@"comicAddName"])
    {
        //NSLog(@"prepareForSegue.comicAdd1");
        [self cleanupData];
        //[self cancelPanelLoadRequests];
        //[self cancelDownLoadRequests];
    }//end if
    
    if([[segue identifier] isEqualToString:@"comicAdd1"])
    {
        //NSLog(@"prepareForSegue.comicAdd1");
        [self cleanupData];
        //[self cancelPanelLoadRequests];
        //[self cancelDownLoadRequests];
    }//end if
}


- (IBAction)refreshed:(id)sender {
    //NSLog(@"refresh comics button pressed");
    [self refreshComics];
}
@end
