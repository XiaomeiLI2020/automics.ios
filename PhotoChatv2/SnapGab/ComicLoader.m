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
BOOL comicsDownloaded = NO;
dispatch_queue_t backgroundQueue;
@synthesize delegate;
@synthesize comicRequestType;



-(void)submitRequestGetComicsForGroup:(int)groupId{
/*
    //if([self submitSQLRequestCountComicsForGroup:groupId]==0)
    //if(!comicsDownloaded)
    {
        comicRequestType = kGetGroupComics;
        comicsDownloaded = YES;
        NSURLRequest* urlRequest = [self prepareComicRequestForGroup:groupId];
        [self submitComicRequest:urlRequest];
    }
   
    
    else
    {
        //NSLog(@"[self submitSQLRequestCountComicsForGroup:groupId]=%i", [self submitSQLRequestCountComicsForGroup:groupId]);

        NSArray* comics = [self convertComicsSQLIntoComics:groupId];
        NSLog(@"comics downloaded from the database =%i.", [comics count]);
        if([self.delegate respondsToSelector:@selector(ComicLoader:didLoadComics:)])
            [self.delegate ComicLoader:self didLoadComics:comics];
    }
     */
 
}


-(void)submitRequestRefreshComicsForGroup{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
    
    //int groupExists = [self submitSQLRequestCheckGroupExists:currentGroupHashId];
    //NSLog(@"groupExists =%i", groupExists);
    //NSLog(@"currentGroupHashId =%@", currentGroupHashId);
    int comicsDownloaded = [self submitSQLRequestCheckComicsDownloadedForGroup:currentGroupHashId];
    //NSLog(@"comicsDownloaded =%i", comicsDownloaded);
    //if(comicsDownloaded==0)
    if([self isReachable])
    {
        //NSLog(@"comics refreshed from the server");
        comicRequestType = kGetGroupComics;
        comicsDownloaded = YES;
        NSURLRequest* urlRequest = [self prepareComicRequestForGroup];
        [self submitComicRequest:urlRequest];
    }
    //else if(comicsDownloaded==1)
    else if(![self isReachable])
    {
        NSArray* comics = [self convertComicsSQLIntoComics:currentGroupHashId];
        //NSLog(@"comics downloaded from the database =%i.", [comics count]);
        if([self.delegate respondsToSelector:@selector(ComicLoader:didLoadComics:)])
            [self.delegate ComicLoader:self didLoadComics:comics];
    }

}

-(void)submitRequestGetComicsForGroup{
    /*
     //if([self submitSQLRequestCountComicsForGroup:groupId]==0)
     //if(!comicsDownloaded)
     {
     comicRequestType = kGetGroupComics;
     comicsDownloaded = YES;
     NSURLRequest* urlRequest = [self prepareComicRequestForGroup:groupId];
     [self submitComicRequest:urlRequest];
     }
     
     
     else
     {
     //NSLog(@"[self submitSQLRequestCountComicsForGroup:groupId]=%i", [self submitSQLRequestCountComicsForGroup:groupId]);
     
     NSArray* comics = [self convertComicsSQLIntoComics:groupId];
     NSLog(@"comics downloaded from the database =%i.", [comics count]);
     if([self.delegate respondsToSelector:@selector(ComicLoader:didLoadComics:)])
     [self.delegate ComicLoader:self didLoadComics:comics];
     }
     */
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
    
    //int groupExists = [self submitSQLRequestCheckGroupExists:currentGroupHashId];
    //NSLog(@"groupExists =%i", groupExists);
    //NSLog(@"currentGroupHashId =%@", currentGroupHashId);
    int comicsDownloaded = [self submitSQLRequestCheckComicsDownloadedForGroup:currentGroupHashId];
    NSLog(@"current_group.comicsDownloaded=%i", comicsDownloaded);
    if(comicsDownloaded==0)
    {
        if([self isReachable])
        {
            comicRequestType = kGetGroupComics;
            comicsDownloaded = YES;
            NSURLRequest* urlRequest = [self prepareComicRequestForGroup];
            [self submitComicRequest:urlRequest];
        }

    }
    else if(comicsDownloaded==1)
    {
        NSArray* comics = [self convertComicsSQLIntoComics:currentGroupHashId];
        //NSLog(@"comics downloaded from the database =%i.", [comics count]);
        if([self.delegate respondsToSelector:@selector(ComicLoader:didLoadComics:)])
            [self.delegate ComicLoader:self didLoadComics:comics];
    }
    
}

