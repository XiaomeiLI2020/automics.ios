//
//  GroupsViewController.m
//  PhotoChat
//
//  Created by Shakir Ali on 12/03/2013.
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

#define QRCODE_SIZE 200

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
    UIImage* qrcodeImage = [self generateQRCodeImageForURL:url];
    QRView *qrView = [[QRView alloc] initWithFrame:CGRectMake(abs(self.view.frame.size.width / 2.0 - QRCODE_SIZE/2.0), abs(self.view.frame.size.height / 2.0 - QRCODE_SIZE/2.0), QRCODE_SIZE, QRCODE_SIZE) image:qrcodeImage];
    [self.view addSubview:qrView];
}

-(UIImage*)generateQRCodeImageForURL:(NSString*)url{
    DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:url];
    UIImage* qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:250];
    return qrcodeImage;
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
