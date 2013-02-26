//
//  ImageDownloader.h
//  PhotoChat
//
//  Created by Shakir Ali on 19/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataLoader.h"

@protocol ImageDownloaderDelegate;

@interface ImageDownloader : DataLoader{
    UIImage *image;
}
@property (weak) id<ImageDownloaderDelegate> delegate;
@property (readonly) UIImage* image;

-(id)initWithImageURL:(NSString*)imageURL;
@end

@protocol ImageDownloaderDelegate <NSObject>
@optional
-(void)imageDownloader:(ImageDownloader*)imageDownloader didLoadImage:(UIImage*)image;
-(void)imageDownloader:(ImageDownloader *)imageDownloader didFailWithError:(NSError*)error;
@end