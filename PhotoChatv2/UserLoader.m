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

int const kPostGenerateSession = 0;
int const kPostJoinGroup = 1;

@synthesize delegate;
@synthesize userRequestType;
@synthesize sessionToken;

-(void)submitRequestPostJoinGroup:(NSString*)token andGroupHashId:(NSString*)hashId;
{
    if(token!=nil && hashId!=nil)
    {
        userRequestType = kPostJoinGroup;
        
        NSString *memberURL = [APIWrapper getURLForPostGroupMembership];
        //NSLog(@"submitRequestPostJoinGroup. memberURL=%@", memberURL);
        NSURL* url = [NSURL URLWithString:memberURL];
        
        
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [self setJoinGroupPostData:token andGroupHashId:hashId InURLRequest:urlRequest];
        
        [self submitUserRequest:urlRequest];
        
    }//end if

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
        NSURL* url = [NSURL URLWithString:loginURL];
        
        
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [self setGenerateSessionPostData:user InURLRequest:urlRequest];
        
        [self submitUserRequest:urlRequest];
        
    }//end if
 
}

-(void)setGenerateSessionPostData:(User*)user InURLRequest:(NSMutableURLRequest*)urlRequest
{
    
    //NSLog(@"setJoinGroupPostData. email=%@ and password=%@", email, password);
    
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

-(void)handlePostForGenerateSessionResponse
{
    
    NSError* error;
    NSDictionary* sessiondict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (sessiondict != nil)
    {
        //NSString* sessionToken =
        Session *session = [SessionJSONHandler getSessionFromSessionJSON:sessiondict];
        
        sessionToken = session.token;
        
        if(sessionToken!=nil)
        {
            //NSLog(@"sessionToken=%@", self.sessionToken);
        }
        
        if ([self.delegate respondsToSelector:@selector(UserLoader:didGenerateSession:)])
            [self.delegate UserLoader:self didGenerateSession:session];
        
    }
    else{
        [self reportErrorToDelegate:error];
    }
    
    
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [super connectionDidFinishLoading:connection];
    if (self.downloadedData.length > 0){
        switch (userRequestType){
            case kPostGenerateSession:
                [self handlePostForGenerateSessionResponse];
            case kPostJoinGroup:
                [self handlePostForJoinGroupResponse];
                
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

