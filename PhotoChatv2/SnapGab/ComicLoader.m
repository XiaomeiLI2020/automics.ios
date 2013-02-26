//
//  ComicLoader.m
//  PhotoChat
//
//  Created by Shakir Ali on 22/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "ComicLoader.h"
#import "APIWrapper.h"
#import "ComicJSONHandler.h"

@interface ComicLoader ()
@property int comicRequestType;
@end

@implementation ComicLoader

int const kGetGroupComics = 0;
int const kGetComic = 1;

@synthesize delegate;
@synthesize comicRequestType;

-(void)submitRequestGetComicsForGroup:(int)groupId{
    comicRequestType = kGetGroupComics;
    NSURLRequest* urlRequest = [self prepareComicRequestForGroup:groupId];
    [self submitComicRequest:urlRequest];
}

-(void)submitRequestGetComicWithId:(int)comicId{
    comicRequestType = kGetComic;
    NSURLRequest* urlRequest = [self prepareComicRequestForGetComicWithId:comicId];
    [self submitComicRequest:urlRequest];
}

-(void)submitComicRequest:(NSURLRequest*)urlRequest{
    [self initConnectionRequest];
    [self submitURLRequest:urlRequest];
}

-(NSURLRequest*)prepareComicRequestForGroup:(int)groupId{
    NSString *comicURL = [APIWrapper getURLForGetComics];
    NSURL* url = [NSURL URLWithString:comicURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)prepareComicRequestForGetComicWithId:(int)comicId{
    NSString* comicURL = [APIWrapper getURLForGetComicWithId:comicId];
    NSURL* url = [NSURL URLWithString:comicURL];
    return [NSURLRequest requestWithURL:url];
}

#pragma mark NSURLConnectionDelegate functions.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [super connectionDidFinishLoading:connection];
    if (self.downloadedData.length > 0){
        switch (comicRequestType){
            case kGetGroupComics:
                [self handleGetComicsForGroupResponse];
                break;
            case kGetComic:
                [self handleGetComicWithIdResponse];
                break;
        }
    }
}

-(void)handleGetComicsForGroupResponse{
    NSError* error;
    NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (jsonArray != nil){
        NSArray* comics = [ComicJSONHandler convertComicsJSONArrayIntoComics:jsonArray];
        if([self.delegate respondsToSelector:@selector(ComicLoader:didLoadComics:)])
            [self.delegate ComicLoader:self didLoadComics:comics];
    }else{
        [self reportErrorToDelegate:error];
    }
}

-(void)handleGetComicWithIdResponse{
    NSError* error;
    NSDictionary* comicdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (comicdict != nil){
        Comic *comic = [ComicJSONHandler convertComicJSONDictIntoComic:comicdict];
        if ([self.delegate respondsToSelector:@selector(ComicLoader:didLoadComic:)])
            [self.delegate ComicLoader:self didLoadComic:comic];
    }else{
        [self reportErrorToDelegate:error];
    }
}

-(void)reportErrorToDelegate:(NSError*)error{
    if ([self.delegate respondsToSelector:@selector(ComicLoader:didFailWithError:)])
        [delegate ComicLoader:self didFailWithError:error];
}

-(void)downloadErrorWithErrorCode:(NSInteger)errorCode ForConnection:(NSURLConnection*) connection{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Application cannot download data. Please check your internet connection."
                                                         forKey:NSLocalizedDescriptionKey];
    NSError *error = [[NSError alloc] initWithDomain:@"" code:errorCode userInfo:userInfo];
    [self reportErrorToDelegate:error];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [super connection:connection didFailWithError:error];
    [self reportErrorToDelegate:error];
}

-(void)cancelComicLoad{
    [self cancelRequest];
}

@end
