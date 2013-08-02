//
//  GroupLeaveViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 10/06/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "GroupLeaveViewController.h"
#import "GroupCollectionViewCell.h"
#import "APIWrapper.h"
#import "GroupCollectionViewLayout.h"
#import "DataLoader.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface GroupLeaveViewController ()

@property NSArray* groups;
@property NSMutableDictionary *groupImages;
@property NSMutableDictionary* photoLoadersInProgress;
@property NSMutableDictionary* imageDownloadersInProgress;

@end

@implementation GroupLeaveViewController

@synthesize photoLoadersInProgress;
@synthesize imageDownloadersInProgress;
@synthesize groupImages;
@synthesize userLoader;
@synthesize groupsButton;
@synthesize leaveGroupLabel;

BOOL alertShown;
NSString* groupHashId;
DataLoader* dataLoader;
NSString *pCellID = @"GROUP_CELL";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backgroundImage;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        //NSLog(@"This is iPhone 5");
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background@x5.png"]];
        [backgroundImage setFrame:CGRectMake(0, 0, 320, 568)];
    }
    else
    {
        //NSLog(@"This is iPhone 4");
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
        [backgroundImage setFrame:CGRectMake(0, 0, 320, 480)];
    }
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    [self.groupsButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.groupsButton.layer.borderWidth=4.0f;
    self.groupsButton.clipsToBounds = YES;
    self.groupsButton.layer.cornerRadius = 10;//half of the width
    [self.groupsButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    groupsButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 0.0, 0.0, 0.0);
    
    [leaveGroupLabel setFont:[UIFont fontWithName: @"Transit Display" size:28]];
    
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
    
    if([[segue identifier] isEqualToString:@"leavetogroupsmenu"])
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
    
    //NSLog(@"Group join request approved.");
    if(currentUser!=nil)
    {
        /*
         user.userId = currentUser.userId;
         user.groupHashId = currentUser.groupHashId;
         
         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
         [userDefaults setObject:user.currentSession.token forKey:@"session"];
         [userDefaults setObject:user.groupHashId forKey:@"group"];
         [userDefaults setObject:[NSNumber numberWithInt:user.userId] forKey:@"user_id"];
         [userDefaults synchronize];
         */
    }
    
}

-(void)UserLoader:(UserLoader*)loader didLeaveGroup:(NSString*)responseString{
    
    if([responseString isEqualToString:@"true"])
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* currentGroupHashId = [userDefaults objectForKey:@"current_group_hash"];
        int userId = [[userDefaults objectForKey:@"user_id"] integerValue];
        NSLog(@"Left group.%@, currentGroupHashId=%@, userId=%i", groupHashId, currentGroupHashId, userId);
        
        //if left the current group
        if([currentGroupHashId isEqualToString:groupHashId])
        {
            [userDefaults setObject:nil forKey:@"current_group_hash"];
            //[userDefaults setObject:nil forKey:@"current_group_name"];
            
            //[userLoader submitRequestPostSetCurrentGroup:userId andNewGroupHashId:nil];
        }

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
        NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
        NSLog(@"currentGroupHashId=%@, selectedGroupHashId=%@", currentGroupHashId, groupHashId);
        
        User* user = [[User alloc] init];
        user.email = email;
        user.password = password;
        
        //NSLog(@"email=%@, password=%@", user.email, user.password);
        [userLoader submitRequestDeleteFromGroup:groupHashId];
        //[userLoader submitRequestPostGenerateSessionToken:user];

        //[userLoader submitRequestPostJoinGroup:sessionToken andGroupHashId:groupHashId];
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

    
    if(!alertShown)
    {
        if([userLoader isReachable])
        {
            groupHashId = group.hashId;
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Leave Group"
                                  message: [NSString stringWithFormat:@"You will leave %@", group.name]
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
    }//end if(groupHashId!=nil && [groupHashId isEqualToString:group.hashId])
    else{
        
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
    }//end else
    */
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

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:pCellID forIndexPath:indexPath];
    Group *group = [_groups objectAtIndex:indexPath.item];
    [cell setGroup:group];
    //cell.label.text = group.name;
    
    [cell.label setFont:[UIFont fontWithName: @"Transit Display" size:20]];
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
        }//end if
        
        [cell.imageView.layer setBorderColor:[[UIColor blackColor] CGColor]];
        cell.imageView.layer.borderWidth=4.0f;
        cell.imageView.clipsToBounds = YES;
        
        
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

#pragma mark- GroupLoaderDelegate
-(void)GroupLoader:(GroupLoader *)groupLoader didLoadGroups:(NSArray *)groups{
    //NSLog(@"[groups count]=%i", [groups count]);
    _groups = groups;
    [self.collectionView reloadData];
}

-(void)GroupLoader:(GroupLoader *)groupLoader didFailWithError:(NSError *)errors{
    NSLog(@"GroupLeaveViewController. Group failed to load.");
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
        
        //[groupImages setObject:photo.imageURL forKey:indexPath];
        //[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        });
        /*
        //ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[APIWrapper getAbsoluteURLUsingImageRelativePath:[photo imageURL]]];
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
