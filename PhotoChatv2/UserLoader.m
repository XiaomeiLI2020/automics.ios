//
//  UserLoader.m
//  PhotoChat
//
//  Created by Umar Rashid on 05/03/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "UserLoader.h"
#import "APIWrapper.h"
#import "SessionJSONHandler.h"
#import "UserJSONHandler.h"
#import "GroupLoader.h"

@interface UserLoader()
 @property int userRequestType;
 @property NSString* sessionToken;
@end

@implementation UserLoader
int const kPostRegister = 0;
int const kPostGenerateSession = 1;
int const kPostJoinGroup = 2;
int const kPostChangeGroup = 3;
int const kLeaveGroup = 4;
int const kGetUser = 5;
int const kPostDeviceToken = 6;
int const kPostNotification = 7;
int const kPostSetCurrentGroup = 8;

NSString* leaveGroupHashId;
@synthesize delegate;
@synthesize userRequestType;
@synthesize sessionToken;


-(void)submitRequestGetUser:(int)userId{
    userRequestType = kGetUser;
    NSURLRequest* urlRequest = [self prepareUserRequestForUserId:userId];
    [self submitUserRequest:urlRequest];
}


-(NSURLRequest*)prepareUserRequestForUserId:(int)userId{
    
    NSString *memberURL = [APIWrapper getURLForPostUserWithId:userId];
    NSLog(@"submitRequestGetUser.memberURL=%@", memberURL);
    NSString* authenticatedMemberURL = [self authenticatedGetURL:memberURL];
    NSLog(@"submitRequestGetUser.authenticatedMemberURL=%@", authenticatedMemberURL);
    NSURL* url = [NSURL URLWithString:authenticatedMemberURL];
    return [NSURLRequest requestWithURL:url];
}

-(void)submitRequestDeleteFromGroup:(NSString*)groupHashId
{
    if(groupHashId!=nil)
    {
        //NSError *requestError;
        
        leaveGroupHashId = groupHashId;
        userRequestType = kLeaveGroup;
        
        NSString *memberURL = [APIWrapper getURLForGetGroup:groupHashId];
        //NSLog(@"submitRequestDeleteFromGroup.memberURL=%@", memberURL);
        NSString* authenticatedMemberURL = [self authenticatedGetURL:memberURL];
        //NSLog(@"submitRequestDeleteFromGroup.authenticatedMemberURL=%@", authenticatedMemberURL);
        NSURL* url = [NSURL URLWithString:authenticatedMemberURL];
        
        
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"DELETE"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [self submitUserRequest:urlRequest];
    }//end if
    

}


-(void)submitRequestPostNotification:(NSString*)message
{
    userRequestType = kPostNotification;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* session = [prefs objectForKey:@"session"];
    
    NSString *notificationURL = [APIWrapper getURLForPostNotification];
    NSLog(@"UserLoader.submitRequestPostNotification.notificationURL=%@, message=%@", notificationURL, message);
    NSURL* url = [NSURL URLWithString:notificationURL];
    
    
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError *requestError;
    NSArray *objects = [NSArray arrayWithObjects:message, session, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"msg",@"session", nil];
    NSDictionary *questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"data"];
    //Create JSON object
    NSData *jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&requestError];
    
    // setting the body of the post to the reqeust
    [urlRequest setHTTPBody:jsonRequestData];
    
    [self submitUserRequest:urlRequest];

    
}

/*
-(void)submitRequestPostNotification
{
    userRequestType = kPostNotification;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* session = [prefs objectForKey:@"session"];
    
    NSString *notificationURL = [APIWrapper getURLForPostNotification];
    NSLog(@"submitRequestPostNotification.notificationURL=%@", notificationURL);
    NSURL* url = [NSURL URLWithString:notificationURL];
    
    
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError *requestError;
    NSArray *objects = [NSArray arrayWithObjects:@"Hello", session, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"msg",@"session", nil];
    NSDictionary *questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"data"];
    //Create JSON object
    NSData *jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&requestError];
    
    // setting the body of the post to the reqeust
    [urlRequest setHTTPBody:jsonRequestData];
    
    [self submitUserRequest:urlRequest];
    
}
 */

