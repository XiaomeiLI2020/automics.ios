//
//  ImageDownloader.m
//  PhotoChat
//
//  Created by Shakir Ali on 19/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader (){
    BOOL downloading;
}

@property NSURL *imageURL;
@end

@implementation ImageDownloader

@synthesize delegate;
@synthesize imageURL;
@synthesize image;
@synthesize obj;

-(id)initWithImageURL:(NSString*)url{
    self = [super init];
    if (self){
        if (url != nil ){
            imageURL = [[NSURL alloc] initWithString:url];
        }
        downloading = NO;
    }
    return self;
}

-(UIImage*)image{
    if (image == nil && !downloading && (imageURL != nil)){
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:imageURL];
        [self submitURLRequest:urlRequest];
        downloading = YES;
    }
    return image;
}

#pragma mark NSURLConnectionDelegate functions.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"imageDownloader.connectionDidFinishLoading.[self.downloadedData.length]=%i", self.downloadedData.length);
    [super connectionDidFinishLoading:connection];
    downloading = NO;
    image = [UIImage imageWithData:self.downloadedData];
    if ([self.delegate respondsToSelector:@selector(imageDownloader:didLoadImage:forObject:)]){
        [self.delegate imageDownloader:self didLoadImage:image forObject:obj];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    downloading = NO;
    [super connection:connection didFailWithError:error];
    if ([self.delegate respondsToSelector:@selector(imageDownloader:didFailWithError:)]){
        [self.delegate imageDownloader:self didFailWithError:error];
    }
}

-(void)cancelImageDownload{
    [self cancelRequest];
    downloading = NO;
    image = nil;
}

@end
