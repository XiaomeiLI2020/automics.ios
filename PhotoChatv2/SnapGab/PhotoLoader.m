//
//  PhotoLoader.m
//  scaleView
//
//  Created by horizon on 28/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "PhotoLoader.h"
#import "Photo.h"
#import "APIWrapper.h"
#import "PhotoJSONHandler.h"

@interface PhotoLoader ()
@property int photoRequestType;
@end

@implementation PhotoLoader

int const kPostPhoto = 1;
@synthesize photoRequestType;
@synthesize delegate;

-(void)submitRequestPostPhoto:(Photo*)photo{
    photoRequestType = kPostPhoto;
    NSURLRequest* urlRequest = [self preparePhotoRequestForPostPhoto:photo];
    [self submitPhotoRequest:urlRequest];

}

-(NSURLRequest*)preparePhotoRequestForPostPhoto:(Photo*)photo{
    NSString *photoURL = [APIWrapper getURLForPostPhoto];
    NSURL* url = [NSURL URLWithString:photoURL];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self setPhotoPostData:photo InURLRequest:urlRequest];
    return urlRequest;
}


-(void)setPhotoPostData:(Photo*)photo InURLRequest:(NSMutableURLRequest*)urlRequest{
    NSDictionary* photodict = [PhotoJSONHandler convertPhotoIntoPhotoJSON:photo];
    photodict = [PhotoJSONHandler wrapJSONDictWithDataTag:photodict];
    NSError *error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:photodict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *tempString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"string to post %@", tempString);
    [urlRequest setHTTPBody:data];
}

-(void)submitPhotoRequest:(NSURLRequest*)urlRequest{
    [self initConnectionRequest];
    [self submitURLRequest:urlRequest];
}

-(void)handlePostPhoto{
    NSError* error;
    NSDictionary* photodict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (photodict != nil){
        /*Photo *photo = [PhotoJSONHandler convertPhotoJSONDictIntoPhoto:photodict];
        if ([self.delegate respondsToSelector:@selector(PhotoLoader:didSavePhoto:)])
            [self.delegate PhotoLoader:self didSavePhoto:photo];
         */
    }
}

-(void)reportErrorToDelegate:(NSError*)error{
    if ([self.delegate respondsToSelector:@selector(PhotoLoader:didFailWithError:)])
        [delegate PhotoLoader:self didFailWithError:error];
}


#pragma mark NSURLConnectionDataDelegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [super connectionDidFinishLoading:connection];
    if (self.downloadedData.length > 0){
        switch (photoRequestType){
            case kPostPhoto:
                [self handlePostPhoto];
                break;
                
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [super connection:connection didFailWithError:error];
    [self reportErrorToDelegate:error];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    if ([self.delegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)])
        [self.delegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}

@end