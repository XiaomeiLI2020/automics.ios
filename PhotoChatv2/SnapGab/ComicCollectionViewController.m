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

@interface ComicCollectionViewController ()
@property NSArray* comics;
@property NSMutableDictionary *comicImages;
@property NSMutableDictionary *panelLoadersInProgress;
@property NSMutableDictionary *imageDownloadersInProgress;
@end

@implementation ComicCollectionViewController

NSString *kComicCellID = @"COMIC_CELL";
@synthesize comics;
@synthesize panelLoadersInProgress;
@synthesize imageDownloadersInProgress;
@synthesize comicImages;


- (void)viewDidLoad
{
    [super viewDidLoad];
     self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groupViewBackground"]];
    [self.collectionView setCollectionViewLayout:[[ComicCollectionViewLayout alloc] init]];
    [self loadComics];
    [self setupDataDownloadLists];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self cancelDownLoadRequests];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self cleanupData];
}

#pragma mark - DataDownloadList methods.
-(void)setupDataDownloadLists{
    panelLoadersInProgress = [[NSMutableDictionary alloc] init];
    imageDownloadersInProgress = [[NSMutableDictionary alloc] init];
    comicImages = [[NSMutableDictionary alloc] init];
}

-(void)cancelDownLoadRequests{
    [self cancelPanelLoadRequests];
    [self cancelImageDownloadRequests];
}

-(void)cleanupData{
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
    UIImage *image = [UIImage imageNamed:@"comicDefaultCellBackground.jpg"];
    [comicImages setObject:image forKey:indexPath];
}

-(void)loadComics{
    ComicLoader *comicLoader = [[ComicLoader alloc] init];
    comicLoader.delegate = self;
    [comicLoader submitRequestGetComicsForGroup:0];
}

#pragma mark ComicLoaderDelegate
-(void)ComicLoader:(ComicLoader *)loader didLoadComics:(NSArray *)groupComics{
    self.comics = groupComics;
    [self.collectionView reloadData];
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
    if ([comicImages objectForKey:indexPath] != nil){
        cell.imageView.image = [comicImages objectForKey:indexPath];
        [cell.activityView stopAnimating];
    }else{
        if ([comic.panels count] > 0){
            if ([panelLoadersInProgress objectForKey:indexPath] == nil && [imageDownloadersInProgress objectForKey:indexPath] == nil){
                Panel* panel = [comic.panels objectAtIndex:arc4random_uniform([comic.panels count])];
                //Download random panel in the comic.
                [self loadPanelWithId:panel.panelId atIndexPath:indexPath];
                [cell.activityView startAnimating];
            }
        }else{
            [self setDefaultImageForIndexPath:indexPath];
            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        }
    }
    return cell;
}

#pragma mark UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [self cancelPanelLoadRequestForIndexPath:indexPath];
    [self cancelImageDownloadRequestForIndexPath:indexPath];
}

-(void)loadPanelWithId:(int)panelId atIndexPath:(NSIndexPath *)indexPath{
    PanelLoader *panelLoader = [[PanelLoader alloc] init];
    panelLoader.delegate = self;
    panelLoader.obj = indexPath;
    [panelLoader submitRequestGetPanelWithId:panelId];
    [panelLoadersInProgress setObject:panelLoader forKey:indexPath];
}

#pragma mark - ImageDownloaderDelegate
-(void)imageDownloader:(ImageDownloader *)imageDownloader didLoadImage:(UIImage *)image forObject:(NSObject *)obj{
    NSIndexPath *indexPath = (NSIndexPath*)obj;
    [imageDownloadersInProgress removeObjectForKey:indexPath];
    [comicImages setObject:image forKey:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

-(void)imageDownloader:(ImageDownloader *)imageDownloader didFailWithError:(NSError *)error{
    [self cancelImageDownloadRequests];
}

#pragma mark PanelLoaderDelegate
-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel *)panel forObject:(id)obj{
    NSIndexPath *indexPath = (NSIndexPath*)obj;
    [panelLoadersInProgress removeObjectForKey:indexPath];
    if (panel.photo.imageURL != nil){
        //ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[APIWrapper getAbsoluteURLUsingImageRelativePath:panel.photo.imageURL]];
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:panel.photo.imageURL];
        imageDownloader.obj = indexPath;
        imageDownloader.delegate = self;
        if (imageDownloader.image == nil)
            [imageDownloadersInProgress setObject:imageDownloader forKey:indexPath];
    }else{
        [self setDefaultImageForIndexPath:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
}

-(void)PanelLoader:(PanelLoader *)loader didFailWithError:(NSError *)error{
    [self cancelPanelLoadRequests];
}


-(IBAction)menuButtonAction:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"COMIC_DETAIL"])
    {
        [self cancelDownLoadRequests];
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        Comic* selectedComic = [self.comics objectAtIndex:indexPath.item];
        ComicDetailsViewController *cpvc = (ComicDetailsViewController *)[segue destinationViewController];
        cpvc.comicId = selectedComic.comicId;
    }
}

@end
