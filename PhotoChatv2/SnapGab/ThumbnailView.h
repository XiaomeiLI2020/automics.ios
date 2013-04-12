//
//  ThumbnailView.h
//  PhotoChat
//
//  Created by Umar Rashid on 09/04/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"
#import "Panel.h"
#import "PanelLoader.h"
#import "ResourceLoader.h"


@interface ThumbnailView : UIView
<ImageDownloaderDelegate, PanelLoaderDelegate, ResourceLoaderDelegate>

- (id)initWithFrame:(CGRect)frame andURL:(NSString*)url;
- (id)initWithFrame:(CGRect)frame andPanel:(Panel*)panel;
- (id)initWithURL:(NSString*)url;

@property ImageDownloader* imageDownloader;
@property PanelLoader* panelLoader;
@property ResourceLoader* resourceLoader;
@property UIImage* image;
@property Panel* panel;
@property UIImage* snapshot;
@end
