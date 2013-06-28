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
     self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groupViewBackground"]];
    [self.collectionView setCollectionViewLayout:[[ComicCollectionViewLayout alloc] init]];
    [self setupDataDownloadLists];
    [self loadComics];

}

/*
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
*/

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
        
        /*
         [[NSNotificationCenter defaultCenter] addObserver:self
         selector:@selector(newPanelNotification)
         name:@"newPanelNotification"
         object:nil];
         
         
         [[NSNotificationCenter defaultCenter] addObserver:self
         selector:@selector(newPanelNotification)
         name:UIApplicationDidBecomeActiveNotification
         object:nil];
         */
        
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
        NSLog(@"New comic uploaded.");
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
    //[self cancelImageDownloadRequests];
}

-(void)cleanupData{
    //NSLog(@"cleanUpData");
    [self cancelDownLoadRequests];
    [comicImages removeAllObjects];
}

-(void)cancelPanelLoadRequests{
    NSArray *allPanelLoaders = [self.panelLoadersInProgress allValues];
    [allPanelLoaders makeObjectsPerformSelector:@selector(cancelRequest)];
    [self.panelLoadersInProgress removeAllObjects];
}

-(void)cancelPanelLoadRequestForIndexPath:(NSIndexPath*)indexPath{
    PanelLoader *panelLoader = [panelLoadersInProgress objectForKey:indexPath];
    [panelLoader cancelRequest];
    [panelLoadersInProgress removeObjectForKey:indexPath];
}

-(void)cancelImageDownloadRequestForIndexPath:(NSIndexPath*)indexPath{
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
    //NSLog(@"setDefaultImageForIndexPath.[comicImages count]=%i", [comicImages count]);
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
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndScrollingAnimation.scrollView.tag");
    /*if(scrollView.tag==0)
        [self alignPageInPanelScrollView];
    if(scrollView.tag==1)
        [self alignPageInThumbnailScrollView];
     */
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating.scrollView.tag");
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
    [self.collectionView reloadData];
    
    //[loader submitSQLRequestSaveComics:comics];
}

-(void)ComicLoader:(ComicLoader *)loader didFailWithError:(NSError *)error{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Comics", nil) message:error.description delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
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
    //NSLog(@"collectionView cellForItemAtIndexPath.[self.comics count]=%i, indexPath.item=%i, comicId=%i, [comicImages objectForKey:indexPath]=%@", [self.comics count], indexPath.item, comic.comicId, [comicImages objectForKey:indexPath]);

    if ([comicImages objectForKey:indexPath] != nil){

        //cell.imageView.image = [comicImages objectForKey:indexPath];
        NSString* imageURL = [comicImages objectForKey:indexPath];
        //NSLog(@"imageURL=%@", imageURL);
        
        NSRange rangeValue = [imageURL rangeOfString:@"http://automicsii.cloudapp.net/" options:NSCaseInsensitiveSearch];
        if (rangeValue.length>0)
        {
            [cell.imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil];
        }
        else{
            
            [cell.imageView setImage:[UIImage imageWithContentsOfFile:imageURL]];
        }
        
        //[imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];
        //[cell.imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil];
        [cell.activityView stopAnimating];
        
        /*
        for (UIView *subview in self.view.subviews)
        {
            if([subview isMemberOfClass:[SpeechBubbleView class]])
            {
                [subview removeFromSuperview];
            }
        }
*/

    }else{
        //NSLog(@"[comic.panels count]=%i", [comic.panels count]);
        if ([comic.panels count] > 0){
            //if ([panelLoadersInProgress objectForKey:indexPath] == nil && [imageDownloadersInProgress objectForKey:indexPath] == nil){
            if ([panelLoadersInProgress objectForKey:indexPath] == nil){

                //Panel* panel = [comic.panels objectAtIndex:arc4random_uniform([comic.panels count])];
                Panel* panel = [comic.panels objectAtIndex:0];
                //Download random panel in the comic.
                [self loadPanelWithId:panel.panelId atIndexPath:indexPath];
                [cell.activityView startAnimating];

            }
        }else{
            //NSLog(@"collectionView cellForItemAtIndexPath");
            [self setDefaultImageForIndexPath:indexPath];
            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        }
    }//end else

    return cell;
}

#pragma mark UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"collectionView.didEndDisplayingCell");
    [self cancelPanelLoadRequestForIndexPath:indexPath];
    //[self cancelImageDownloadRequestForIndexPath:indexPath];
}

-(void)loadPanelWithId:(int)panelId atIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"loadPanelWithId");
    PanelLoader *panelLoader = [[PanelLoader alloc] init];
    panelLoader.delegate = self;
    panelLoader.obj = indexPath;
    [panelLoadersInProgress setObject:panelLoader forKey:indexPath];
    [panelLoader submitRequestGetPanelWithId:panelId];
}

#pragma mark - ImageDownloaderDelegate
-(void)imageDownloader:(ImageDownloader *)imageDownloader didLoadImage:(UIImage*)image forObject:(NSObject *)obj{
    //NSLog(@"didLoadImage");
    NSIndexPath *indexPath = (NSIndexPath*)obj;
    [imageDownloadersInProgress removeObjectForKey:indexPath];
    [comicImages setObject:image forKey:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

-(void)imageDownloader:(ImageDownloader *)imageDownloader didFailWithError:(NSError *)error{
    [self cancelImageDownloadRequests];
}

#pragma mark PanelLoaderDelegate
-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel*)panel forObject:(id)obj{
    //NSLog(@"didLoadPanel");
    NSIndexPath *indexPath = (NSIndexPath*)obj;
    [panelLoadersInProgress removeObjectForKey:indexPath];
    if (panel.photo.imageURL != nil){
        
        
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //NSString* imageName = [NSString stringWithFormat:@"%i.png", currentPage];
        NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", panel.photo.photoId];
        NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
        BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        //NSLog(@"alignPageinPanelScrollView. Panel[%i].[%@] File exists=%d", currentPanel.panelId, imageName, fileExists);
        if(!fileExists)
        {
            [comicImages setObject:panel.photo.imageURL forKey:indexPath];
            
            [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL]
                      placeholderImage:nil
                               success:^(UIImage *imageDownloaded) {
                                   //UIImageWriteToSavedPhotosAlbum(imageDownloaded, nil, nil, nil);
                                   
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
        
        //[comicImages setObject:panel.photo.imageURL forKey:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        
        //ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[APIWrapper getAbsoluteURLUsingImageRelativePath:panel.photo.imageURL]];
        /*
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:panel.photo.imageURL];
        imageDownloader.obj = indexPath;
        imageDownloader.delegate = self;
        if (imageDownloader.image == nil)
            [imageDownloadersInProgress setObject:imageDownloader forKey:indexPath];
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
    }

    if([[segue identifier] isEqualToString:@"comicstomenu1"])
    {
        //NSLog(@"prepareForSegue.comicstomenu1");
        [self cleanupData];
        //[self cancelPanelLoadRequests];
        //[self cancelDownLoadRequests];
    }
    
    if([[segue identifier] isEqualToString:@"comicAdd1"])
    {
        //NSLog(@"prepareForSegue.comicAdd1");
        [self cleanupData];
        //[self cancelPanelLoadRequests];
        //[self cancelDownLoadRequests];
    }
    
    
}


- (IBAction)refreshed:(id)sender {
    NSLog(@"refresh comics");
    [self refreshComics];
}
@end
