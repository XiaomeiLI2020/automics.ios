//
//  GroupJoinViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 28/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "GroupJoinViewController.h"
#import "GroupCollectionViewCell.h"
#import "APIWrapper.h"
#import "GroupCollectionViewLayout.h"
#import "DataLoader.h"
//#import "QREncoder.h"
//#import "GroupQRView.h"

@interface GroupJoinViewController ()
@property NSArray* groups;
@property NSMutableDictionary *groupImages;
@property NSMutableDictionary* photoLoadersInProgress;
@property NSMutableDictionary* imageDownloadersInProgress;
@end

@implementation GroupJoinViewController

@synthesize photoLoadersInProgress;
@synthesize imageDownloadersInProgress;
@synthesize groupImages;
@synthesize userLoader;

BOOL alertShown;
NSString* groupHashId;
DataLoader* dataLoader;
NSString *mCellID = @"GROUP_CELL";

- (void)viewDidLoad
{
    [super viewDidLoad];
    alertShown = NO;
    userLoader = [[UserLoader alloc] init];
    userLoader.delegate = self;
    dataLoader= [[DataLoader alloc] init];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    groupHashId= [prefs objectForKey:@"current_group_hash"];
    NSLog(@"GroupJoinViewController.groupHashId=%@", groupHashId);

    [self loadGroups];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groupViewBackground"]];
    photoLoadersInProgress = [[NSMutableDictionary alloc] init];
    imageDownloadersInProgress = [[NSMutableDictionary alloc] init];
    groupImages = [[NSMutableDictionary alloc] init];
    [self.collectionView setCollectionViewLayout:[[GroupCollectionViewLayout alloc] init]];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self cancelPhotoLoadRequests];
    [self cancelImageDownloadRequests];
    [groupImages removeAllObjects];
    [super viewDidDisappear:animated];
}

-(void)loadGroups{
    GroupLoader *groupLoader = [[GroupLoader alloc] init];
    groupLoader.delegate = self;
    [groupLoader submitRequestGetGroups];
}

-(void)loadPhotosForGroup:(Group *)group atIndexPath:(NSIndexPath *)indexPath{
    PhotoLoader *photoLoader = [[PhotoLoader alloc] init];
    photoLoader.delegate = self;
    photoLoader.obj = indexPath;
    [photoLoader submitRequestGetPhotosForGroup:[group hashId]];
    [photoLoadersInProgress setObject:photoLoader forKey:indexPath];
}

-(void)cancelPhotoLoadRequests{
    NSArray *allPhotoLoaders = [self.photoLoadersInProgress allValues];
    [allPhotoLoaders makeObjectsPerformSelector:@selector(cancelRequest)];
    [self.photoLoadersInProgress removeAllObjects];
}

-(void)cancelPhotoLoadRequestForIndexPath:(NSIndexPath*)indexPath{
    PhotoLoader *photoLoader = [photoLoadersInProgress objectForKey:indexPath];
    [photoLoader cancelRequest];
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
    [groupImages setObject:image forKey:indexPath];
}

