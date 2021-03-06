//
//  GroupsFlowViewController.m
//  scaleView
//
//  Created by horizon on 22/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "GroupsFlowViewController.h"
#import "GroupCollectionViewCell.h"
#import "APIWrapper.h"
#import "GroupCollectionViewLayout.h"
#import "QREncoder.h"
#import "GroupQRView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface GroupsFlowViewController ()
@property NSArray* groups;
@property NSMutableDictionary *groupImages;
@property NSMutableDictionary* photoLoadersInProgress;
@property NSMutableDictionary* imageDownloadersInProgress;
@end

@implementation GroupsFlowViewController

@synthesize photoLoadersInProgress;
@synthesize imageDownloadersInProgress;
@synthesize groupImages;
@synthesize groupsButton;
@synthesize inviteLabel;

BOOL alertShown;
NSString *kCellID = @"GROUP_CELL";
UIActivityIndicatorView* activityIndicator;
UILabel* clickLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    alertShown = NO;
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
    
    [inviteLabel setFont:[UIFont fontWithName: @"Transit Display" size:28]];
    
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activityIndicator.frame = CGRectMake(0, 40, 320, 320);
	activityIndicator.center = self.view.center;
	[self.view addSubview: activityIndicator];
    //[activityIndicator startAnimating];
    
    
    clickLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(0, 40, 320, 320)];
    clickLabel.textColor = [UIColor whiteColor];
    clickLabel.backgroundColor = [UIColor blackColor];
    //clickLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(36.0)];
    clickLabel.text = [NSString stringWithFormat: @"No groups exist. Please create a group."];
    [clickLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    
    //[self loadGroups];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groupViewBackground"]];
    photoLoadersInProgress = [[NSMutableDictionary alloc] init];
    imageDownloadersInProgress = [[NSMutableDictionary alloc] init];
    groupImages = [[NSMutableDictionary alloc] init];
    [self.collectionView setCollectionViewLayout:[[GroupCollectionViewLayout alloc] init]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [activityIndicator startAnimating];
    [self loadGroups];
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
    //[groupLoader submitRequestRefreshGroups];
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
    
    if([[segue identifier] isEqualToString:@"invitetogroupsmenu"])
    {
        //NSLog(@"prepareForSegue.comicAdd1");
        [self cleanupData];
        [self.collectionView removeFromSuperview];
        //[self cancelPanelLoadRequests];
        //[self cancelDownLoadRequests];
    }//end if
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    GroupCollectionViewCell* selectedGroupCell = (GroupCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    Group *group = [selectedGroupCell getGroup];
    NSString *url = [APIWrapper getURLForJoinGroupWithHashId:[group hashId]];
    
    //Shortening URL using bit.Ly login and API key
    NSString* bitLyLogin = @"urashid";
    NSString* bitLyAPIKey = @"R_4f9848d25ed8180c65991be731251456";
    
    NSString *shortenedURL = url;
    GroupLoader* groupLoader = [[GroupLoader alloc] init];
    if([groupLoader isReachable])
    {
        shortenedURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.bit.ly/v3/shorten?login=%@&apikey=%@&longUrl=%@&format=txt", bitLyLogin, bitLyAPIKey, url]] encoding:NSUTF8StringEncoding error:nil];
    }

    //NSLog(@"collectionView didSelectItemAtIndexPath.shortenedURL=%@", shortenedURL);
    
    if(!alertShown)
    {
        alertShown = YES;
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: [NSString stringWithFormat:@"Join %@", group.name]
                              message: [NSString stringWithFormat:@"%@", shortenedURL]
                              delegate: self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }

    
    /*
    UIImage* qrcodeImage = [self generateQRCodeImageForURL:url];
    GroupQRView *qrView = [[[NSBundle mainBundle] loadNibNamed:@"GroupQRView" owner:self options:nil] objectAtIndex:0];
    qrView.qrImageView.image = qrcodeImage;
    qrView.label.text = group.name;
    qrView.label.text = url;
    qrView.label.numberOfLines = 0; //will wrap text in new line
    
    
    CGSize size = qrView.frame.size;
    qrView.frame = CGRectMake(abs(self.collectionView.frame.size.width / 2.0 - size.width/2.0), abs(self.collectionView.frame.size.height / 2.0 - size.height/2.0), size.width, size.height);
    
    [self.view addSubview:qrView];
     */
}

-(UIImage*)generateQRCodeImageForURL:(NSString*)url{
    //NSLog(@"generateQRCodeImageForURL.url=%@", url);
    
    DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:url];
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:250];
    return qrcodeImage;
}

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
    GroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    Group *group = [_groups objectAtIndex:indexPath.item];
    [cell setGroup:group];
    
    [cell.label setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    //cell.label.text = group.name;
    /*
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
     */
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
        }
        
      
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
    _groups = groups;
    if([groups count]>0)
    {
        [clickLabel removeFromSuperview];
        [self.collectionView reloadData];
    }
    else{
        
        [self.view addSubview:clickLabel];
    }
    

    
    //[self.collectionView reloadData];
    [activityIndicator stopAnimating];
}

-(void)GroupLoader:(GroupLoader *)groupLoader didFailWithError:(NSError *)errors{
    NSLog(@"GroupFlowViewController. Group failed to load.");
    /*
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Groups", nil) message:errors.description delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
    */
}

#pragma mark - PhotoLoaderDelegate
-(void)PhotoLoader:(PhotoLoader *)photoLoader didLoadPhotos:(NSArray *)photos forObject:(NSObject *)obj{
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
            
            [imageView setImageWithURL:[NSURL URLWithString:[photo.imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                       placeholderImage:nil
                              completed:^(UIImage *imageDownloaded, NSError *error, SDImageCacheType cacheType)
             {
                 //NSLog(@"alignPageinPanelScrollView.saving image=%@", imageName);
                 NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(imageDownloaded)];
                 [data1 writeToFile:currentFile atomically:YES];
                 
             }];
            /*
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
             */
        }//end if(!fileExists)
        else if(fileExists)
        {
            //NSLog(@"GroupFlowViewController. Group photo Loading image from file=%@", imageName);
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
        alertShown = NO;
    }
}


@end