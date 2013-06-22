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

-(void)submitRequestPostChangeGroup:(int)userId andNewGroupHashId:(NSString*)hashId;
{
    if(userId!=0 && hashId!=nil)
    {
        userRequestType = kPostChangeGroup;
        
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
        NSLog(@"handlePostForChangeGroupResponse.changeGroupData=%@", responseString);
        if (userdict != nil)
        {
            User *user = [UserJSONHandler getUserFromUserJSON:userdict];
            
            if ([self.delegate respondsToSelector:@selector(UserLoader:didChangeGroup:)])
                [self.delegate UserLoader:self didChangeGroup:user];
            
        }
        else{
            [self reportErrorToDelegate:error];
        }
        
    }
    
}


-(void)handlePostForLoginUserResponse
{
    NSError* error;
    NSDictionary* userdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    //NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    //NSLog(@"UserLoader.handlePostForLoginUserResponse.loginData=%@", responseString);
    if (userdict!= nil)
    {
        //NSString* sessionToken =
        User* user = [UserJSONHandler getUserFromUserJSON:userdict];
        
        if(user!=nil)
        {
            
            if ([self.delegate respondsToSelector:@selector(UserLoader:didLoginUser:)])
                [self.delegate UserLoader:self didLoginUser:user];
        }

        
    }
    else{
        [self reportErrorToDelegate:error];
    }
    
    
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
        }
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

