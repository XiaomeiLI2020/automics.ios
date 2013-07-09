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
#import "UIImageView+WebCache.h"
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
    photoLoadersInProgress = [[NSMutableDictionary alloc] init];
    imageDownloadersInProgress = [[NSMutableDictionary alloc] init];
    groupImages = [[NSMutableDictionary alloc] init];
    

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    groupHashId= [prefs objectForKey:@"current_group_hash"];
    NSLog(@"GroupJoinViewController.groupHashId=%@", groupHashId);

    [self loadGroups];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groupViewBackground"]];
    [self.collectionView setCollectionViewLayout:[[GroupCollectionViewLayout alloc] init]];

}

/*
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    alertShown = NO;
    userLoader = [[UserLoader alloc] init];
    userLoader.delegate = self;
    dataLoader= [[DataLoader alloc] init];
    photoLoadersInProgress = [[NSMutableDictionary alloc] init];
    imageDownloadersInProgress = [[NSMutableDictionary alloc] init];
    groupImages = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    groupHashId= [prefs objectForKey:@"current_group_hash"];
    NSLog(@"GroupJoinViewController.groupHashId=%@", groupHashId);
    
    [self loadGroups];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groupViewBackground"]];
    [self.collectionView setCollectionViewLayout:[[GroupCollectionViewLayout alloc] init]];
}
*/

-(void)viewDidDisappear:(BOOL)animated{
    [self cancelPhotoLoadRequests];
    [self cancelImageDownloadRequests];
    [groupImages removeAllObjects];
    [super viewDidDisappear:animated];
}

-(void)didReceiveMemoryWarning{
    //NSLog(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
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

-(void)cancelDownLoadRequests{
    [self cancelPhotoLoadRequests];
    [self cancelImageDownloadRequests];
}


-(void)cleanupData{
    //NSLog(@"cleanUpData");
    [self cancelDownLoadRequests];
    [groupImages removeAllObjects];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"jointogroupsmenu"])
    {
        //NSLog(@"prepareForSegue.comicAdd1");
        [self cleanupData];
        [self.collectionView removeFromSuperview];
        //[self cancelPanelLoadRequests];
        //[self cancelDownLoadRequests];
    }//end if
}



#pragma mark - UserLoaderDelegate
/*
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
        
    }
    
}
*/

