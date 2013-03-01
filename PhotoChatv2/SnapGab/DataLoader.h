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

@property NSMutableData *downloadedData;
@property NSURLConnection *dataFeedConnection;
-(void)initConnectionRequest;
-(void)submitURLRequest:(NSURLRequest*)urlRequest;
-(void)cancelRequest;
@end