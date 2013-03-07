//
//  UserLoader.h
//  PhotoChat
//
//  Created by Umar Rashid on 05/03/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataLoader.h"
#import "User.h"
#import "Session.h"

@protocol UserLoaderDelegate;

@interface UserLoader : DataLoader

@property (weak) id<UserLoaderDelegate> delegate;
-(void)submitRequestPostJoinGroup:(NSString*)sessionToken andGroupHashId:(NSString*)groupHashId;
-(void)submitRequestPostGenerateSessionToken:(User*)user;


@end


@protocol UserLoaderDelegate<NSURLConnectionDataDelegate>
@optional

-(void)UserLoader:(UserLoader*)loader didFailWithError:(NSError*)error;
-(void)UserLoader:(UserLoader*)loader didGenerateSession:(Session*)session;
-(void)UserLoader:(UserLoader*)loader didJoinGroup:(User*)user;
@end