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

bool photosDownloaded = NO;
//NSString* currentGroupHashId;

@synthesize photoRequestType;
@synthesize delegate;
@synthesize obj;
@synthesize currentGroupHashId;

-(void)submitRequestPostPhoto:(Photo*)photo{
    photoRequestType = kPostPhoto;
    NSLog(@"ak: PhotoLoader->submitRequestPostPhoto: %@", photo.name); //ak
    NSURLRequest* urlRequest = [self preparePhotoRequestForPostPhoto:photo];
    [self submitPhotoRequest:urlRequest];
}

-(void)submitRequestGetPhotoWithId:(int)photoId{
    photoRequestType = kGetPhoto;
    
    int photoExists = [self submitSQLRequestCheckPhotoExists:photoId];
    if(photoExists==0)
    {
        if([self isReachable])
        {
            NSURLRequest* urlRequest = [self preparePhotoRequestForGetPhotoWithId:photoId];
            [self submitPhotoRequest:urlRequest];
        }//end if([self isReachable])
        
    }//end if(photoExists==0)
    else if(photoExists>0)
    {
        //NSLog(@"PhotoLoader. submitRequestGetPhotoWithId.photoId#%i downloaded from database.", photoId);
        NSArray* photosLocal = [self convertPhotoSQLIntoPhoto:photoId];
        if(photosLocal!=nil && [photosLocal count]>0)
        {
            Photo* photo = [photosLocal objectAtIndex:0];
            if(photo!=nil)
            {
                if ([self.delegate respondsToSelector:@selector(PhotoLoader:didLoadPhoto:)])
                    [self.delegate PhotoLoader:self didLoadPhoto:photo];
            }//end if(photo!=nil)
        }//end if(photosLocal!=nil)
        
        
    }////end if(photoExists>0)

}

-(void)submitRequestGetPhotosForGroup:(NSString*)groupHashId{
    currentGroupHashId = groupHashId;
    int photosDownloaded = [self submitSQLRequestCheckPhotosDownloadedForGroup:groupHashId];
    //NSLog(@"PhotoLoader.submitRequestGetPhotosForGroup. groupHashId=%@, photosDownloaded=%i", groupHashId, photosDownloaded);
    
    if(photosDownloaded==0 && [self isReachable])
    {
        photosDownloaded = YES;
        photoRequestType = kGetPhotosForGroup;
        NSURLRequest *urlRequest = [self prepareRequestForGetPhotosForGroup:groupHashId];
        [self submitPhotoRequest:urlRequest];
    }
    else{
        //NSLog(@"PhotoLoader.Photos downloaded from the database.");
        NSArray *photos = [self convertPhotosSQLIntoPhotos:groupHashId];
        if(photos!=nil)
        {
            if ([self.delegate respondsToSelector:@selector(PhotoLoader:didLoadPhotos:forObject:)])
                [self.delegate PhotoLoader:self didLoadPhotos:photos forObject:obj];
        }
    }
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
    //NSLog(@"prepareRequestForGetPhotosForGroup.photoURL=%@", photoURL);
    NSURL* url = [NSURL URLWithString:photoURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)prepareRequestForGetPhotosForTheme:(int)themeId{
    NSString *photoURL = [APIWrapper getURLForGetPhotosForTheme:themeId];
    photoURL = [self authenticatedGetURL:photoURL];
    //NSLog(@"photoURL=%@", photoURL);
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
    NSLog(@"PhotoLoader->handlePostPhoto: [self.delegate PhotoLoader:self didUploadPhoto:photo]");
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
    NSLog(@"PhotoLoader->handleGetPhotoWithId");
    NSError* error;
    NSDictionary* photodict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (photodict != nil){
        Photo *photo = [PhotoJSONHandler convertPhotoJSONIntoPhoto:photodict];
        if(photo!=nil)
        {
            //NSLog(@"PhotoLoader.handleGetPhotoWithId. photoId=%i", photo.photoId);
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
            
            NSMutableArray* photos = [[NSMutableArray alloc] init];
            [photos addObject:photo];
            [self submitSQLRequestSavePhotos:photos andGroupHashId:currentGroupHashId];
            
            if ([self.delegate respondsToSelector:@selector(PhotoLoader:didLoadPhoto:)])
                [self.delegate PhotoLoader:self didLoadPhoto:photo];
        }

    }else{
        [self reportErrorToDelegate:error];
    }
}


-(void)handleGetPhotosForGroup{
    NSLog(@"PhotoLoader->handleGetPhotosForGroup");
    NSError* error;
    NSArray* photosJSON = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (photosJSON != nil){
        NSArray *photos = [PhotoJSONHandler convertPhotosJSONArrayIntoPhotos:photosJSON];
        //NSLog(@"handleGetPhotosForGroup.currentGroupHashId=%@", currentGroupHashId);
        [self submitSQLRequestSaveAllPhotos:photos andGroupHashId:currentGroupHashId];
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
    NSLog(@"PhotoLoader->connectionDidFinishLoading, photoRequestType: %i", photoRequestType);
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
