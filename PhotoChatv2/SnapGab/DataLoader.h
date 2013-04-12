//
//  DataLoader.h
//  PhotoChat
//
//  Created by Shakir Ali on 15/02/2013.
//  Copyright (c) 2013 Horizon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataLoader : NSObject<NSURLConnectionDataDelegate>{
    NSMutableData  *downloadedData;
    NSURLConnection *dataFeedConnection;
}

@property NSDictionary* dict;
@property NSString* request;
@property NSString* httpMethod;
@property int postRequestType;
@property NSMutableData *downloadedData;
@property NSURLConnection *dataFeedConnection;
-(NSString*)authenticatedGetURL:(NSString*)urlString;
-(NSDictionary*)authenticatedPostData:(NSDictionary*)dictionary;
-(void)initConnectionRequest;
-(void)submitURLRequest:(NSURLRequest*)urlRequest;
-(void)cancelRequest;
@end