-(void)submitRequestPostDeviceToken
{
    userRequestType = kPostDeviceToken;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int userId = [[prefs objectForKey:@"user_id"] integerValue];
    NSString* deviceToken = [prefs objectForKey:@"token"];
    NSString* session = [prefs objectForKey:@"session"];
    
    NSString *userURL = [APIWrapper getURLForPostUserWithId:userId];
    //NSLog(@"submitRequestPostDeviceToken.userURL=%@", userURL);
    NSURL* url = [NSURL URLWithString:userURL];

    /*
    NSString* authenticatedUserURL = [self authenticatedGetURL:userURL];
    NSLog(@"submitRequestPostChangeGroup.authenticatedUserURL=%@", authenticatedUserURL);
    NSURL* url = [NSURL URLWithString:authenticatedUserURL];
    */
    
    
    if(deviceToken!=nil && session!=nil)
    {
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSError *requestError;
        NSArray *objects = [NSArray arrayWithObjects:deviceToken, session, nil];
        NSArray *keys = [NSArray arrayWithObjects:@"device_token",@"session", nil];
        NSDictionary *questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"data"];
        //Create JSON object
        NSData *jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&requestError];
        
        // setting the body of the post to the reqeust
        [urlRequest setHTTPBody:jsonRequestData];
        
        [self submitUserRequest:urlRequest];
        
    }//end if(deviceToken!=nil && session!=nil)
    
    /*
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError *requestError;
    NSArray *objects = [NSArray arrayWithObjects:deviceToken, session, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"device_token",@"session", nil];
    NSDictionary *questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"data"];
    //Create JSON object
    NSData *jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&requestError];
    
    // setting the body of the post to the reqeust
    [urlRequest setHTTPBody:jsonRequestData];
    
    [self submitUserRequest:urlRequest];
     */
    
}

/*
-(void)submitRequestPostDeviceToken:(NSString*)deviceToken andSessionToken:(NSString*)sessionToken
{
    if(deviceToken!=nil && sessionToken!=nil)
    {
        userRequestType = kPostDeviceToken;
        
        NSString *userURL = [APIWrapper getURLForPostUserWithId:userId];
        NSLog(@"submitRequestPostChangeGroup.userURL=%@", userURL);
        NSString* authenticatedUserURL = [self authenticatedGetURL:userURL];
        NSLog(@"submitRequestPostChangeGroup.authenticatedUserURL=%@", authenticatedUserURL);
        NSURL* url = [NSURL URLWithString:authenticatedUserURL];
        
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [self setChangeGroupPostData:hashId InURLRequest:urlRequest];
        [self submitUserRequest:urlRequest];

        
    }//end if
}
*/

-(void)submitRequestPostJoinGroup:(NSString*)token andGroupHashId:(NSString*)hashId;
{
    if(token!=nil && hashId!=nil)
    {
        userRequestType = kPostJoinGroup;

        NSString *memberURL = [APIWrapper getURLForPostGroupMembership];
        NSLog(@"submitRequestPostJoinGroup.memberURL=%@", memberURL);
        NSURL* url = [NSURL URLWithString:memberURL];
        
        
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [self setJoinGroupPostData:token andGroupHashId:hashId InURLRequest:urlRequest];
        
        [self submitUserRequest:urlRequest];
        
    }//end if

}

-(void)submitRequestPostSetCurrentGroup:(int)userId andNewGroupHashId:(NSString*)hashId
{
    //if(userId>0 && hashId!=nil && ![hashId isEqualToString:@""])
    if(userId>0)
    {
        userRequestType = kPostSetCurrentGroup;
        
        NSString *userURL = [APIWrapper getURLForPostUserWithId:userId];
        //NSLog(@"submitRequestPostSetCurrentGroup.userURL=%@", userURL);
        NSString* authenticatedUserURL = [self authenticatedGetURL:userURL];
        NSLog(@"submitRequestPostSetCurrentGroup.authenticatedUserURL=%@", authenticatedUserURL);
        NSURL* url = [NSURL URLWithString:authenticatedUserURL];
        
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [self setChangeGroupPostData:hashId InURLRequest:urlRequest];
        [self submitUserRequest:urlRequest];
        
    }//end if
    

}

