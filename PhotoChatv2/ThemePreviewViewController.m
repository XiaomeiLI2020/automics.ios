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
#import "UIImageView+WebCache.h"

@interface ThemePreviewViewController ()

@property NSMutableDictionary *themeImages;
@property NSMutableDictionary* photoLoadersInProgress;
@property NSMutableDictionary* imageDownloadersInProgress;

@end

@implementation ThemePreviewViewController

@synthesize theme;
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
    //NSLog(@"ThemePreviewViewController.viewDidLoad. theme.themeId=%i", theme.themeId);
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    themes = [[NSMutableArray alloc] init];
    resources = [[NSMutableArray alloc] init];
    resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate=self;
    [resourceLoader submitRequestGetResourcesForTheme:theme.themeId];
    
    alertShown = NO;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    groupHashId= [prefs objectForKey:@"current_group_hash"];
    //NSLog(@"ThemeViewController.groupHashId=%@", groupHashId);
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
   
    //self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groupViewBackground"]];
    photoLoadersInProgress = [[NSMutableDictionary alloc] init];
    imageDownloadersInProgress = [[NSMutableDictionary alloc] init];
    themeImages = [[NSMutableDictionary alloc] init];
    [self.collectionView setCollectionViewLayout:[[GroupCollectionViewLayout alloc] init]];
    
    //[self.collectionView reloadData];
    
    //[resourceLoader submitRequestGetResourcesForTheme:theme.themeId];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    //[resourceLoader submitRequestGetResourcesForTheme:theme.themeId];
}
*/
/*
-(void)viewDidDisappear:(BOOL)animated{
    [self cancelPhotoLoadRequests];
    [self cancelImageDownloadRequests];
    [themeImages removeAllObjects];
    [super viewDidDisappear:animated];
}
*/

-(void)loadPhotoForResource:(Resource*)resource atIndexPath:(NSIndexPath*)indexPath{
    /*
    ResourceLoader* resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate = self;
    resourceLoader.obj = indexPath;
    [resourceLoader submitRequestGetResourcesForTheme:theme.themeId];
    [photoLoadersInProgress setObject:resourceLoader forKey:indexPath];
     */

    //if(resource==nil)
   
    //NSLog(@"loadPhotoForResource.atIndexPath.resource.resourceId=%i", resource.resourceId);
    /*
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSLog(@"loadPhotoForResource.atIndexPath (section, row)=(%i, %i)", section, row);
    */
    //resource = [self.resources objectAtIndex:row];
    [photoLoadersInProgress setObject:resource forKey:indexPath];
}


-(void)cancelPhotoLoadRequests{
    NSArray *allPhotoLoaders = [self.photoLoadersInProgress allValues];
    [allPhotoLoaders makeObjectsPerformSelector:@selector(cancelRequest)];
    [self.photoLoadersInProgress removeAllObjects];
}

-(void)cancelPhotoLoadRequestForIndexPath:(NSIndexPath*)indexPath{
    /*
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSLog(@"cancelPhotoLoadRequestForIndexPath.indexPath (section, row)=(%i, %i)", section, row);
    */
     //PhotoLoader *photoLoader = [photoLoadersInProgress objectForKey:indexPath];
    //[photoLoader cancelRequest];
    //[photoLoadersInProgress removeObjectForKey:indexPath];
}

-(void)cancelImageDownloadRequestForIndexPath:(NSIndexPath*)indexPath{
    /*
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSLog(@"cancelImageDownloadRequestForIndexPath.indexPath (section, row)=(%i, %i)", section, row);
    */
    /*
    ImageDownloader *imageDownloader = [imageDownloadersInProgress objectForKey:indexPath];
    [imageDownloader cancelRequest];
    [imageDownloadersInProgress removeObjectForKey:indexPath];
     */
}

-(void)cancelImageDownloadRequests{
    NSArray *allImageDownloaders = [self.imageDownloadersInProgress allValues];
    [allImageDownloaders makeObjectsPerformSelector:@selector(cancelRequest)];
    [self.imageDownloadersInProgress removeAllObjects];
}

-(void)setDefaultImageForIndexPath:(NSIndexPath*)indexPath{
    UIImage *image = [UIImage imageNamed:@"groupDefaultCellBackground.jpg"];
    [themeImages setObject:image forKey:indexPath];
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSLog(@"setDefaultImageForIndexPath.indexPath (section, row)=(%i, %i)", section, row);
}

