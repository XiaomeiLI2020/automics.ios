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

#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"
#import "AppDelegate.h"

@interface PhotoLoader ()
@property int photoRequestType;
@end

@implementation PhotoLoader

int const kPostPhoto = 1;
int const kGetPhotosForGroup = 2;
int const kGetPhoto = 3;
int const kGetPhotosForTheme = 4;

@synthesize photoRequestType;
@synthesize delegate;
@synthesize obj;

-(void)submitRequestPostPhoto:(Photo*)photo{
    photoRequestType = kPostPhoto;
    NSURLRequest* urlRequest = [self preparePhotoRequestForPostPhoto:photo];
    [self submitPhotoRequest:urlRequest];
}

-(void)submitRequestGetPhotoWithId:(int)photoId{
    /*
     panelRequestType = kGetPanel;
     NSURLRequest* urlRequest = [self preparePanelRequestForGetPanelWithId:panelId];
     [self submitPanelRequest:urlRequest];
     */
    photoRequestType = kGetPhoto;
    NSURLRequest* urlRequest = [self preparePhotoRequestForGetPhotoWithId:photoId];
    [self submitPhotoRequest:urlRequest];
}

-(void)submitRequestGetPhotosForGroup:(NSString*)groupHashId{
    photoRequestType = kGetPhotosForGroup;
    NSURLRequest *urlRequest = [self prepareRequestForGetPhotosForGroup:groupHashId];
    [self submitPhotoRequest:urlRequest];
}

-(void)submitRequestGetPhotosForTheme:(int)themeId{
    photoRequestType = kGetPhotosForTheme;
    NSURLRequest *urlRequest = [self prepareRequestForGetPhotosForTheme:themeId];
    [self submitPhotoRequest:urlRequest];
}

-(NSURLRequest*)preparePhotoRequestForGetPhotoWithId:(int)photoId{
    NSString* photoURL = [APIWrapper getURLForGetPhotoWithId:photoId];
    NSString* authenticatedPhotoURL = [self authenticatedGetURL:photoURL];
    NSURL* url = [NSURL URLWithString:authenticatedPhotoURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)preparePhotoRequestForPostPhoto:(Photo*)photo{
    NSString *photoURL = [APIWrapper getURLForPostPhoto];
    self.httpMethod = @"POST";
    self.request = photoURL;
    self.postRequestType = 0;
    NSURL* url = [NSURL URLWithString:photoURL];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self setPhotoPostData:photo InURLRequest:urlRequest];
    return urlRequest;
}

-(NSURLRequest*)prepareRequestForGetPhotosForGroup:(NSString*)groupHashId{
    NSString *photoURL = [APIWrapper getURLForGetPhotosForGroup:groupHashId];
    photoURL = [self authenticatedGetURL:photoURL];
    NSLog(@"photoURL=%@", photoURL);
    NSURL* url = [NSURL URLWithString:photoURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)prepareRequestForGetPhotosForTheme:(int)themeId{
    NSString *photoURL = [APIWrapper getURLForGetPhotosForTheme:themeId];
    photoURL = [self authenticatedGetURL:photoURL];
    NSLog(@"photoURL=%@", photoURL);
    NSURL* url = [NSURL URLWithString:photoURL];
    return [NSURLRequest requestWithURL:url];
}

-(void)setPhotoPostData:(Photo*)photo InURLRequest:(NSMutableURLRequest*)urlRequest{
    NSDictionary* photodict = [PhotoJSONHandler convertPhotoIntoPhotoJSON:photo];
    photodict = [self authenticatedPostData:photodict];
    photodict = [PhotoJSONHandler wrapJSONDictWithDataTag:photodict];
    self.dict = photodict;
    NSError *error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:photodict options:NSJSONWritingPrettyPrinted error:&error];
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
        Photo *photo = [PhotoJSONHandler convertPhotoJSONIntoPhoto:photodict];
        if ([self.delegate respondsToSelector:@selector(PhotoLoader:didUploadPhoto:)])
            [self.delegate PhotoLoader:self didUploadPhoto:photo];
    }else{
        [self reportErrorToDelegate:error];
    }
}

-(void)handleGetPhotoWithId{
    NSError* error;
    NSDictionary* photodict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (photodict != nil){
        Photo *photo = [PhotoJSONHandler convertPhotoJSONIntoPhoto:photodict];
        if ([self.delegate respondsToSelector:@selector(PhotoLoader:didLoadPhoto:)])
            [self.delegate PhotoLoader:self didLoadPhoto:photo];
    }else{
        [self reportErrorToDelegate:error];
    }
}


-(void)handleGetPhotosForGroup{
    NSError* error;
    NSArray* photosJSON = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (photosJSON != nil){
        NSArray *photos = [PhotoJSONHandler convertPhotosJSONArrayIntoPhotos:photosJSON];
        if ([self.delegate respondsToSelector:@selector(PhotoLoader:didLoadPhotos:forObject:)])
                [self.delegate PhotoLoader:self didLoadPhotos:photos forObject:obj];
        else{
            [self reportErrorToDelegate:error];
        }
    }
}

-(void)reportErrorToDelegate:(NSError*)error{
    if ([self.delegate respondsToSelector:@selector(PhotoLoader:didFailWithError:)])
        [delegate PhotoLoader:self didFailWithError:error];
}


#pragma mark NSURLConnectionDataDelegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [super connectionDidFinishLoading:connection];
    //DLog(@"self.downloadedData.length=%i", self.downloadedData.length);
    if (self.downloadedData.length > 0){
        switch (photoRequestType){
            case kPostPhoto:
                [self handlePostPhoto];
                break;
            case kGetPhotosForGroup:
                [self handleGetPhotosForGroup];
                break;
            case kGetPhoto:
                [self handleGetPhotoWithId];
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