-(void)submitRequestPostChangeGroup:(int)userId andNewGroupHashId:(NSString*)hashId;
{
    if(userId>0 && hashId!=nil && ![hashId isEqualToString:@""])
    {
        userRequestType = kPostChangeGroup;
        
        NSString *userURL = [APIWrapper getURLForPostUserWithId:userId];
        //NSLog(@"submitRequestPostChangeGroup.userURL=%@", userURL);
        NSString* authenticatedUserURL = [self authenticatedGetURL:userURL];
        NSLog(@"submitRequestPostChangeGroup.authenticatedUserURL=%@", authenticatedUserURL);
        NSURL* url = [NSURL URLWithString:authenticatedUserURL];
        
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [self setChangeGroupPostData:hashId InURLRequest:urlRequest];
        [self submitUserRequest:urlRequest];
        
    }//end if
    
}

-(void)setChangeGroupPostData:(NSString*)groupHashId InURLRequest:(NSMutableURLRequest*)urlRequest
{
    
    NSError *requestError;
    NSArray *objects = [NSArray arrayWithObjects:groupHashId, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"current_group_hash", nil];
    NSDictionary *questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"data"];
    //Create JSON object
    NSData *jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&requestError];
    
    // setting the body of the post to the reqeust
    [urlRequest setHTTPBody:jsonRequestData];
}


-(void)setJoinGroupPostData:(NSString*)token andGroupHashId:(NSString*)groupHashId InURLRequest:(NSMutableURLRequest*)urlRequest
{
    
    NSError *requestError;
    
    NSArray *objects = [NSArray arrayWithObjects:token, groupHashId, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"session",@"group", nil];
    NSDictionary *questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"data"];
    //Create JSON object
    NSData *jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&requestError];
    
    // setting the body of the post to the reqeust
    [urlRequest setHTTPBody:jsonRequestData];
    
}


-(void)submitRequestPostGenerateSessionToken:(User*)user
{
    if(user!=nil)
    {
        userRequestType = kPostGenerateSession;
        NSString *loginURL = [APIWrapper getURLForPostLogin];
        //NSLog(@"submitRequestPostGenerateSessionToken.loginURL=%@", loginURL);
        NSURL* url = [NSURL URLWithString:loginURL];
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self setGenerateSessionPostData:user InURLRequest:urlRequest];        
        [self submitUserRequest:urlRequest];
        
    }//end if(user!=nil)
 
}

-(void)submitRequestPostRegister:(User*)user
{
    if(user!=nil)
    {
        userRequestType = kPostRegister;
        NSString *loginURL = [APIWrapper getURLForPostRegister];
        NSURL* url = [NSURL URLWithString:loginURL];
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self setGenerateSessionPostData:user InURLRequest:urlRequest];
        [self submitUserRequest:urlRequest];
        
    }//end if(user!=nil)
    
}

-(void)setGenerateSessionPostData:(User*)user InURLRequest:(NSMutableURLRequest*)urlRequest
{
    NSError *requestError;
    NSArray *objects = [NSArray arrayWithObjects:user.email, user.password, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"login",@"password", nil];
    NSDictionary *questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"data"];
    //Create JSON object
    NSData *jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&requestError];
    
    // setting the body of the post to the reqeust
    [urlRequest setHTTPBody:jsonRequestData];
}



-(void)submitUserRequest:(NSURLRequest*)urlRequest{
    [self initConnectionRequest];
    [self submitURLRequest:urlRequest];
}

-(void)reportErrorToDelegate:(NSError*)error{
    if ([self.delegate respondsToSelector:@selector(UserLoader:didFailWithError:)])
        [delegate UserLoader:self didFailWithError:error];
}

