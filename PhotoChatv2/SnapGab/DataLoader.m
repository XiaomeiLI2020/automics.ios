//
//  DataLoader.m
//  PhotoChat
//
//  Created by Shakir Ali on 15/02/2013.
//  Copyright (c) 2013 Horizon. All rights reserved.
//

#import "DataLoader.h"

#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"
#import "AppDelegate.h"

@implementation DataLoader

@synthesize postRequestType;
@synthesize dict;
@synthesize request;
@synthesize httpMethod;
@synthesize downloadedData;
@synthesize dataFeedConnection;

-(void)initConnectionRequest{
    if (dataFeedConnection)
        [dataFeedConnection cancel];
    self.dataFeedConnection = nil;
    self.downloadedData = nil;
}

-(NSString*)authenticatedGetURL:(NSString*)urlString
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* sessionToken = [prefs objectForKey:@"session"];
    NSString* authenticatedURL = [NSString stringWithFormat:@"%@?session=%@", urlString, sessionToken];
    return authenticatedURL;
}

-(NSDictionary*)authenticatedPostData:(NSDictionary*)dictionary
{

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* sessionToken = [prefs objectForKey:@"session"];
    [dictionary setValue:sessionToken forKey:@"session"];
    return dictionary;
}

-(void)submitURLRequest:(NSURLRequest*)urlRequest{
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    [urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [urlConnection start];
    self.dataFeedConnection = urlConnection;
}

-(void)cancelRequest{
    [self initConnectionRequest];
}

#pragma mark NSURLConnection functions.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
       self.downloadedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.downloadedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    self.dataFeedConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    self.dataFeedConnection = nil;
}

@end
