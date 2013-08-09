//
//  GroupLoader.m
//  PhotoChat
//
//  Created by Umar Rashid on 05/03/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "GroupLoader.h"
#import "APIWrapper.h"
#import "GroupJSONHandler.h"

@interface GroupLoader ()
@property int groupRequestType;
@end

@implementation GroupLoader

int const kGetGroups = 0;
int const kGetGroup = 1;
int const kPostGroup = 2;
int const kPostThemeForGroup = 3;
int const kPostMembershipForGroup = 4;

//BOOL groupsDownloaded = NO;

@synthesize groupRequestType;
@synthesize delegate;

-(void)submitRequestGetGroups{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int userId = [[prefs objectForKey:@"user_id"] integerValue];
    
    int groupsDownloaded = [self submitSQLRequestCheckGroupsDownloaded:userId];
    if(groupsDownloaded==0 && [self isReachable])
    {
        groupRequestType = kGetGroups;
        groupsDownloaded = YES;
        NSURLRequest* urlRequest = [self prepareRequestForGetGroups];
        [self submitGroupRequest:urlRequest];
    }
    else
    {
        NSLog(@"Groups downloaded from the database.");
        NSArray* groups= [self convertGroupsSQLIntoGroups];
        if(groups!=nil && [groups count]>0)
        {
            if ([self.delegate respondsToSelector:@selector(GroupLoader:didLoadGroups:)])
                [self.delegate GroupLoader:self didLoadGroups:groups];
        }//end if(groups!=nil && [groups count]>0)

    }//end else
}

-(void)submitRequestPostGroup:(Group*)group{
    groupRequestType = kPostGroup;
    NSURLRequest* urlRequest = [self prepareRequestForPostGroup:group];
    [self submitGroupRequest:urlRequest];
}

-(void)submitRequestPostMembershipForGroup:(Group*)group{
    groupRequestType = kPostMembershipForGroup;
    NSURLRequest* urlRequest = [self prepareRequestPostMemberShipForGroup:group];
    [self submitGroupRequest:urlRequest];
}

-(void)submitRequestPostThemeForGroup:(NSString*)groupHashId andThemeId:(int)themeId{
    groupRequestType = kPostThemeForGroup;
    NSURLRequest* urlRequest = [self prepareRequestForPostThemeForGroup:groupHashId andThemeId:themeId];
    [self submitGroupRequest:urlRequest];
}

-(NSURLRequest*)prepareRequestForPostThemeForGroup:(NSString*)groupHashId andThemeId:(int)themeId{
    Group* group=[[Group alloc] init];
    //Theme* theme = [[Theme alloc] init];
    //theme.themeId = themeId;
    //group.theme = theme;
    group.name=@"new name";
    
    NSString* groupURL = [APIWrapper getURLForGetGroup:groupHashId];
    //NSString* authenticatedGroupURL = [self authenticatedGetURL:groupURL];
    //NSLog(@"authenticatedGroupURL=%@", authenticatedGroupURL);
    NSLog(@"prepareRequestForPostThemeForGroup.groupHashId=%@, themeId=%i, groupURL=%@", groupHashId, themeId, groupURL);
    self.httpMethod = @"POST";
    self.request = groupURL;
    self.postRequestType = kPostThemeForGroup;
    NSURL* url = [NSURL URLWithString:groupURL];
    //return [NSURLRequest requestWithURL:url];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //[self setGroupPostData:group InURLRequest:urlRequest];
    
    NSString* groupName= @"newgroup1";
    
    NSArray *objects = [NSArray arrayWithObjects:groupName, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"name", nil];
    NSDictionary *questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"data"];
    
    /*
     NSDictionary* groupdict = [GroupJSONHandler convertGroupIntoGroupJSON:group];
     //comicdict = [self authenticatedPostData:comicdict];
     groupdict = [GroupJSONHandler wrapJSONDictWithDataTag:groupdict];
     self.dict = groupdict;
     */
    self.dict = jsonDict;
    NSError *error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"groupPostData: %@", responseString);
    [urlRequest setHTTPBody:data];

    return urlRequest;
}

-(void)setGroupPostData:(Group*)group InURLRequest:(NSMutableURLRequest*)urlRequest{
    
    NSDictionary* groupdict = [GroupJSONHandler convertGroupIntoGroupJSON:group];
    //comicdict = [self authenticatedPostData:comicdict];
    groupdict = [GroupJSONHandler wrapJSONDictWithDataTag:groupdict];
    self.dict = groupdict;
    NSError *error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:groupdict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"setGroupPostData.groupPostData: %@", responseString);
    [urlRequest setHTTPBody:data];
}

