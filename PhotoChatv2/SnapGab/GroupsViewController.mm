//
//  GroupsViewController.m
//  scaleView
//
//  Created by horizon on 12/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "GroupsViewController.h"
#import "GroupCell.h"
#import "APIWrapper.h"
#import "QREncoder.h"
#import "QRView.h"

@interface GroupsViewController ()
@property NSArray* groups;
@end

@implementation GroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadGroups];
    self.collectionView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    [self.collectionView registerClass:[GroupCell class] forCellWithReuseIdentifier:@"GROUP_CELL"];
}

-(void)loadGroups{
    GroupLoader *groupLoader = [[GroupLoader alloc] init];
    groupLoader.delegate = self;
    [groupLoader submitRequestGetGroups];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    GroupCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"GROUP_CELL" forIndexPath:indexPath];
    cell.group = [_groups objectAtIndex:indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Group *group = [_groups objectAtIndex:indexPath.item];
    NSString *url = [NSString stringWithFormat:@"%@/%@",[APIWrapper getURLForGetGroup],[group hashId]];
    
    DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:url];
    
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:250];
    CGRect imageFrame = CGRectMake(60, 100, qrcodeImage.size.width, qrcodeImage.size.height);
    UIImageView* qrcodeImageView = [[UIImageView alloc] initWithFrame:imageFrame];
    [qrcodeImageView setImage:qrcodeImage];
    
    QRView *qrView = [[QRView alloc] initWithFrame:CGRectMake(abs(self.view.frame.size.width / 2.0 - 200/2.0), abs(self.view.frame.size.height / 2.0 - 200/2.0), 200, 200) image:qrcodeImage];
    [self.view addSubview:qrView];
    
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_groups != nil)
        return [_groups count];
    else
        return 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- GroupLoaderDelegate
-(void)GroupLoader:(GroupLoader *)groupLoader didLoadGroups:(NSArray *)groups{
    _groups = groups;
    [self.collectionView reloadData];
}

-(void)GroupLoader:(GroupLoader *)groupLoader didFailWithError:(NSError *)errors{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Groups", nil) message:errors.description delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];

}

@end