-(void)UserLoader:(UserLoader*)loader didGenerateSession:(Session*)session{
    
    NSLog(@"GroupJoinViewController.session token generated.");
    if(session!=nil)
    {
        
        NSLog(@"GroupJoinViewController.didGenerateSession.session=%@, current_group_hash=%@", session.token, groupHashId);
        if(session.token!=nil)
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:groupHashId forKey:@"current_group_hash"];
            [userDefaults setObject:session.token forKey:@"session"];
            [userDefaults synchronize];
            [userLoader submitRequestPostJoinGroup:session.token andGroupHashId:groupHashId];
            
        }//end if(session.token!=nil)
    }//end if(session!=nil)
}
-(void)UserLoader:(UserLoader*)loader didJoinGroup:(User*)currentUser{
    

    if(currentUser!=nil)
    {
        NSLog(@"GroupJoinViewController.didJoinGroup.currentUser.userId=%i", currentUser.userId);
        NSLog(@"GroupJoinViewController.didJoinGroup.currentUser.groupHashId=%@", currentUser.currentGroup.hashId);
         
         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
         [userDefaults setObject:currentUser.currentGroup.hashId forKey:@"current_group_hash"];
         [userDefaults setObject:[NSNumber numberWithInt:currentUser.userId] forKey:@"user_id"];
         [userDefaults synchronize];
        
        [userLoader submitSQLRequestUpdateCurrentGroup:currentUser.currentGroup.hashId andUserId:currentUser.userId];

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
        //NSString* sessionToken = [prefs objectForKey:@"session"];
        NSString* email = [prefs objectForKey:@"email"];
        NSString* password = [prefs objectForKey:@"password"];
        NSString* sessionToken = [prefs objectForKey:@"session"];
        NSString* currentGroupHash = [prefs objectForKey:@"current_group_hash"];
        
        //[NSNumber numberWithInt:currentUser.userId]
        int userId = [[prefs objectForKey:@"user_id"] intValue];
        
        User* user = [[User alloc] init];
        user.email = email;
        user.password = password;
  
        NSLog(@"sessionToken=%@, newgroupHashId=%@, currentGroupHash=%@, userId=%i", sessionToken, groupHashId, currentGroupHash, userId);
        //NSLog(@"email=%@, password=%@", user.email, user.password);
        //[userLoader submitRequestPostGenerateSessionToken:user];
        
        if(currentGroupHash==NULL)
            [userLoader submitRequestPostJoinGroup:sessionToken andGroupHashId:groupHashId];
        else{
            
            if(userId>0)
                [userLoader submitRequestPostChangeGroup:userId andNewGroupHashId:groupHashId];
        }
        
        return;
    }//end if([title isEqualToString:@"Confirm"])
    if([title isEqualToString:@"Cancel"])
    {
        alertShown = NO;
        
        //Restore the groupHashId to the current group
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        groupHashId = [prefs objectForKey:@"current_group_hash"];
        //[self performSegueWithIdentifier:@"postToView" sender:self];
        //[self dismissViewControllerAnimated:YES completion:nil];
        return;
    }//end if([title isEqualToString:@"Cancel"])
}//end alertView

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    GroupCollectionViewCell* selectedGroupCell = (GroupCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    Group *group = [selectedGroupCell getGroup];
    
    
    if(groupHashId!=nil && [groupHashId isEqualToString:group.hashId])
    {

            NSLog(@"Already selected this group.");
            //if(!alertShown)
            {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"This is your current group"
                                      message: [NSString stringWithFormat:@"Please select a different group"]
                                      delegate: nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                [alert show];
                //alertShown = YES;
            }
    }//end if(groupHashId!=nil && [groupHashId isEqualToString:group.hashId])
    else{
        
        if(!alertShown)
        {
            if([userLoader isReachable])
            {
                groupHashId = group.hashId;
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"Select Group"
                                      message: [NSString stringWithFormat:@"You have selected %@", group.name]
                                      delegate: self
                                      cancelButtonTitle:@"Confirm"
                                      otherButtonTitles:@"Cancel", nil];
                [alert show];
                alertShown = YES;
                
            }//end if([userLoader isReachable])
            else{
                
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle: @"You are offline."
                                      message:@"Group change only when Internet is available"
                                      delegate: nil
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:nil];
                [alert show];
            }//end else
            
            
        }//end if(!alertShown)
    }//end else
    
    /*
    if(groupHashId!=nil && [groupHashId isEqualToString:@""])
    {
        if([groupHashId isEqualToString:group.hashId])
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
            
        }//end if([groupHashId isEqualToString:group.hashId])
        
        if(![groupHashId isEqualToString:group.hashId])
        {
            //Create database for that group
            //[dataLoader submitSQLRequestCreateTablesForGroup:group.groupId];
            
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
            }//end if(!alertShown)
        }//end if(![groupHashId isEqualToString:group.hashId])
        
    }//end if(groupHashId!=nil && [groupHashId isEqualToString:@""])

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

/*
 
 [_imageView setImageWithURL:[NSURL URLWithString:resource.imageURL] placeholderImage:nil success:^(UIImage *imageDownloaded) {

}
failure:^(NSError *error) {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Load failed"
                          message: @"Failed to load image"
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}];


*/

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:mCellID forIndexPath:indexPath];
    Group *group = [_groups objectAtIndex:indexPath.item];
    [cell setGroup:group];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* groupHashIdLocal= [prefs objectForKey:@"current_group_hash"];
    
    //Display the name of current group in italic font
    if([groupHashIdLocal isEqualToString:group.hashId])
    {
        cell.label.font = [UIFont italicSystemFontOfSize:18.0f];
    }//end if([groupHashIdLocal isEqualToString:group.hashId])
    
    //cell.label.font = [UIFont italicSystemFontOfSize:16.0f];
    //cell.label.text = @"Current group"group.name;
    
    if ([groupImages objectForKey:indexPath] != nil)
    {
        
        id object= [groupImages objectForKey:indexPath];
        if([object isKindOfClass:[UIImage class]])
        {
            
            cell.imageView.image = [groupImages objectForKey:indexPath];
        }
        if([object isKindOfClass:[NSString class]])
        {
            //[cell.imageView setImageWithURL:[NSURL URLWithString:object] placeholderImage:nil];
            
            NSRange rangeValue = [object rangeOfString:@"http://automicsii.cloudapp.net/" options:NSCaseInsensitiveSearch];
            if (rangeValue.length>0)
            {
                [cell.imageView setImageWithURL:[NSURL URLWithString:object] placeholderImage:nil];
            }
            else{
                
                [cell.imageView setImage:[UIImage imageWithContentsOfFile:object]];
                //[cell.imageView setImage:[UIImage imageNamed:object]];
            }
        }//end if([object isKindOfClass:[NSString class]])

        [cell.activityIndicator stopAnimating];
    }else{
        // load the image for this cell
        if ([photoLoadersInProgress objectForKey:indexPath] == nil && [imageDownloadersInProgress objectForKey:indexPath] == nil)
        //if ([photoLoadersInProgress objectForKey:indexPath] == nil)
        {
            [self loadPhotosForGroup:group atIndexPath:indexPath];
            [cell.activityIndicator startAnimating];
        }
    }
    return cell;
}