-(void)handlePostForJoinGroupResponse
{
    
    NSError* error;
    //NSString *requestString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    //NSLog(@"handlePostForJoinGroupResponse.requestData: %@", requestString);
    
    if(self.downloadedData.length > 0)
    {
        NSDictionary* userdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
        NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
        NSLog(@"handlePostForJoinGroupResponse.joinGroupData=%@", responseString);
        if (userdict != nil)
        {
            User *user = [UserJSONHandler getUserFromUserJSON:userdict];
            
            if ([self.delegate respondsToSelector:@selector(UserLoader:didJoinGroup:)])
                [self.delegate UserLoader:self didJoinGroup:user];
            
        }
        else{
            [self reportErrorToDelegate:error];
        }
        
    }
    
}


-(void)handleGetUserResponse
{
    
    NSError* error;
    //NSString *requestString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    //NSLog(@"handlePostForJoinGroupResponse.requestData: %@", requestString);
    
    if(self.downloadedData.length > 0)
    {
        NSDictionary* userdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
        NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
        NSLog(@"handleGetUserResponse.userData=%@", responseString);
        if (userdict != nil)
        {
            User *user = [UserJSONHandler getUserFromUserJSON:userdict];
            
            if ([self.delegate respondsToSelector:@selector(UserLoader:didLoadUser:)])
                [self.delegate UserLoader:self didLoadUser:user];
            
        }
        else{
            [self reportErrorToDelegate:error];
        }
        
    }
    
}

-(void)handlePostForChangeGroupResponse
{
    
    NSError* error;
    //NSString *requestString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    //NSLog(@"handlePostForJoinGroupResponse.requestData: %@", requestString);
    
    if(self.downloadedData.length > 0)
    {
        NSDictionary* userdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
        NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
        NSLog(@"UserLoader.handlePostForChangeGroupResponse.changeGroupData=%@", responseString);
        if (userdict != nil)
        {
            User *user = [UserJSONHandler getUserFromUserJSON:userdict];
            
            
            
            if(user!=nil)
            {
                //NSLog(@"GroupJoinViewController.didChangeGroup.currentUser.userId=%i", currentUser.userId);
                if(user.currentGroup!=nil)
                {
                    NSLog(@"UserLoader.didChangeGroup.currentUser.currentGroup.hashId=%@", user.currentGroup.hashId);
                    if(user.currentGroup.hashId!=nil)
                    {
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:user.currentGroup.hashId forKey:@"current_group_hash"];
                        [userDefaults synchronize];
                        
                        
                        GroupLoader* groupLoader = [[GroupLoader alloc] init];
                        [groupLoader submitRequestGetGroupForHashId:user.currentGroup.hashId];
                        
                        // [self.userLoader submitSQLRequestUpdateCurrentGroup:currentUser.currentGroup.hashId andUserId:currentUser.userId];
                        
                    }
                }
            }
            
            /*
            if ([self.delegate respondsToSelector:@selector(UserLoader:didChangeGroup:)])
                [self.delegate UserLoader:self didChangeGroup:user];
            */
        }
        else{
            [self reportErrorToDelegate:error];
        }
        
    }
    
}

-(void)handlePostForSetCurrentGroupResponse
{
    
    NSError* error;
    //NSString *requestString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    //NSLog(@"handlePostForJoinGroupResponse.requestData: %@", requestString);
    
    if(self.downloadedData.length > 0)
    {
        NSDictionary* userdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
        NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
        NSLog(@"handlePostForSetCurrentGroupResponse.changeGroupData=%@", responseString);
        if (userdict != nil)
        {
            User *user = [UserJSONHandler getUserFromUserJSON:userdict];
            
            if ([self.delegate respondsToSelector:@selector(UserLoader:didSetCurrentGroup:)])
                [self.delegate UserLoader:self didSetCurrentGroup:user];
            
        }
        else{
            [self reportErrorToDelegate:error];
        }
        
    }
    
}



