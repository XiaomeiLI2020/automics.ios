//
//  ThemePreviewViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 30/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ThemePreviewViewController.h"
#import "Theme.h"
#import "GroupCollectionViewCell.h"
#import "APIWrapper.h"
#import "GroupCollectionViewLayout.h"

@interface ThemePreviewViewController ()

@property NSMutableDictionary *themeImages;
@property NSMutableDictionary* photoLoadersInProgress;
@property NSMutableDictionary* imageDownloadersInProgress;

@end

@implementation ThemePreviewViewController

@synthesize themeId;
@synthesize photoLoadersInProgress;
@synthesize imageDownloadersInProgress;
@synthesize themeImages;

BOOL alertShown;
NSString* groupHashId;
NSString *nCellID = @"GROUP_CELL";
ResourceLoader* resourceLoader;

@synthesize resources;
@synthesize themes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    NSLog(@"ThemePreviewViewController.viewDidLoad");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    themes = [[NSMutableArray alloc] init];
    resources = [[NSMutableArray alloc] init];
    resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate=self;
    [resourceLoader submitRequestGetResourcesForTheme:1];
    
    alertShown = NO;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    groupHashId= [prefs objectForKey:@"current_group_hash"];
    //NSLog(@"ThemeViewController.groupHashId=%@", groupHashId);
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groupViewBackground"]];
    photoLoadersInProgress = [[NSMutableDictionary alloc] init];
    imageDownloadersInProgress = [[NSMutableDictionary alloc] init];
    themeImages = [[NSMutableDictionary alloc] init];
    [self.collectionView setCollectionViewLayout:[[GroupCollectionViewLayout alloc] init]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    [self cancelPhotoLoadRequests];
    [self cancelImageDownloadRequests];
    [themeImages removeAllObjects];
    [super viewDidDisappear:animated];
}


-(void)loadPhotoForResource:(Resource*)resource atIndexPath:(NSIndexPath*)indexPath{
    /*
    ResourceLoader* resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate = self;
    resourceLoader.obj = indexPath;
    [resourceLoader submitRequestGetResourcesForTheme:theme.themeId];
    [photoLoadersInProgress setObject:resourceLoader forKey:indexPath];
     */
    [photoLoadersInProgress setObject:resource forKey:indexPath];
}


-(void)cancelPhotoLoadRequests{
    NSArray *allPhotoLoaders = [self.photoLoadersInProgress allValues];
    [allPhotoLoaders makeObjectsPerformSelector:@selector(cancelRequest)];
    [self.photoLoadersInProgress removeAllObjects];
}

-(void)cancelPhotoLoadRequestForIndexPath:(NSIndexPath*)indexPath{
    //PhotoLoader *photoLoader = [photoLoadersInProgress objectForKey:indexPath];
    //[photoLoader cancelRequest];
    //ResourceLoader *rLoader = [photoLoadersInProgress objectForKey:indexPath];
    //[rLoader cancelRequest];
    [photoLoadersInProgress removeObjectForKey:indexPath];
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
    UIImage *image = [UIImage imageNamed:@"groupDefaultCellBackground.jpg"];
    [themeImages setObject:image forKey:indexPath];
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Confirm"])
    {
        alertShown = NO;
        return;
    }//end if
    if([title isEqualToString:@"Cancel"])
    {
        alertShown = NO;
        return;
    }//end if
}//end alertView

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //GroupCollectionViewCell* selectedGroupCell = (GroupCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    //Theme* theme = [selectedGroupCell getTheme];
    //Resource* resource = [selectedGroupCell getResource];
    /*
    if(theme!=nil)
    {
        NSLog(@"theme got");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Select theme"
                              message: [NSString stringWithFormat:@"You selected theme %@", theme.name]
                              delegate: self
                              cancelButtonTitle:@"Confirm"
                              otherButtonTitles:@"Cancel", nil];
        [alert show];
    }
     */
    /*
     if(groupHashId!=nil && [groupHashId isEqualToString:group.hashId])
     {
     NSLog(@"Already a member of this group");
     //if(!alertShown)
     {
     UIAlertView *alert = [[UIAlertView alloc]
     initWithTitle: @"Already a group member"
     message: [NSString stringWithFormat:@"Please select a different group"]
     delegate: nil
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     [alert show];
     //alertShown = YES;
     }
     
     }
     */
}


