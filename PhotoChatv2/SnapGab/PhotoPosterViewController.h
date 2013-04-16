//
//  PhotoPosterViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 11/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PanelLoader.h"
#import "PhotoLoader.h"
#import "MKNetworkOperation.h"
#import "AutomicsEngine.h"

@interface PhotoPosterViewController : UIViewController
<PanelLoaderDelegate, UIScrollViewDelegate,  PhotoLoaderDelegate, MKNetworkOperationDelegate, UIAlertViewDelegate, MKNetworkEngineDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) UIImage *image;
@property NSString* imageURL;

@property PanelLoader* panelsLoader;
@property PhotoLoader* photoLoader;
@property BOOL editMode;
@property Photo* editedPhoto;
@property NSMutableArray* placementsArray;
@property NSMutableArray* annotationsArray;

@property MainScrollSelector *panelScrollView;

- (IBAction)cancelPressed:(id)sender;

@end
