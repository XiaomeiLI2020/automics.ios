//
//  PhotoLoader.h
//  scaleView
//
//  Created by horizon on 28/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "ImageDownloader.h"
#import "Photo.h"

@protocol PhotoLoaderDelegate;

@interface PhotoLoader : DataLoader
@property (weak) id<PhotoLoaderDelegate> delegate;
-(void)submitRequestPostPhoto:(Photo*)photo;
@end

@protocol PhotoLoaderDelegate<NSURLConnectionDataDelegate>
@optional
-(void)PhotoLoader:(PhotoLoader*)photoLoader didUploadPhoto:(Photo*)photo;
-(void)PhotoLoader:(PhotoLoader*)photoLoader didFailWithError:(NSError*)error;
@end