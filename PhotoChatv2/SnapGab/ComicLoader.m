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

@end

@implementation ComicLoader


int const kGetGroupComics = 0;
int const kGetComic = 1;
int const kPostComic = 2;

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


-(void)submitRequestPostComic:(Comic*)comic{
    comicRequestType = kPostComic;
    NSURLRequest* urlRequest = [self prepareComicRequestForPostComic:comic];
    [self submitComicRequest:urlRequest];
}

-(void)submitComicRequest:(NSURLRequest*)urlRequest{
    [self initConnectionRequest];
    [self submitURLRequest:urlRequest];
}

-(NSURLRequest*)prepareComicRequestForGroup:(int)groupId{
    NSString *comicURL = [APIWrapper getURLForGetComics];
    NSString* authenticatedPanelURL = [self authenticatedGetURL:comicURL];
    NSURL* url = [NSURL URLWithString:authenticatedPanelURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)prepareComicRequestForGetComicWithId:(int)comicId{
    NSString* comicURL = [APIWrapper getURLForGetComicWithId:comicId];
    NSString* authenticatedComicURL = [self authenticatedGetURL:comicURL];
    //NSLog(@"authenticatedComicURL=%@", authenticatedComicURL);
    NSURL* url = [NSURL URLWithString:authenticatedComicURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)prepareComicRequestForPostComic:(Comic*)comic{
    NSString *comicURL = [APIWrapper getURLForGetComics];
    NSURL* url = [NSURL URLWithString:comicURL];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self setComicPostData:comic InURLRequest:urlRequest];
    return urlRequest;
}


-(void)setComicPostData:(Comic*)comic InURLRequest:(NSMutableURLRequest*)urlRequest{

    NSDictionary* comicdict = [ComicJSONHandler convertComicIntoComicJSON:comic];
    comicdict = [self authenticatedPostData:comicdict];
    comicdict = [ComicJSONHandler wrapJSONDictWithDataTag:comicdict];
    NSError *error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:comicdict options:NSJSONWritingPrettyPrinted error:&error];
    
    // NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // NSLog(@"panelData: %@", responseString);
    
    
    [urlRequest setHTTPBody:data];

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
            case kPostComic:
                [self handlePostComicResponse];
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

-(void)handlePostComicResponse{
    NSError* error;
    NSDictionary* comicdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    
    if (comicdict != nil){
        //Comic *comic = [ComicJSONHandler convertComicJSONDictIntoComic:comicdict];
        
        NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
        //NSLog(@"panelData: %@", responseString);
         
        if ([self.delegate respondsToSelector:@selector(ComicLoader:didSaveComic:)])
            [self.delegate ComicLoader:self didSaveComic:responseString];
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
