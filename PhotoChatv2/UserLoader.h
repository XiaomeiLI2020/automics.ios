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
-(void)submitRequestGetUser:(int)userId;
-(void)submitRequestPostJoinGroup:(NSString*)sessionToken andGroupHashId:(NSString*)groupHashId;
//-(void)submitRequestPostDeviceToken:(NSString*)deviceToken andSessionToken:(NSString*)sessionToken;
-(void)submitRequestPostDeviceToken;
//-(void)submitRequestPostNotification;
-(void)submitRequestPostNotification:(NSString*)message;
-(void)submitRequestPostChangeGroup:(int)userId andNewGroupHashId:(NSString*)groupHashId;
-(void)submitRequestPostSetCurrentGroup:(int)userId andNewGroupHashId:(NSString*)groupHashId;
-(void)submitRequestDeleteFromGroup:(NSString*)groupHashId;
//-(void)submitRequestPostJoinGroup:(NSString*)sessionToken andGroupHashId:(NSString*)groupHashId;
-(void)submitRequestPostGenerateSessionToken:(User*)user;
-(void)submitRequestPostRegister:(User*)user;

@end


@protocol UserLoaderDelegate<NSURLConnectionDataDelegate>
@optional

-(void)UserLoader:(UserLoader*)loader didFailWithError:(NSError*)error;
-(void)UserLoader:(UserLoader*)loader didGenerateSession:(Session*)session;
-(void)UserLoader:(UserLoader*)loader didLeaveGroup:(NSString*)responseString;
-(void)UserLoader:(UserLoader*)loader didLoginUser:(User*)user;
-(void)UserLoader:(UserLoader*)loader didJoinGroup:(User*)user;
-(void)UserLoader:(UserLoader*)loader didSetCurrentGroup:(User*)user;
-(void)UserLoader:(UserLoader*)loader didChangeGroup:(User*)user;
-(void)UserLoader:(UserLoader*)loader didLoadUser:(User*)user;
@end