#pragma mark - UIAlertViewDelegate
-(void)UserLoader:(UserLoader*)loader didJoinGroup:(User*)currentUser{
    
    //NSLog(@"Group join request approved.");
    if(currentUser!=nil)
    {
        NSLog(@"currentUser.userId=%i", currentUser.userId);
        NSLog(@"currentUser.email=%@", currentUser.email);
        
        Group* currentGroup = currentUser.currentGroup;
        NSLog(@"currentGroup.hashId=%@", currentGroup.hashId);
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //[userDefaults setObject:user.currentSession.token forKey:@"session"];
        [userDefaults setObject:currentGroup.hashId forKey:@"current_group_hash"];
        [userDefaults setObject:[NSNumber numberWithInt:currentUser.userId] forKey:@"user_id"];
        [userDefaults synchronize];
        
        //NSLog(@"user.session=%@", user.currentSession.token);
        /*
         NSLog(@"user.userId=%i", user.userId);
         NSLog(@"user.group_hash=%@", user.groupHashId);
         
         NSLog(@"user.email=%@", user.email);
         */
    }
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Confirm"])
    {
        alertShown = NO;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString* sessionToken = [prefs objectForKey:@"session"];
        [userLoader submitRequestPostJoinGroup:sessionToken andGroupHashId:groupHashId];
        //[self performSegueWithIdentifier:@"toGroupMain" sender:self];
        //[self dismissViewControllerAnimated:YES completion:nil];
        return;
    }//end if
    if([title isEqualToString:@"Cancel"])
    {
        alertShown = NO;
        //[self performSegueWithIdentifier:@"postToView" sender:self];
        //[self dismissViewControllerAnimated:YES completion:nil];
        return;
    }//end if
}//end alertView

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    GroupCollectionViewCell* selectedGroupCell = (GroupCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    Group *group = [selectedGroupCell getGroup];
    
    
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
    else{
        //Create database for that group
        [dataLoader submitSQLRequestCreateTablesForGroup:group.groupId];

        if(!alertShown)
        {
            groupHashId = group.hashId;
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Join Group"
                                  message: [NSString stringWithFormat:@"You will join %@", group.name]
                                  delegate: self
                                  cancelButtonTitle:@"Confirm"
                                  otherButtonTitles:@"Cancel", nil];
            [alert show];
            alertShown = YES;
        }
        

    }
     
    //UIImage* qrcodeImage = [self generateQRCodeImageForURL:url];
    /*
    GroupQRView *qrView = [[[NSBundle mainBundle] loadNibNamed:@"GroupQRView" owner:self options:nil] objectAtIndex:0];
    qrView.qrImageView.image = qrcodeImage;
    qrView.label.text = group.name;
    CGSize size = qrView.frame.size;
    qrView.frame = CGRectMake(abs(self.collectionView.frame.size.width / 2.0 - size.width/2.0), abs(self.collectionView.frame.size.height / 2.0 - size.height/2.0), size.width, size.height);
    [self.view addSubview:qrView];
     */
}

/*
-(UIImage*)generateQRCodeImageForURL:(NSString*)url{
    DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:url];
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:250];
    return qrcodeImage;
}
 */

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [self cancelPhotoLoadRequestForIndexPath:indexPath];
    [self cancelImageDownloadRequestForIndexPath:indexPath];
    [groupImages removeObjectForKey:indexPath];
}


#pragma mark - UICollectionViewDataSourceDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_groups != nil)
        return [_groups count];
    else
        return 0;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:mCellID forIndexPath:indexPath];
    Group *group = [_groups objectAtIndex:indexPath.item];
    [cell setGroup:group];
    //cell.label.text = group.name;
    if ([groupImages objectForKey:indexPath] != nil){
        cell.imageView.image = [groupImages objectForKey:indexPath];
        [cell.activityIndicator stopAnimating];
    }else{
        // load the image for this cell
        if ([photoLoadersInProgress objectForKey:indexPath] == nil && [imageDownloadersInProgress objectForKey:indexPath] == nil){
            [self loadPhotosForGroup:group atIndexPath:indexPath];
            [cell.activityIndicator startAnimating];
        }
    }
    return cell;
}

#pragma mark- GroupLoaderDelegate
-(void)GroupLoader:(GroupLoader *)groupLoader didLoadGroups:(NSArray *)groups{
    //NSLog(@"[groups count]=%i", [groups count]);
    _groups = groups;
    [self.collectionView reloadData];
}

-(void)GroupLoader:(GroupLoader *)groupLoader didFailWithError:(NSError *)errors{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Groups", nil) message:errors.description delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
    
}

#pragma mark - PhotoLoaderDelegate
-(void)PhotoLoader:(PhotoLoader *)photoLoader didLoadPhotos:(NSArray *)photos forObject:(NSObject*)obj{
    NSIndexPath *indexPath = (NSIndexPath*)obj;
    [photoLoadersInProgress removeObjectForKey:indexPath];
    if (photos.count > 0){
        Photo* photo = [photos objectAtIndex:arc4random_uniform(photos.count)];
        //ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[APIWrapper getAbsoluteURLUsingImageRelativePath:[photo imageURL]]];
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[photo imageURL]];
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

-(void)PhotoLoader:(PhotoLoader *)photoLoader didFailWithError:(NSError *)error{
    [self cancelPhotoLoadRequests];
}

#pragma mark - ImageDownloaderDelegate
-(void)imageDownloader:(ImageDownloader *)imageDownloader didLoadImage:(UIImage *)image forObject:(NSObject *)obj{
    NSIndexPath *indexPath = (NSIndexPath*)obj;
    [imageDownloadersInProgress removeObjectForKey:indexPath];
    [groupImages setObject:image forKey:indexPath];
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
    NSLog(@"Selected group %@", [[selectedGroupCell getGroup] name]);
}

@end