#pragma mark- UserLoaderDelegate
-(void)UserLoader:(UserLoader*)userLoader didChangeGroup:(User*)currentUser{
    if(currentUser!=nil)
    {
        NSLog(@"GroupJoinViewController.currentUser.userId=%i", currentUser.userId);
        if(currentUser.currentGroup!=nil)
        {
            NSLog(@"GroupJoinViewController.currentUser.currentGroup.hashId=%@", currentUser.currentGroup.hashId);
            if(currentUser.currentGroup.hashId!=nil)
            {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:currentUser.currentGroup.hashId forKey:@"current_group_hash"];
                [userDefaults synchronize];
                
                [self.userLoader submitSQLRequestUpdateCurrentGroup:currentUser.currentGroup.hashId andUserId:currentUser.userId];
                
            }
        }
    }
}




#pragma mark- GroupLoaderDelegate
-(void)GroupLoader:(GroupLoader *)groupLoader didLoadGroups:(NSArray *)groups{
    //NSLog(@"[groups count]=%i", [groups count]);
    _groups = groups;
    [self.collectionView reloadData];
}

-(void)GroupLoader:(GroupLoader *)groupLoader didFailWithError:(NSError *)errors{
    NSLog(@"GroupJoinViewController. Group failed to load.");
    /*
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Groups", nil) message:errors.description delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
    */
}

#pragma mark - PhotoLoaderDelegate
-(void)PhotoLoader:(PhotoLoader *)photoLoader didLoadPhotos:(NSArray *)photos forObject:(NSObject*)obj{
    NSIndexPath *indexPath = (NSIndexPath*)obj;
    [photoLoadersInProgress removeObjectForKey:indexPath];
    if (photos.count > 0){
        //Photo* photo = [photos objectAtIndex:arc4random_uniform(photos.count)];
        Photo* photo = [photos objectAtIndex:0];
        
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //NSString* imageName = [NSString stringWithFormat:@"%i.png", currentPage];
        NSString* imageName = [NSString stringWithFormat:@"panelPhoto%i.png", photo.photoId];
        NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
        BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        //NSLog(@"alignPageinPanelScrollView. Panel[%i].[%@] File exists=%d", currentPanel.panelId, imageName, fileExists);
        if(!fileExists)
        {
            [groupImages setObject:photo.imageURL forKey:indexPath];
            
            [imageView setImageWithURL:[NSURL URLWithString:photo.imageURL]
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
            //NSLog(@"GroupJoinViewController. Group photo Loading image from file=%@", imageName);
            //NSError* err;
            //[fileMgr removeItemAtPath:currentFile error:&err];
            //[imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
            [groupImages setObject:currentFile forKey:indexPath];
        }//end if(fileExists)
        
        
        //NSLog(@"photo.imageURL=%@", photo.imageURL)
        //[groupImages setObject:photo.imageURL forKey:indexPath];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        });
        
        //[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        
        //[groupImages setObject:image forKey:indexPath];
        //[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        
        //ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[APIWrapper getAbsoluteURLUsingImageRelativePath:[photo imageURL]]];
        /*
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[photo imageURL]];
        imageDownloader.obj = indexPath;
        imageDownloader.delegate = self;
        if (imageDownloader.image == nil)
            [imageDownloadersInProgress setObject:imageDownloader forKey:indexPath];
         */
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
    NSLog(@"didLoadImage");
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