-(void)submitRequestGetComicWithId:(int)comicId{
    
    int comicExists = [self submitSQLRequestCheckComicExists:comicId];
    NSLog(@"ComicLoader. comicExists=%i", comicExists);
    if(comicExists==0 && [self isReachable])
    //if(comicExists==0)
    {
        comicRequestType = kGetComic;
        NSURLRequest* urlRequest = [self prepareComicRequestForGetComicWithId:comicId];
        [self submitComicRequest:urlRequest];
    }
    else if(comicExists==1)
    {
        //NSLog(@"[self submitSQLRequestCheckComicExists:comicId]=%i", [self submitSQLRequestCheckComicExists:comicId]);
        NSArray* comics= [self convertComicSQLIntoComic:comicId];
        if(comics!=nil && [comics count]>0)
        {
            Comic* comic = [comics objectAtIndex:0];
            if(comic!=nil){
                if ([self.delegate respondsToSelector:@selector(ComicLoader:didLoadComic:)])
                    [self.delegate ComicLoader:self didLoadComic:comic];
            }//end if
        }//end if
    }
}


-(void)submitRequestPostComic:(Comic*)comic{
    comicRequestType = kPostComic;
    NSURLRequest* urlRequest = [self prepareComicRequestForPostComic:comic];
    [self submitComicRequest:urlRequest];
}

-(void)submitRequestPostComicCached:(Comic*)comic{
    comicRequestType = kPostComic;
    NSURLRequest* urlRequest = [self prepareComicRequestForPostComic:comic];
    [self submitComicRequest:urlRequest];
}

-(void)submitComicRequest:(NSURLRequest*)urlRequest{
    [self initConnectionRequest];
    [self submitURLRequest:urlRequest];
}

//-(NSURLRequest*)prepareComicRequestForGroup:(int)groupId{
-(NSURLRequest*)prepareComicRequestForGroup{
    NSString *comicURL = [APIWrapper getURLForGetComics];
    NSString* authenticatedComicURL = [self authenticatedGetURL:comicURL];
    NSURL* url = [NSURL URLWithString:authenticatedComicURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)prepareComicRequestForGetComicWithId:(int)comicId{
    NSString* comicURL = [APIWrapper getURLForGetComicWithId:comicId];
    NSString* authenticatedComicURL = [self authenticatedGetURL:comicURL];
    NSURL* url = [NSURL URLWithString:authenticatedComicURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)prepareComicRequestForPostComic:(Comic*)comic{
    NSString *comicURL = [APIWrapper getURLForGetComics];
    self.httpMethod = @"POST";
    self.request = comicURL;
    self.postRequestType = 2;
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
    self.dict = comicdict;
    NSError *error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:comicdict options:NSJSONWritingPrettyPrinted error:&error];
    
    // NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // NSLog(@"panelData: %@", responseString)
    [urlRequest setHTTPBody:data];
}

#pragma mark NSURLConnectionDelegate functions.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [super connectionDidFinishLoading:connection];
    //NSLog(@"self.downloadedData.length=%i", self.downloadedData.length);
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
        //[self submitSQLRequestSaveComics:comics];
  
        //backgroundQueue = dispatch_queue_create("com.razeware.imagegrabber.bgqueue", NULL);
        //dispatch_async(backgroundQueue, ^(void) {
        //    [self submitSQLRequestSaveComics:comics];
        //});
   
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
        
        [self submitSQLRequestSaveComicsForGroup:comics andGroupHashId:currentGroupHashId];
        
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
        Comic *comic = [ComicJSONHandler convertComicJSONDictIntoComic:comicdict];
        NSMutableArray* comics = [[NSMutableArray alloc] init];
        [comics addObject:comic];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
        [self submitSQLRequestSaveComicsForGroup:comics andGroupHashId:currentGroupHashId];
        
        NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
        NSLog(@"ComicData: %@", responseString);
        

        
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
