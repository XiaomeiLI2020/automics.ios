//
//  APIWrapper.m
//  PhotoChat
//
//  Created by Shakir Ali on 15/02/2013.
//  Copyright (c) 2013 Horizon. All rights reserved.
//

#import "APIWrapper.h"
#import "APIConstant.h"

@implementation APIWrapper

@synthesize delegate;

-(void)submitRequestGetPanelsForGroup:(int)groupId{
    [self initConnectionRequest];
    NSURLRequest* urlRequest = [self preparePanelRequestForGroup:groupId];
    [self submitURLRequest:urlRequest];
}

-(NSURLRequest*)preparePanelRequestForGroup:(int)groupId{
    NSString *panelURL = [kBaseURL stringByAppendingString:kPanelURL];
    NSURL* url = [NSURL URLWithString:panelURL];
    return [NSURLRequest requestWithURL:url];
}

#pragma mark NSURLConnectionDelegate functions.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [super connectionDidFinishLoading:connection];
    if (self.downloadedData.length > 0){
        NSError* error;
        NSArray* data = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
        if (data != nil){
        }else{
            [self reportErrorToDelegate:error];
        }
    }else{
        
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [super connection:connection didFailWithError:error];
    [self reportErrorToDelegate:error];
}

-(void)cancelPanelLoad{
    [self cancelRequest];
}


@end
