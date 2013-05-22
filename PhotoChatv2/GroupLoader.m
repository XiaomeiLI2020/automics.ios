//
//  GroupLoader.m
//  PhotoChat
//
//  Created by Umar Rashid on 05/03/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "GroupLoader.h"
#import "APIWrapper.h"
#import "GroupJSONHandler.h"

@interface GroupLoader ()
@property int groupRequestType;
@end

@implementation GroupLoader

int const kGetGroups = 0;

@synthesize groupRequestType;
@synthesize delegate;

-(void)submitRequestGetGroups{
    groupRequestType = kGetGroups;
    NSURLRequest* urlRequest = [self prepareRequestForGetGroups];
    [self submitGroupRequest:urlRequest];
    
}

-(NSURLRequest*)prepareRequestForGetGroups{
    NSString* groupURL = [APIWrapper getURLForGetGroups];
    NSString* authenticatedGroupURL = [self authenticatedGetURL:groupURL];
    //NSLog(@"authenticatedGroupURL=%@", authenticatedGroupURL);
    NSURL* url = [NSURL URLWithString:authenticatedGroupURL];
    return [NSURLRequest requestWithURL:url];
}

-(void)submitGroupRequest:(NSURLRequest*)urlRequest{
    [self initConnectionRequest];
    [self submitURLRequest:urlRequest];
}

-(void)handleGetGroupsResponse{
    NSError* error;
    NSArray* groupJSON = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (groupJSON != nil){
        NSArray* groups = [GroupJSONHandler convertGroupsJSONIntoGroups:groupJSON];
        if ([self.delegate respondsToSelector:@selector(GroupLoader:didLoadGroups:)])
            [self.delegate GroupLoader:self didLoadGroups:groups];
    }
    
}

-(void)reportErrorToDelegate:(NSError*)error{
    if ([self.delegate respondsToSelector:@selector(GroupLoader:didFailWithError:)])
        [delegate GroupLoader:self didFailWithError:error];
}


#pragma mark NSURLConnectionDataDelegate methods
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [super connectionDidFinishLoading:connection];
    if (self.downloadedData.length > 0){
        switch (groupRequestType){
            case kGetGroups:
                [self handleGetGroupsResponse];
                break;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [super connection:connection didFailWithError:error];
    [self reportErrorToDelegate:error];
}


@end
