//
//  ResourceLoader.m
//  PhotoChat
//
//  Created by Umar Rashid on 26/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ResourceLoader.h"

#import "APIConstant.h"
#import "ResourceJSONHandler.h"
#import "APIWrapper.h"

@interface ResourceLoader ()

@property int resourceRequestType;
@end

@implementation ResourceLoader


int const kGetThemeResources = 0;
int const kGetResource = 1;
int numResources;
//int numPanels;
BOOL resourcesLoaded = NO;


@synthesize delegate;
@synthesize resourceRequestType;
@synthesize obj;


-(void)submitRequestGetResourcesForTheme:(int)themeId{
    //NSLog(@"resourcesLoaded=%d", resourcesLoaded);
    if(!resourcesLoaded)
    {
        resourceRequestType = kGetThemeResources;
        NSURLRequest* urlRequest = [self prepareResourceRequestForTheme:themeId];
        [self submitResourceRequest:urlRequest];
        resourcesLoaded = YES;
    }

    else{
        //NSLog(@"submitRequestGetResourcesForTheme.Resources downloaded from the database.themeId=%i", themeId);
        NSArray* resources = [self convertResourcesSQLIntoResources:themeId];
        //NSLog(@"submitRequestGetResourcesForTheme.[resources count]=%i", [resources count]);
        if([self.delegate respondsToSelector:@selector(ResourceLoader:didLoadResources:)])
            [self.delegate ResourceLoader:self didLoadResources:resources];
        if ([self.delegate respondsToSelector:@selector(ResourceLoader:didLoadResources:forObject:)])
            [self.delegate ResourceLoader:self didLoadResources:resources forObject:obj];
    }

}

-(void)submitRequestGetResourceWithId:(int)resourceId{
    //NSLog(@"submitRequestGetResourceWithId");
    resourceRequestType = kGetResource;
    NSURLRequest* urlRequest = [self prepareResourceRequestForGetResourceWithResourceId:resourceId];
    [self submitResourceRequest:urlRequest];
}


-(void)submitRequestGetResourceWithResourceId:(int)resourceId{
    //NSLog(@"submitRequestGetResourceWithId");
    //If the resource is not in SQLite database, download it
    if([self submitSQLRequestCheckResourceExists:resourceId]==0)
    {
        //NSLog(@"Resource is not in the database yet.");
        resourceRequestType = kGetResource;
        NSURLRequest* urlRequest = [self prepareResourceRequestForGetResourceWithResourceId:resourceId];
        [self submitResourceRequest:urlRequest];
    }
    //If the resource is downloadeded
    else if([self submitSQLRequestCheckResourceExists:resourceId]>0)
    {
        //NSLog(@"Resource downloaded from the database.");
        NSArray* resources = [self convertResourceSQLIntoResource:resourceId];
        if(resources!=nil)
        {
            Resource* resource = [resources objectAtIndex:0];
            if(resource!=nil){
                if ([self.delegate respondsToSelector:@selector(ResourceLoader:didLoadResource:)])
                    [self.delegate ResourceLoader:self didLoadResource:resource];
            }//end if(resource!=nil)
        }//end if(resources!=nil)
    }
    /*
    resourceRequestType = kGetResource;
    NSURLRequest* urlRequest = [self prepareResourceRequestForGetResourceWithResourceId:resourceId];
    [self submitResourceRequest:urlRequest];
     */
}


-(void)submitResourceRequest:(NSURLRequest*)urlRequest{
    [self initConnectionRequest];
    [self submitURLRequest:urlRequest];
    
    
}


-(NSURLRequest*)prepareResourceRequestForTheme:(int)themeId{

    NSString *resourceURL = [APIWrapper getURLForGetResourcesWithTheme:themeId];
    //NSLog(@"prepareResourceRequestForTheme.resourceURL=%@", resourceURL);
    NSURL* url = [NSURL URLWithString:resourceURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)prepareResourceRequestForGetResourceWithId:(int)resourceId{
    NSString* resourceURL = [APIWrapper getURLForGetResourceWithId:resourceId];
    NSLog(@"resourceURL=%@", resourceURL);
    NSURL* url = [NSURL URLWithString:resourceURL];
    return [NSURLRequest requestWithURL:url];
}


-(NSURLRequest*)prepareResourceRequestForGetResourceWithResourceId:(int)resourceId{
    NSString* resourceURL = [APIWrapper getURLForGetResourceWithResourceId:resourceId];
    NSURL* url = [NSURL URLWithString:resourceURL];
    return [NSURLRequest requestWithURL:url];
}

#pragma mark NSURLConnectionDelegate functions.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [super connectionDidFinishLoading:connection];
    
    if(self.downloadedData.length > 0){
        switch (resourceRequestType){
            case kGetThemeResources:
                [self handleGetResourcesForThemeResponse];
                break;
            case kGetResource:
                [self handleGetResourceWithIdResponse];
                break;
                
        }//end switch
    }//end if(self.downloadedData.length > 0)
}

-(void)handleGetResourcesForThemeResponse{
    NSError* error;
    NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (jsonArray != nil){
        
        //Update numPanels
        numResources = [jsonArray count];
        NSArray* resources = [ResourceJSONHandler getResourcesFromResourcesJSON:jsonArray];
        [self submitSQLRequestSaveResources:resources];
        //NSLog(@"handleGetResourcesForThemeResponse.#of resources =%i", [resources count]);
        if([self.delegate respondsToSelector:@selector(ResourceLoader:didLoadResources:)])
            [self.delegate ResourceLoader:self didLoadResources:resources];
        if ([self.delegate respondsToSelector:@selector(ResourceLoader:didLoadResources:forObject:)])
            [self.delegate ResourceLoader:self didLoadResources:resources forObject:obj];
    }else{
        [self reportErrorToDelegate:error];
    }
}
 

-(void)handleGetResourceWithIdResponse{
    NSError* error;
    NSDictionary* resourcedict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    //NSLog(@"resourcedict=%i", [resourcedict count]);
    if (resourcedict != nil){
        Resource *resource = [ResourceJSONHandler getResourceFromResourceJSON:resourcedict];
        [self submitSQLRequestSaveResource:resource.resourceId andThemeId:1 andType:resource.type andImageURL:resource.imageURL andThumbURL:resource.thumbURL];
        
        if ([self.delegate respondsToSelector:@selector(ResourceLoader:didLoadResource:)])
            [self.delegate ResourceLoader:self didLoadResource:resource];

    }else{
        [self reportErrorToDelegate:error];
    }
}


-(void)reportErrorToDelegate:(NSError*)error{
    if ([self.delegate respondsToSelector:@selector(ResourceLoader:didFailWithError:)])
        [delegate ResourceLoader:self didFailWithError:error];
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


-(void)cancelResourceLoad{
    [self cancelRequest];
}


@end