-(void)handlePostForLoginUserResponse
{
    NSError* error;
    
    NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    NSLog(@"UserLoader.handlePostForLoginUserResponse.loginData=%@", responseString);
    
    {
        NSDictionary* userdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
        //responseString = [[NSString alloc] initWithData:userdict encoding:NSUTF8StringEncoding];
        //NSLog(@"UserLoader.handlePostForLoginUserResponse.loginData=%@", responseString);
        if (userdict!= nil)
        {
            //NSString* sessionToken =
            User* user = [UserJSONHandler getUserFromUserJSON:userdict];
            if(user!=nil && user.userId>0)
            {
                //NSLog(@"user.userId=%i", user.userId);
                if ([self.delegate respondsToSelector:@selector(UserLoader:didLoginUser:)])
                    [self.delegate UserLoader:self didLoginUser:user];
            }//end if(user!=nil && user.userId>0)
            else{
                [self reportErrorToDelegate:error];
            }//end else
        }
        else{
            [self reportErrorToDelegate:error];
        }

        
    }//end if(![responseString isEqualToString:@"invalid user"])
    
       
    
}
-(void)handlePostForGenerateSessionResponse
{
    NSError* error;
    NSDictionary* sessiondict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    NSLog(@"handlePostForGenerateSessionResponse.loginData=%@", responseString);
    if (sessiondict != nil)
    {
        //NSString* sessionToken =
        Session *session = [SessionJSONHandler getSessionFromSessionJSON:sessiondict];
        
        sessionToken = session.token;
        
        if(sessionToken!=nil)
        {
            //NSLog(@"handlePostForGenerateSessionResponse.sessionToken=%@", self.sessionToken);
        }
        
        if ([self.delegate respondsToSelector:@selector(UserLoader:didGenerateSession:)])
            [self.delegate UserLoader:self didGenerateSession:session];
        
    }
    else{
        [self reportErrorToDelegate:error];
    }
    
    
}

-(void)handlePostForRegisterResponse
{
    
    NSError* error;
    NSDictionary* sessiondict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (sessiondict != nil)
    {
        NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
        NSLog(@"registerData=%@", responseString);
        /*
        if ([self.delegate respondsToSelector:@selector(UserLoader:didGenerateSession:)])
            [self.delegate UserLoader:self didGenerateSession:session];
        */
    }
    else{
        [self reportErrorToDelegate:error];
    }
}

-(void)handleLeaveGroupResponse
{
    
    //NSError* error;
    //NSString *requestString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    //NSLog(@"handlePostForJoinGroupResponse.requestData: %@", requestString);
    
    if(self.downloadedData.length > 0)
    {
        //NSDictionary* userdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
        NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
        //NSLog(@"handleLeaveGroupResponse.leaveGroupData=%@", responseString);
        
        if([responseString isEqualToString:@"true"])
        {
            [self submitSQLRequestLeaveGroup:leaveGroupHashId];
            
            if ([self.delegate respondsToSelector:@selector(UserLoader:didLeaveGroup:)])
                [self.delegate UserLoader:self didLeaveGroup:responseString];
            
        }
    }
    
}

-(void)handlePostDeviceToken{
    if(self.downloadedData.length > 0)
    {
        //NSDictionary* userdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
        NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
        NSLog(@"handlePostDeviceToken.responseString=%@", responseString);

    }
}

-(void)handlePostNotification{
    if(self.downloadedData.length > 0)
    {
        //NSDictionary* userdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
        NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
        NSLog(@"handlePostNotification.responseString=%@", responseString);
        
    }
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [super connectionDidFinishLoading:connection];
    if (self.downloadedData.length > 0){
        switch (userRequestType){
            case kPostRegister:
                [self handlePostForRegisterResponse];
                break;
            case kPostGenerateSession:
                //[self handlePostForGenerateSessionResponse];
                [self handlePostForLoginUserResponse];
                break;
            case kPostJoinGroup:
                [self handlePostForJoinGroupResponse];
                break;
            case kPostChangeGroup:
                [self handlePostForChangeGroupResponse];
                break;
            case kLeaveGroup:
                [self handleLeaveGroupResponse];
                break;
            case kGetUser:
                [self handleGetUserResponse];
                break;
            case kPostDeviceToken:
                [self handlePostDeviceToken];
                break;
            case kPostNotification:
                [self handlePostNotification];
                break;
            case kPostSetCurrentGroup:
                [self handlePostForSetCurrentGroupResponse];
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