- (IBAction)selectThemePressed:(id)sender {
    
    if(!alertShown)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Select theme"
                              message: [NSString stringWithFormat:@"You selected theme %@", theme.name]
                              delegate: self
                              cancelButtonTitle:@"Confirm"
                              otherButtonTitles:@"Cancel", nil];
        [alert show];
        alertShown = YES;
    }//end if
}

-(void)cancelDownLoadRequests{
    [self cancelPhotoLoadRequests];
    [self cancelImageDownloadRequests];
}


-(void)cleanupData{
    //NSLog(@"cleanUpData");
    [self cancelDownLoadRequests];
    [themeImages removeAllObjects];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"backthemes"])
    {
        //NSLog(@"prepareForSegue.comicAdd1");
        [self cleanupData];
        [self.collectionView removeFromSuperview];
        //[self cancelPanelLoadRequests];
        //[self cancelDownLoadRequests];
    }//end if
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Confirm"])
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString* groupHashId= [prefs objectForKey:@"new_group_hash"];
        //NSLog(@"groupHashId=%@", groupHashId);
        
        GroupLoader* groupLoader = [[GroupLoader alloc] init];
        groupLoader.delegate = self;
        [groupLoader submitRequestPostThemeForGroup:groupHashId andThemeId:themeId];
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
    //NSLog(@"collectionView didEndDisplayingCell");
    [self cancelPhotoLoadRequestForIndexPath:indexPath];
    [self cancelImageDownloadRequestForIndexPath:indexPath];
    [themeImages removeObjectForKey:indexPath];
}


#pragma mark - UICollectionViewDataSourceDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //NSLog(@"ThemePreviewViewController.collectionView numberOfItemsInSection=%i", [resources count]);
    if (resources != nil)
        return [resources count];
    else
        return 0;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"ThemePreviewViewController.cellForItemAtIndexPath");
    GroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:nCellID forIndexPath:indexPath];
    Resource* resource = [resources objectAtIndex:indexPath.item];
    [cell setResource:resource];
    
    /*
    //ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[APIWrapper getAbsoluteURLUsingImageRelativePath:[photo imageURL]]];
    ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[resource imageURL]];
    //NSNumber *n =resource.resourceId;
    imageDownloader.obj = [NSNumber numberWithInt:resource.resourceId];
    imageDownloader.delegate = self;
    if (imageDownloader.image == nil)
        [imageDownloadersInProgress setObject:imageDownloader forKey:indexPath];
    */
    //cell.imageView.image = imageDownloader.image;
    //[cell.activityIndicator stopAnimating];
    
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString* imageName = [NSString stringWithFormat:@"%i.png", currentPage];
    NSString* imageName = [NSString stringWithFormat:@"resource%i.png", resource.resourceId];
    NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
    
    if(!fileExists)
    {
        
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:[resource.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                   placeholderImage:nil
                          completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
         {
             //NSLog(@"alignPageinPanelScrollView.saving image=%@", imageName);
             NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
             [data1 writeToFile:currentFile atomically:YES];
         }];
        
        /*
        [cell.imageView setImageWithURL:[NSURL URLWithString:resource.imageURL]
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
         */
        
    }//end if(!fileExists)
    else if(fileExists)
    {
        //NSLog(@"ThemePreviewViewController. Resource photo Loading image from file=%@", imageName);
        //NSError* err;
        //[fileMgr removeItemAtPath:currentFile error:&err];
        [cell.imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
    }//end if(fileExists)
    
    
    //[cell.imageView setImageWithURL:[NSURL URLWithString:resource.imageURL] placeholderImage:nil];
    
    
    
    //cell.imageView.image = [imageView setImageWithURL:[NSURL URLWithString:panel.photo.imageURL] placeholderImage:nil];;
    //[cell.activityIndicator stopAnimating];
    
    //cell.label.text = resource.description;
    /*
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
    */
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
    NSMutableArray* mutableResources = [[NSMutableArray alloc] initWithArray:resourcesLocal];
    resources = mutableResources;
    //NSLog(@"ThemePreviewViewController.resources loaded.=resources=%i, resourcesLocal=%i", [resources count], [resourcesLocal count]);
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

#pragma mark - GroupLoaderDelegate
-(void)GroupLoader:(GroupLoader*)groupLoader didSaveGroup:(Group*)group{
    NSLog(@"Group saved=%@ ", group.hashId);
}


@end
