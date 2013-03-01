//
//  PanelLoader.m
//  PhotoChat
//
//  Created by Shakir Ali on 20/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "PanelLoader.h"

#import "APIConstant.h"
#import "PanelJSONHandler.h"
#import "APIWrapper.h"


@interface PanelLoader ()
@property int panelRequestType;
@end

@implementation PanelLoader

int const kGetGroupPanels = 0;
int const kGetPanel = 1;
int const kPostPanel = 2;

@synthesize delegate;
@synthesize panelRequestType;


-(void)submitRequestGetPanelsForGroup:(int)groupId{
    panelRequestType = kGetGroupPanels;
    NSURLRequest* urlRequest = [self preparePanelRequestForGroup:groupId];
    [self submitPanelRequest:urlRequest];
}

-(void)submitRequestGetPanelWithId:(int)panelId{
    panelRequestType = kGetPanel;
    NSURLRequest* urlRequest = [self preparePanelRequestForGetPanelWithId:panelId];
    [self submitPanelRequest:urlRequest];
}

-(void)submitRequestPostPanel:(Panel*)panel{
    panelRequestType = kPostPanel;
    NSURLRequest* urlRequest = [self preparePanelRequestForPostPanel:panel];
    [self submitPanelRequest:urlRequest];
}

-(void)submitPanelRequest:(NSURLRequest*)urlRequest{
    [self initConnectionRequest];
    [self submitURLRequest:urlRequest];
}

-(NSURLRequest*)preparePanelRequestForGroup:(int)groupId{
    NSString *panelURL = [APIWrapper getURLForGetPanels];
    NSURL* url = [NSURL URLWithString:panelURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)preparePanelRequestForGetPanelWithId:(int)panelId{
    NSString* panelURL = [APIWrapper getURLForGetPanelWithId:panelId];
    NSURL* url = [NSURL URLWithString:panelURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)preparePanelRequestForPostPanel:(Panel*)panel{
    NSString *panelURL = [APIWrapper getURLForPostPanel];
    NSURL* url = [NSURL URLWithString:panelURL];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self setPanelPostData:panel InURLRequest:urlRequest];
    return urlRequest;
}

-(void)setPanelPostData:(Panel*)panel InURLRequest:(NSMutableURLRequest*)urlRequest{
    NSDictionary* paneldict = [PanelJSONHandler convertPanelIntoPanelJSON:panel];
    paneldict = [PanelJSONHandler wrapJSONDictWithDataTag:paneldict];
    NSError *error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:paneldict options:NSJSONWritingPrettyPrinted error:&error];
    [urlRequest setHTTPBody:data];
}


-(void)handleGetPanelsForGroupResponse{
    NSError* error;
    NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (jsonArray != nil){
        NSArray* panels = [PanelJSONHandler convertPanelsJSONIntoPanels:jsonArray];
        if([self.delegate respondsToSelector:@selector(PanelLoader:didLoadPanels:)])
            [self.delegate PanelLoader:self didLoadPanels:panels];
    }else{
        [self reportErrorToDelegate:error];
    }
}

-(void)handleGetPanelWithIdResponse{
    NSError* error;
    NSDictionary* paneldict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    //NSLog(@"paneldict=%i", [paneldict count]);
    if (paneldict != nil){
        Panel *panel = [PanelJSONHandler convertPanelJSONDictIntoPanel:paneldict];
        if ([self.delegate respondsToSelector:@selector(PanelLoader:didLoadPanel:)])
            [self.delegate PanelLoader:self didLoadPanel:panel];
    }else{
        [self reportErrorToDelegate:error];
    }
}

-(void)handlePostPanel{
    NSError* error;
    NSDictionary* paneldict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (paneldict != nil){
        Panel *panel = [PanelJSONHandler convertPanelJSONDictIntoPanel:paneldict];
        if ([self.delegate respondsToSelector:@selector(PanelLoader:didSavePanel:)])
            [self.delegate PanelLoader:self didSavePanel:panel];
    }
}

-(void)reportErrorToDelegate:(NSError*)error{
    if ([self.delegate respondsToSelector:@selector(PanelLoader:didFailWithError:)])
        [delegate PanelLoader:self didFailWithError:error];
}

-(void)downloadErrorWithErrorCode:(NSInteger)errorCode ForConnection:(NSURLConnection*) connection{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Application cannot download data. Please check your internet connection."
                                                         forKey:NSLocalizedDescriptionKey];
    NSError *error = [[NSError alloc] initWithDomain:@"" code:errorCode userInfo:userInfo];
    [self reportErrorToDelegate:error];
}

-(void)cancelPanelLoad{
    [self cancelRequest];
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [super connectionDidFinishLoading:connection];
    if (self.downloadedData.length > 0){
        switch (panelRequestType){
            case kGetGroupPanels:
                [self handleGetPanelsForGroupResponse];
                break;
            case kGetPanel:
                [self handleGetPanelWithIdResponse];
                break;
            case kPostPanel:
                [self handlePostPanel];
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