-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [self cancelPhotoLoadRequestForIndexPath:indexPath];
    [self cancelImageDownloadRequestForIndexPath:indexPath];
    [themeImages removeObjectForKey:indexPath];
}


#pragma mark - UICollectionViewDataSourceDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (resources != nil)
        return [resources count];
    else
        return 0;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:nCellID forIndexPath:indexPath];
    Resource* resource = [resources objectAtIndex:indexPath.item];
    [cell setResource:resource];
    
    //cell.label.text = group.name;
    if ([themeImages objectForKey:indexPath] != nil){
        cell.imageView.image = [themeImages objectForKey:indexPath];
        [cell.activityIndicator stopAnimating];
    }else{
        // load the image for this cell
        if ([photoLoadersInProgress objectForKey:indexPath] == nil && [imageDownloadersInProgress objectForKey:indexPath] == nil){
            [self loadPhotoForResource:resource atIndexPath:indexPath];
            [cell.activityIndicator startAnimating];
        }
    }
    
    return cell;
}

#pragma mark - ImageDownloaderDelegate
-(void)imageDownloader:(ImageDownloader *)imageDownloader didLoadImage:(UIImage *)image forObject:(NSObject *)obj{
    NSIndexPath *indexPath = (NSIndexPath*)obj;
    [imageDownloadersInProgress removeObjectForKey:indexPath];
    [themeImages setObject:image forKey:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

-(void)imageDownloader:(ImageDownloader *)imageDownloader didFailWithError:(NSError *)error{
    [self cancelImageDownloadRequests];
}

#pragma mark - Back button
-(IBAction)backButtonClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - gesture
-(void)handleShareGesture:(UITapGestureRecognizer*)sender
{
    CGPoint gesturePoint = [sender locationInView:self.collectionView];
    NSIndexPath* shareGestureCellPath = [self.collectionView indexPathForItemAtPoint:gesturePoint];
    GroupCollectionViewCell* selectedGroupCell = (GroupCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:shareGestureCellPath];
    NSLog(@"Selected resource %i", [[selectedGroupCell getResource] resourceId]);
}



#pragma mark ResourceLoader functions.
/*
-(void)ResourceLoader:(ResourceLoader *)loader didLoadResources:(NSArray*)resources forObject:(NSObject *)obj{
    NSLog(@"resources loaded.");
    NSIndexPath *indexPath = (NSIndexPath*)obj;
    [photoLoadersInProgress removeObjectForKey:indexPath];
    if (resources.count > 0){
        Resource* resource= [resources objectAtIndex:arc4random_uniform(resources.count)];
        //ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[APIWrapper getAbsoluteURLUsingImageRelativePath:[photo imageURL]]];
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[resource imageURL]];
        imageDownloader.obj = indexPath;
        imageDownloader.delegate = self;
        if (imageDownloader.image == nil)
            [imageDownloadersInProgress setObject:imageDownloader forKey:indexPath];
    }else{
        //set default image.
        [self setDefaultImageForIndexPath:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
}
*/

-(void)ResourceLoader:(ResourceLoader *)loader didLoadResources:(NSArray*)resourcesLocal{
    NSLog(@"ThemePreviewViewController.resources loaded.");
    NSMutableArray* mutableResources = [[NSMutableArray alloc] initWithArray:resourcesLocal];
    resources = mutableResources;
    
    [self.collectionView reloadData];

    /*
    //NSIndexPath *indexPath = (NSIndexPath*)obj;
    //[photoLoadersInProgress removeObjectForKey:indexPath];
    if (resources.count > 0){
        Resource* resource= [resources objectAtIndex:0];
        //ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[APIWrapper getAbsoluteURLUsingImageRelativePath:[photo imageURL]]];
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[resource imageURL]];
        //imageDownloader.obj = indexPath;
        imageDownloader.delegate = self;
        if (imageDownloader.image == nil)
            [imageDownloadersInProgress setObject:imageDownloader forKey:indexPath];
    }else{
        //set default image.
        [self setDefaultImageForIndexPath:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
     */
}

-(void)ResourceLoader:(ResourceLoader*)loader didLoadResource:(Resource*)resource
{
    //NSLog(@"Resource downloaded");
}





@end
