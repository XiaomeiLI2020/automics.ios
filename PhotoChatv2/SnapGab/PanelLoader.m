//
//  PanelLoader.m
//  PhotoChat
//
//  Created by horizon on 20/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "PanelLoader.h"

#import "APIConstant.h"
#import "Panel.h"
#import "APIWrapper.h"

@implementation PanelLoader

@synthesize delegate;

-(void)submitRequestGetPanelsForGroup:(int)groupId{
    [self initConnectionRequest];
    NSURLRequest* urlRequest = [self preparePanelRequestForGroup:groupId];
    [self submitURLRequest:urlRequest];
}

-(NSURLRequest*)preparePanelRequestForGroup:(int)groupId{
    NSString *panelURL = [APIWrapper getURLForGetPanels];
    NSURL* url = [NSURL URLWithString:panelURL];
    return [NSURLRequest requestWithURL:url];
}

#pragma mark NSURLConnectionDelegate functions.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [super connectionDidFinishLoading:connection];
    if (self.downloadedData.length > 0){
        NSError* error;
        NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
        if (jsonArray != nil){
            NSArray* panels = [self convertJSONArrayIntoPanels:jsonArray];
            if([self.delegate respondsToSelector:@selector(PanelLoader:didLoadPanels:)])
                [self.delegate PanelLoader:self didLoadPanels:panels];
        }else{
            [self reportErrorToDelegate:error];
        }
    }else{
        
    }
}

-(NSArray*)convertJSONArrayIntoPanels:(NSArray*)jsonArray{
    NSMutableArray *panels = [[NSMutableArray alloc] initWithCapacity:jsonArray.count];
    for (NSDictionary *obj in jsonArray){
        Panel *panel = [[Panel alloc] init];
        panel.panelID = [(NSString*)[obj valueForKey:@"id"] integerValue];
        //dict string object uses NSNull value in json deserilization.
        NSString* url = [obj objectForKey:@"image_url"];
        if ([url isEqual:[NSNull null]]){
            url = nil;
        }else{
            url = [APIWrapper getAbsoluteURLUsingPanelImageRelativePath:url];
        }
        panel.imageURL = url;
        [panels addObject:panel];
    }
    return panels;
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [super connection:connection didFailWithError:error];
    [self reportErrorToDelegate:error];
}

-(void)cancelPanelLoad{
    [self cancelRequest];
}


@end