-(void)submitRequestGetGroupForHashId:(NSString*)groupHashId{
    int groupExists = [self submitSQLRequestCheckGroupExists:groupHashId];
    //NSLog(@"Grouploader.submitRequestGetGroupForHashId.groupExists=%i", groupExists);
    if(groupExists==0)
    {
        groupRequestType = kGetGroup;
        NSURLRequest* urlRequest = [self prepareRequestForGetGroup:groupHashId];
        [self submitGroupRequest:urlRequest];
    }

    else
    {

        NSArray* groups = [self convertGroupSQLIntoGroup:groupHashId];
        if(groups!=nil && [groups count]>0)
        {
            Group* group = [groups objectAtIndex:0];
            if(group!=nil)
            {
                //NSLog(@"Group %@ downloaded from the database.", group.name);
                if ([self.delegate respondsToSelector:@selector(GroupLoader:didLoadGroup:)])
                    [self.delegate GroupLoader:self didLoadGroup:group];
            }//end if(group!=nil)
        }//end if(groups!=nil && [groups count]>0)
    }//end else
}

-(NSURLRequest*)prepareRequestForGetGroups{
    NSString* groupURL = [APIWrapper getURLForGetGroups];
    NSString* authenticatedGroupURL = [self authenticatedGetURL:groupURL];
    //NSLog(@"authenticatedGroupURL=%@", authenticatedGroupURL);
    NSURL* url = [NSURL URLWithString:authenticatedGroupURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)prepareRequestForGetGroup:(NSString*)groupHashId{
    NSString* groupURL = [APIWrapper getURLForGetGroup:groupHashId];
    NSString* authenticatedGroupURL = [self authenticatedGetURL:groupURL];
    //NSLog(@"authenticatedGroupURL=%@", authenticatedGroupURL);
    NSURL* url = [NSURL URLWithString:authenticatedGroupURL];
    return [NSURLRequest requestWithURL:url];
}


-(NSURLRequest*)prepareRequestForPostGroup:(Group*)group
{
    NSString* groupURL = [APIWrapper getURLForGetGroups];
    //NSString* authenticatedGroupURL = [self authenticatedGetURL:groupURL];
    //NSLog(@"authenticatedGroupURL=%@", authenticatedGroupURL);
    self.httpMethod = @"POST";
    self.request = groupURL;
    self.postRequestType = kPostGroup;
    NSURL* url = [NSURL URLWithString:groupURL];
    //return [NSURLRequest requestWithURL:url];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self setGroupPostData:group InURLRequest:urlRequest];
    return urlRequest;
}

-(NSURLRequest*)prepareRequestPostMemberShipForGroup:(Group*)group
{
    NSString* groupURL = [APIWrapper getURLForPostGroupMembership];
    //NSString* authenticatedGroupURL = [self authenticatedGetURL:groupURL];
    //NSLog(@"authenticatedGroupURL=%@", authenticatedGroupURL);
    self.httpMethod = @"POST";
    self.request = groupURL;
    self.postRequestType = kPostGroup;
    NSURL* url = [NSURL URLWithString:groupURL];
    //return [NSURLRequest requestWithURL:url];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    Group* newGroup = [[Group alloc] init];
    newGroup.hashId = group.hashId;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* sessionToken = [prefs objectForKey:@"session"];
    
    NSArray *objects = [NSArray arrayWithObjects:group.hashId, sessionToken, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"group",@"session", nil];
    NSDictionary *questionDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:questionDict forKey:@"data"];
    
    /*
    NSDictionary* groupdict = [GroupJSONHandler convertGroupIntoGroupJSON:group];
    //comicdict = [self authenticatedPostData:comicdict];
    groupdict = [GroupJSONHandler wrapJSONDictWithDataTag:groupdict];
    self.dict = groupdict;
    */
    self.dict = jsonDict;
    NSError *error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];

    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"prepareRequestPostMemberShipForGroup.groupPostData: %@", responseString);
    [urlRequest setHTTPBody:data];
    
    //[self setGroupPostData:group InURLRequest:urlRequest];
    return urlRequest;
}


-(void)submitGroupRequest:(NSURLRequest*)urlRequest{
    [self initConnectionRequest];
    [self submitURLRequest:urlRequest];
}

