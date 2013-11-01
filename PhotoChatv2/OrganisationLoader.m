//
//  OrganisationLoader.m
//  PhotoChat
//
//  Created by Umar Rashid on 24/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "OrganisationLoader.h"
#import "APIWrapper.h"
#import "OrganisationJSONHandler.h"

@interface OrganisationLoader ()
@property int organisationRequestType;
@end

@implementation OrganisationLoader

int const kGetOrganisations = 0;
int const kGetOrganisation = 1;
int const kGetThemesForOrganisation = 2;

@synthesize organisationRequestType;
@synthesize delegate;

-(void)submitRequestGetOrganisations{
    organisationRequestType=kGetOrganisations;
    NSURLRequest* urlRequest = [self prepareRequestForGetOrganisations];
    [self submitOrganisationRequest:urlRequest];
}

-(void)submitRequestGetOrganisation:(int)organisationId{
    organisationRequestType=kGetOrganisation;
    NSURLRequest* urlRequest = [self prepareRequestGetOrganisation:organisationId];
    [self submitOrganisationRequest:urlRequest];
}

-(void)submitRequestGetThemesForOrganisation:(int)organisationId{
    organisationRequestType=kGetThemesForOrganisation;
    NSURLRequest* urlRequest = [self prepareRequestGetThemesForOrganisation:organisationId];
    [self submitOrganisationRequest:urlRequest];
}

-(void)handleGetOrganisationsResponse{
    NSError* error;
    NSArray* organisationJSON = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (organisationJSON != nil){
        NSArray* organisations = [OrganisationJSONHandler convertOrganisationsJSONIntoOrganisations:organisationJSON];
        /*
        for(int i=0;i<[organisations count]; i++)
        {
            Organisation* organisation = [organisations objectAtIndex:i];
            if(organisation!=nil)
            {
                NSLog(@"handleGetOrganisationsResponse.name=%@, id=%i, organisation.themes count=%i", organisation.name, organisation.organisationId, [organisation.themes count]);
                //[self submitRequestGetOrganisation:organisation.organisationId];
            }
        }
        */
        if ([self.delegate respondsToSelector:@selector(OrganisationLoader:didLoadOrganisations:)])
            [self.delegate OrganisationLoader:self didLoadOrganisations:organisations];
    }
    
}

-(void)handleGetOrganisationResponse{
    NSError* error;
    NSDictionary* organisationDict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (organisationDict != nil){
        Organisation* organisation = [OrganisationJSONHandler convertOrganisationJSONDictIntoOrganisation:organisationDict];
        /*
        if(organisation!=nil)
        {
            NSLog(@"handleGetOrganisationResponse.name=%@, id=%i, organisation.themes count=%i", organisation.name, organisation.organisationId, [organisation.themes count]);
        }
         */
         if ([self.delegate respondsToSelector:@selector(OrganisationLoader:didLoadOrganisation:)])
         [self.delegate OrganisationLoader:self didLoadOrganisation:organisation];

    }
    
}


-(void)handleGetThemesForOrganisationResponse{
    NSError* error;
    NSDictionary* organisationDict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (organisationDict != nil){
        Organisation* organisation = [OrganisationJSONHandler convertOrganisationJSONDictIntoOrganisation:organisationDict];
        /*
        if(organisation!=nil)
        {
            NSLog(@"handleGetThemesForOrganisationResponse.name=%@, id=%i, organisation.themes count=%i", organisation.name, organisation.organisationId, [organisation.themes count]);
        }
         */
        if ([self.delegate respondsToSelector:@selector(OrganisationLoader:didLoadThemesForOrganisation:)])
            [self.delegate OrganisationLoader:self didLoadThemesForOrganisation:organisation];
    }

}

-(NSURLRequest*)prepareRequestGetOrganisation:(int)organisationId
{
    NSString *organisationURL = [APIWrapper getURLForGetOrganisation:organisationId];
    NSString* authenticatedOrganisationURL = [self authenticatedGetURL:organisationURL];
    //NSLog(@"authenticatedOrganisationURL=%@", authenticatedOrganisationURL);
    NSURL* url = [NSURL URLWithString:authenticatedOrganisationURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)prepareRequestGetThemesForOrganisation:(int)organisationId
{
    NSString *organisationURL = [APIWrapper getURLForGetThemesForOrganisation:organisationId];
    NSString* authenticatedOrganisationURL = [self authenticatedGetURL:organisationURL];
    //NSLog(@"authenticatedOrganisationURL=%@", authenticatedOrganisationURL);
    NSURL* url = [NSURL URLWithString:authenticatedOrganisationURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)prepareRequestForGetOrganisations{
    NSString *organisationURL = [APIWrapper getURLForGetOrganisations];
    NSString* authenticatedOrganisationURL = [self authenticatedGetURL:organisationURL];
    NSURL* url = [NSURL URLWithString:authenticatedOrganisationURL];
    return [NSURLRequest requestWithURL:url];
}

-(void)submitOrganisationRequest:(NSURLRequest*)urlRequest{
    [self initConnectionRequest];
    [self submitURLRequest:urlRequest];
}

-(void)reportErrorToDelegate:(NSError*)error{
    if ([self.delegate respondsToSelector:@selector(OrganisationLoader:didFailWithError:)])
        [delegate OrganisationLoader:self didFailWithError:error];
}


#pragma mark NSURLConnectionDataDelegate methods
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"Organization->connectionDidFinishLoading organizationRequestType: %i",organisationRequestType);
    [super connectionDidFinishLoading:connection];
    if (self.downloadedData.length > 0){
        switch (organisationRequestType){
            case kGetOrganisations:
                [self handleGetOrganisationsResponse];
                break;
            case kGetOrganisation:
                [self handleGetOrganisationResponse];
                break;
            case kGetThemesForOrganisation:
                [self handleGetThemesForOrganisationResponse];
                break;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [super connection:connection didFailWithError:error];
    [self reportErrorToDelegate:error];
}

@end
