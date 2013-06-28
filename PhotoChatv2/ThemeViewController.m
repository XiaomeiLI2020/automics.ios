//
//  ThemeViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 24/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ThemeViewController.h"
#import "Theme.h"
#import "GroupCollectionViewCell.h"
#import "APIWrapper.h"
#import "GroupCollectionViewLayout.h"
#import "ThemePreviewViewController.h"
#import "UIImageView+WebCache.h"

@interface ThemeViewController ()

@property NSMutableDictionary *themeImages;
@property NSMutableDictionary* photoLoadersInProgress;
@property NSMutableDictionary* imageDownloadersInProgress;

@end

@implementation ThemeViewController

@synthesize photoLoadersInProgress;
@synthesize imageDownloadersInProgress;
@synthesize themeImages;

BOOL alertShown;
NSString* groupHashId;
NSString *iCellID = @"GROUP_CELL";
int selectedThemeId;
Theme* selectedTheme;

@synthesize organisations;
@synthesize themes;
@synthesize organisationLoader;
@synthesize organisationCounter;
@synthesize themeScrollView;
@synthesize resourceScrollView;

float themeXOrigin = 0.0;
float themeYOrigin = 50.0;
float themeScrollViewWidth = 80.0;
float themeScrollViewHeight = 80.0;

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
    //NSLog(@"viewDidLoad");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //DataLoader* dataLoader = [[DataLoader alloc] init];
    //[dataLoader submitSQLRequestCreateTablesForGroup:1];
    
    organisationCounter=0;
    organisations = [[NSArray alloc] init];
    themes = [[NSMutableArray alloc] init];
    organisationLoader = [[OrganisationLoader alloc] init];
    organisationLoader.delegate = self;
    [organisationLoader submitRequestGetOrganisations];
    
    selectedThemeId = 0;
    alertShown = NO;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    groupHashId= [prefs objectForKey:@"current_group_hash"];
    //NSLog(@"ThemeViewController.groupHashId=%@", groupHashId);
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groupViewBackground"]];
    photoLoadersInProgress = [[NSMutableDictionary alloc] init];
    imageDownloadersInProgress = [[NSMutableDictionary alloc] init];
    themeImages = [[NSMutableDictionary alloc] init];
    [self.collectionView setCollectionViewLayout:[[GroupCollectionViewLayout alloc] init]];
    //[self initiateScrollViews];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initiateScrollViews
{
    //NSLog(@"initiateScrollView.numPanels=%i", numPanels);
    // Add panels scrollview
    CGRect panelFrame = CGRectMake(0, 50, 100, 320);
    themeScrollView = [[UIScrollView alloc] init];
    //panelScrollView = [[MainScrollSelector alloc] initWithFrame:panelFrame andItemSize:panelSize];
    themeScrollView.tag=0;
    themeScrollView.frame = panelFrame;
    //themeScrollView.backgroundColor = [UIColor redColor];
    //themeScrollView.delegate=self;
    [self.view addSubview:themeScrollView];
    
    UILabel *themeLabel = [[UILabel alloc] init];
    themeLabel.frame = CGRectMake(0, 0, 40, 40);
    themeLabel.text=@"Hello";
    [themeScrollView addSubview:themeLabel];

}

-(void)loadThemes
{
    //NSLog(@"ThemeViewController.loadThemes.");

    [self.collectionView reloadData];
    /*
    if([themes count]>0)
    {
        CGRect themeFrame = CGRectMake(themeXOrigin, themeYOrigin, themeScrollViewWidth, [themes count]*themeScrollViewHeight);
        themeScrollView = [[UIScrollView alloc] init];
        themeScrollView.tag=0;
        themeScrollView.frame = themeFrame;
        themeScrollView.backgroundColor = [UIColor redColor];
        //themeScrollView.delegate=self;
        [self.view addSubview:themeScrollView];

        for(int i=0; i<[themes count]; i++)
        //for(int i=0; i<5; i++)
        {
            Theme* theme = [themes objectAtIndex:0];
            if(theme!=nil){
                UILabel *themeLabel = [[UILabel alloc] init];
                themeLabel.frame = CGRectMake(0, i*themeScrollViewHeight, themeScrollViewWidth, themeScrollViewHeight);
                themeLabel.text=theme.name;
                themeLabel.tag = i;
                [themeScrollView addSubview:themeLabel];
                
                [resourceLoader submitRequestGetResourcesForTheme:theme.themeId];
            }//end if(theme!=nil)

        }//end for
        
    }//end if([themes count]>0)
    */ 
}