-(void)handleGetGroupsResponse{
    NSError* error;
    NSArray* groupJSON = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (groupJSON != nil){
        NSArray* groups = [GroupJSONHandler convertGroupsJSONIntoGroups:groupJSON];
        if(groups!=nil && [groups count]>0)
        {
            [self submitSQLRequestSaveGroups:groups];
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            int userId = [[prefs objectForKey:@"user_id"] integerValue];
            [self submitSQLRequestUpdateGroupsDownloaded:1 andUserId:userId];
            if ([self.delegate respondsToSelector:@selector(GroupLoader:didLoadGroups:)])
                [self.delegate GroupLoader:self didLoadGroups:groups];
        }
    }
    
}

-(void)handleGetGroupResponse{
    NSError* error;
    NSDictionary* groupJSON = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (groupJSON != nil){
        Group* group = [GroupJSONHandler convertGroupJSONIntoGroup:groupJSON];
        //NSLog(@"handleGetGroupResponse. group.name=%@", group.name);
        if(group!=nil){
            NSMutableArray* groups = [[NSMutableArray alloc] init];
            [groups addObject:group];
            [self submitSQLRequestSaveGroups:groups];
            
            if ([self.delegate respondsToSelector:@selector(GroupLoader:didLoadGroup:)])
                [self.delegate GroupLoader:self didLoadGroup:group];
        }
    }
    
}

-(void)handlePostGroupResponse{
   
    NSError* error;
    NSDictionary* groupdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    
    NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    NSLog(@"handlePostGroupResponse.groupPostData: %@", responseString);
    
    if (groupdict != nil){
        //NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
        //NSLog(@"GroupData: %@", responseString);
        Group* group = [GroupJSONHandler convertGroupJSONIntoGroup:groupdict];
        if(group!=nil)
        {
            NSMutableArray* groups= [[NSMutableArray alloc] init];
            [groups addObject:group];
            [self submitSQLRequestSaveGroups:groups];
            
            //NSLog(@"group.name=%@, hashId=%@, id=%i", group.name, group.hashId, group.groupId);
            if ([self.delegate respondsToSelector:@selector(GroupLoader:didSaveGroup:)])
                [self.delegate GroupLoader:self didSaveGroup:group];
        }//end if
        
    }else{
        [self reportErrorToDelegate:error];
    }

    
    /*
    NSError* error;
    NSArray* groupJSON = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (groupJSON != nil){
        NSArray* groups = [GroupJSONHandler convertGroupsJSONIntoGroups:groupJSON];
        if ([self.delegate respondsToSelector:@selector(GroupLoader:didLoadGroups:)])
            [self.delegate GroupLoader:self didLoadGroups:groups];
    }
    */
}

-(void)handlePostGroupMembershipResponse{
    
    NSError* error;
    NSDictionary* groupdict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    NSLog(@"handlePostGroupMembershipResponse.groupPostData: %@", responseString);
    
    if (groupdict != nil){
        //NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
        //NSLog(@"GroupData: %@", responseString);
        Group* group = [GroupJSONHandler convertGroupJSONIntoGroup:groupdict];
        if(group!=nil)
        {
            
            //NSLog(@"group.name=%@, hashId=%@, id=%i", group.name, group.hashId, group.groupId);
            if ([self.delegate respondsToSelector:@selector(GroupLoader:didJoinGroup:)])
                [self.delegate GroupLoader:self didJoinGroup:group];
        }//end if
        
    }else{
        [self reportErrorToDelegate:error];
    }
    
    
    /*
     NSError* error;
     NSArray* groupJSON = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
     if (groupJSON != nil){
     NSArray* groups = [GroupJSONHandler convertGroupsJSONIntoGroups:groupJSON];
     if ([self.delegate respondsToSelector:@selector(GroupLoader:didLoadGroups:)])
     [self.delegate GroupLoader:self didLoadGroups:groups];
     }
     */
}



-(void)reportErrorToDelegate:(NSError*)error{
    if ([self.delegate respondsToSelector:@selector(GroupLoader:didFailWithError:)])
        [delegate GroupLoader:self didFailWithError:error];
}


#pragma mark NSURLConnectionDataDelegate methods
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [super connectionDidFinishLoading:connection];
    if (self.downloadedData.length > 0){
        switch (groupRequestType){
            case kGetGroups:
                [self handleGetGroupsResponse];
                break;
            case kGetGroup:
                [self handleGetGroupResponse];
                break;
            case kPostGroup:
                [self handlePostGroupResponse];
                break;
            case kPostThemeForGroup:
                [self handlePostGroupResponse];
                break;
            case kPostMembershipForGroup:
                [self handlePostGroupMembershipResponse];
                break;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [super connection:connection didFailWithError:error];
    [self reportErrorToDelegate:error];
}


@end
