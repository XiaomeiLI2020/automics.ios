//
//  UserJSONHandler.m
//  PhotoChat
//
//  Created by Umar Rashid on 05/03/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "UserJSONHandler.h"
#import "DataValidator.h"

@implementation UserJSONHandler

+(User*)getUserFromUserJSON:(NSDictionary*)userJSON
{
    User *user = [[User alloc] init];
    
    if ([userJSON valueForKey:@"user_id"] != nil){
        NSString* userId = [DataValidator checkKeyValueForNull:[userJSON valueForKey:@"user_id"]];
        if (userId != nil)
            user.userId = [userId integerValue];
    }
    
    if ([userJSON valueForKey:@"id"] != nil){
        NSString* userId = [DataValidator checkKeyValueForNull:[userJSON valueForKey:@"id"]];
        if (userId != nil)
            user.userId = [userId integerValue];
    }
    
    if ([userJSON valueForKey:@"user_login"] != nil){
        NSString* email = [DataValidator checkKeyValueForNull:[userJSON valueForKey:@"user_login"]];
        if (email != nil)
            user.email = email;
    }

    if ([userJSON valueForKey:@"login"] != nil){
        NSString* email = [DataValidator checkKeyValueForNull:[userJSON valueForKey:@"login"]];
        if (email != nil)
            user.email = email;
    }
    
    if ([userJSON valueForKey:@"password"] != nil){
        NSString* password = [DataValidator checkKeyValueForNull:[userJSON valueForKey:@"password"]];
        if (password != nil)
            user.password = password;
    }
    
    if ([userJSON valueForKey:@"group_hash"] != nil){
        NSString* groupHashId = [DataValidator checkKeyValueForNull:[userJSON valueForKey:@"group_hash"]];
        if (groupHashId != nil)
            user.groupHashId = groupHashId;
            user.currentGroup = [[Group alloc] init];
            user.currentGroup.hashId = groupHashId;
    }
    
    if ([userJSON valueForKey:@"current_group_hash"] != nil){
        NSString* groupHashId = [DataValidator checkKeyValueForNull:[userJSON valueForKey:@"current_group_hash"]];
        if (groupHashId != nil)
            user.groupHashId = groupHashId;
        user.currentGroup = [[Group alloc] init];
        user.currentGroup.hashId = groupHashId;
    }
    
    if ([userJSON valueForKey:@"session"] != nil){
        NSString* sessionToken = [DataValidator checkKeyValueForNull:[userJSON valueForKey:@"session"]];
        if (sessionToken != nil){
            
            user.currentSession = [[Session alloc] init];
            user.currentSession.token = sessionToken;
        }

    }

    
    return user;
    
}


+(NSDictionary*)convertUserIntoUserJSON:(User*)user{
    NSMutableDictionary *userdict;
    if (user != nil){
        userdict = [[NSMutableDictionary alloc] init];
        
        if (user.email != nil)
        {
            [userdict setValue:user.email forKey:@"login"];
            [userdict setValue:user.email forKey:@"user_login"];
        }
        
        if (user.password != nil)
            [userdict setValue:user.password forKey:@"password"];
 
        if (user.currentSession != nil)
            [userdict setValue:user.currentSession.token forKey:@"session"];
        
        if(user.currentGroup!=nil)
        {
            if(user.currentGroup.hashId!=nil)
            {
                [userdict setValue:user.currentGroup.hashId forKey:@"group_hash"];
                [userdict setValue:user.currentGroup.hashId forKey:@"current_group_hash"];
            }
        }
        //if (user.groupHashId != nil)
        //    [userdict setValue:user.groupHashId forKey:@"group_hash"];
        
        if (user.userId > 0)
        {
            [userdict setValue:[[NSNumber alloc] initWithInt:user.userId] forKey:@"user_id"];
            [userdict setValue:[[NSNumber alloc] initWithInt:user.userId] forKey:@"id"];
        }

    }
    return userdict;
}


@end