-(void)viewDidDisappear:(BOOL)animated{
    [self cancelPhotoLoadRequests];
    [self cancelImageDownloadRequests];
    [themeImages removeAllObjects];
    [super viewDidDisappear:animated];
}


-(void)loadPhotosForTheme:(Theme*)theme atIndexPath:(NSIndexPath *)indexPath{
    ResourceLoader* resourceLoader = [[ResourceLoader alloc] init];
    resourceLoader.delegate = self;
    resourceLoader.obj = indexPath;
    [resourceLoader submitRequestGetResourcesForTheme:theme.themeId];
    [photoLoadersInProgress setObject:resourceLoader forKey:indexPath];
}

-(void)cancelPhotoLoadRequests{
    NSArray *allPhotoLoaders = [self.photoLoadersInProgress allValues];
    [allPhotoLoaders makeObjectsPerformSelector:@selector(cancelRequest)];
    [self.photoLoadersInProgress removeAllObjects];
}

-(void)cancelPhotoLoadRequestForIndexPath:(NSIndexPath*)indexPath{
    //PhotoLoader *photoLoader = [photoLoadersInProgress objectForKey:indexPath];
    //[photoLoader cancelRequest];
    ResourceLoader *rLoader = [photoLoadersInProgress objectForKey:indexPath];
    [rLoader cancelRequest];
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


/*
 -(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
 
 if([[segue identifier] isEqualToString:@"preview"])
 {
     ThemePreviewViewController *tpvc = (ThemePreviewViewController*)[segue destinationViewController];
     tpvc.theme = selectedTheme;
     tpvc.themeId = selectedThemeId;
     
 }
 }
*/

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
        [groupLoader submitRequestPostThemeForGroup:groupHashId andThemeId:selectedThemeId];
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
    GroupCollectionViewCell* selectedGroupCell = (GroupCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    Theme* theme = [selectedGroupCell getTheme];
    if(theme!=nil)
    {
        selectedThemeId = theme.themeId;
        selectedTheme = theme;
        //NSLog(@"ThemeViewController.Get preview of theme: id=%i, selectedThemeId=%i", selectedTheme.themeId, selectedThemeId);
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        ThemePreviewViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ThemePreviewViewController"];
        viewController.theme = selectedTheme;
        viewController.themeId = selectedThemeId;
        //[self presentViewController:viewController animated:YES completion:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    /*
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
*/
}


-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [self cancelPhotoLoadRequestForIndexPath:indexPath];
    [self cancelImageDownloadRequestForIndexPath:indexPath];
    [themeImages removeObjectForKey:indexPath];
}


#pragma mark - UICollectionViewDataSourceDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (themes != nil)
        return [themes count];
    else
        return 0;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:iCellID forIndexPath:indexPath];
    Theme* theme = [themes objectAtIndex:indexPath.item];
    [cell setTheme:theme];

    //cell.label.text = group.name;
    if ([themeImages objectForKey:indexPath] != nil){
        
        id object= [themeImages objectForKey:indexPath];
        if([object isKindOfClass:[UIImage class]])
        {
            
            cell.imageView.image = [themeImages objectForKey:indexPath];
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
            }
        }
        

        
        //cell.imageView.image = [themeImages objectForKey:indexPath];
        [cell.activityIndicator stopAnimating];
    }else{
        // load the image for this cell
        if ([photoLoadersInProgress objectForKey:indexPath] == nil && [imageDownloadersInProgress objectForKey:indexPath] == nil){
            [self loadPhotosForTheme:theme atIndexPath:indexPath];
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
    NSLog(@"Selected theme %@", [[selectedGroupCell getTheme] name]);
}



#pragma mark OrganisationLoader functions.
-(void)OrganisationLoader:(OrganisationLoader*)loader didFailWithError:(NSError*)error{
    NSLog(@"organisation failed to load.");
}


-(void)OrganisationLoader:(OrganisationLoader*)loader didLoadOrganisations:(NSArray*)organisationsLocal{
    //NSLog(@"didLoadOrganisations");
    self.organisations = organisationsLocal;
    
    if(organisationCounter>=0 && organisationCounter<[self.organisations count])
    {
        Organisation* organisation = [organisations objectAtIndex:organisationCounter];
        if(organisation!=nil){
            [organisationLoader submitRequestGetOrganisation:organisation.organisationId];
        }
    }//end if
}

-(void)OrganisationLoader:(OrganisationLoader*)loader didLoadOrganisation:(Organisation*)organisation{
    //NSLog(@"didLoadOrganisation.");
    if(organisation!=nil)
    {
        Organisation* organisationLocal = [organisations objectAtIndex:organisationCounter];
        organisationLocal = organisation;
        
        
        for(int i=0; i<[organisation.themes count];i++)
        {
            Theme* theme = [organisation.themes objectAtIndex:i];
            //NSLog(@"theme.id=%i, theme.name=%@", theme.themeId, theme.name);
            [self.themes addObject:theme];
        }
        
        organisationCounter++;
        if(organisationCounter>=0 && organisationCounter<[self.organisations count])
        {
            Organisation* organisation = [organisations objectAtIndex:organisationCounter];
            if(organisation!=nil){
                [organisationLoader submitRequestGetOrganisation:organisation.organisationId];
            }
        }//end if

        if(organisationCounter==[self.organisations count])
        {
            //NSLog(@"ThemeViewController.All organisations loaded");
            [self loadThemes];
        }//end if

        
    }//end if
}

#pragma mark ResourceLoader functions.
-(void)ResourceLoader:(ResourceLoader *)loader didLoadResources:(NSArray*)resources forObject:(NSObject *)obj{
    //NSLog(@"ThemeViewController.resources loaded.");
    NSIndexPath *indexPath = (NSIndexPath*)obj;
    [photoLoadersInProgress removeObjectForKey:indexPath];
    if (resources.count > 0){
        //Resource* resource= [resources objectAtIndex:arc4random_uniform(resources.count)];
        Resource* resource= [resources objectAtIndex:0];
        //ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[APIWrapper getAbsoluteURLUsingImageRelativePath:[photo imageURL]]];
        
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        //NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //NSString* imageName = [NSString stringWithFormat:@"%i.png", currentPage];
        NSString* imageName = [NSString stringWithFormat:@"resource%i.png", resource.resourceId];
        NSString* currentFile = [documentsDirectory stringByAppendingPathComponent:imageName];
        BOOL fileExists = [fileMgr fileExistsAtPath:currentFile];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        //NSLog(@"alignPageinPanelScrollView. Panel[%i].[%@] File exists=%d", currentPanel.panelId, imageName, fileExists);
        if(!fileExists)
        {
            [themeImages setObject:resource.imageURL forKey:indexPath];
            
            [imageView setImageWithURL:[NSURL URLWithString:resource.imageURL]
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
            //NSLog(@"ThemeViewController. Resource photo Loading image from file=%@", imageName);
            //NSError* err;
            //[fileMgr removeItemAtPath:currentFile error:&err];
            //[imageView setImage:[UIImage imageWithContentsOfFile:currentFile]];
            [themeImages setObject:currentFile forKey:indexPath];
        }//end if(fileExists)

        //[themeImages setObject:image forKey:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        
        /*
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithImageURL:[resource imageURL]];
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

-(void)ResourceLoader:(ResourceLoader*)loader didLoadResource:(Resource*)resource
{
    //NSLog(@"Resource downloaded");
}




@end
