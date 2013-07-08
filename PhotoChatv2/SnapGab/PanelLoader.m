//
//  PanelLoader.m
//  PhotoChat
//
//  Created by Shakir Ali on 20/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "PanelLoader.h"

#import "APIConstant.h"
#import "PanelJSONHandler.h"
#import "APIWrapper.h"

@interface PanelLoader ()
@property int panelRequestType;
@end

@implementation PanelLoader

int const kGetGroupPanels = 0;
int const kGetPanel = 1;
int const kPostPanel = 2;
int const kRefreshGetGroupPanels = 3;

BOOL panelsDownloaded = NO;
int currentNumPanels = 0;

@synthesize delegate;
@synthesize panelRequestType;
@synthesize obj;

/*
-(void)submitRequestGetPanelsForGroup:(int)groupId{
    
    //dispatch_queue_t panelQueue = dispatch_queue_create("automics.database", NULL);
    //dispatch_async(panelQueue, ^(void) {

    //NSLog(@"[self submitSQLRequestCountPanelsForGroup:groupId]=%i", [self submitSQLRequestCountPanelsForGroup:groupId]);
    //if([self submitSQLRequestCountPanelsForGroup:groupId]==0)
    if(!panelsDownloaded)
    {

        panelRequestType = kGetGroupPanels;
        panelsDownloaded = YES;
        NSURLRequest* urlRequest = [self preparePanelRequestForGroup:groupId];
        [self submitPanelRequest:urlRequest];

    }

    //});
    else
    {

        //NSLog(@"[self submitSQLRequestCountPanelsForGroup:groupId]=%i", [self submitSQLRequestCountPanelsForGroup:groupId]);
        NSArray* panels = [self convertPanelsSQLIntoPanels:groupId];
        if([self.delegate respondsToSelector:@selector(PanelLoader:didLoadPanels:)])
            [self.delegate PanelLoader:self didLoadPanels:panels];

    }
}
*/

-(void)submitRequestRefreshGetPanelsForGroup{
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
    
    //int groupExists = [self submitSQLRequestCheckGroupExists:currentGroupHashId];
    //NSLog(@"groupExists =%i", groupExists);
    
    //NSLog(@"currentGroupHashId =%@", currentGroupHashId);
    //int panelsDownloaded = [self submitSQLRequestCheckPanelsDownloadedForGroup:currentGroupHashId];
    //NSLog(@"PanelLoader.submitRequestGetPanelsForGroup.panelsDownloaded=%i", panelsDownloaded);
    
    //if(panelsDownloaded==0)
    if([self isReachable])
    {
        panelRequestType = kRefreshGetGroupPanels;
        //panelsDownloaded = YES;
        NSURLRequest* urlRequest = [self preparePanelRequestForGroup];
        [self submitPanelRequest:urlRequest];
    }

}

/*
-(void)submitRequestRefreshGetPanelsForGroup:(int)oldNmPanels{
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
    
    //int groupExists = [self submitSQLRequestCheckGroupExists:currentGroupHashId];
    //NSLog(@"groupExists =%i", groupExists);
    
    //NSLog(@"currentGroupHashId =%@", currentGroupHashId);
    //int panelsDownloaded = [self submitSQLRequestCheckPanelsDownloadedForGroup:currentGroupHashId];
    //NSLog(@"PanelLoader.submitRequestGetPanelsForGroup.panelsDownloaded=%i", panelsDownloaded);
    
    //if(panelsDownloaded==0)
    {
        panelRequestType = kRefreshGetGroupPanels;
        //panelsDownloaded = YES;
        NSURLRequest* urlRequest = [self preparePanelRequestForGroup];
        [self submitPanelRequest:urlRequest];
    }
    
}
*/


-(void)submitRequestGetPanelsForGroup{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
    
    //int groupExists = [self submitSQLRequestCheckGroupExists:currentGroupHashId];
    //NSLog(@"groupExists =%i", groupExists);
    
    //NSLog(@"currentGroupHashId =%@", currentGroupHashId);
    int panelsDownloaded = [self submitSQLRequestCheckPanelsDownloadedForGroup:currentGroupHashId];
    //NSLog(@"PanelLoader.submitRequestGetPanelsForGroup.panelsDownloaded=%i", panelsDownloaded);
    
    if(panelsDownloaded==0 && [self isReachable])
    {
        panelRequestType = kGetGroupPanels;
        //panelsDownloaded = YES;
        NSURLRequest* urlRequest = [self preparePanelRequestForGroup];
        [self submitPanelRequest:urlRequest];
    }
    else if(panelsDownloaded==1)
    {
        //NSLog(@"PanelLoader. Panels downloaded from the database.");
        //NSLog(@"[self submitSQLRequestCountPanelsForGroup:groupId]=%i", [self submitSQLRequestCountPanelsForGroup:groupId]);
        NSArray* panels = [self convertPanelsSQLIntoPanels:currentGroupHashId];
        if(panels!=nil && [panels count]>0)
        {
            currentNumPanels = [panels count];
            if([self.delegate respondsToSelector:@selector(PanelLoader:didLoadPanels:)])
                [self.delegate PanelLoader:self didLoadPanels:panels];
        }//end if(panels!=nil && [panels count>0])

    }
    /*
    if(!panelsDownloaded)
    {
        panelRequestType = kGetGroupPanels;
        panelsDownloaded = YES;
        NSURLRequest* urlRequest = [self preparePanelRequestForGroup:groupId];
        [self submitPanelRequest:urlRequest];
    }
    
    //});
    else
    {
        //NSLog(@"[self submitSQLRequestCountPanelsForGroup:groupId]=%i", [self submitSQLRequestCountPanelsForGroup:groupId]);
        NSArray* panels = [self convertPanelsSQLIntoPanels:groupId];
        if([self.delegate respondsToSelector:@selector(PanelLoader:didLoadPanels:)])
            [self.delegate PanelLoader:self didLoadPanels:panels];
    }
     */
}

-(void)submitRequestGetPanelWithId:(int)panelId{
    //If the panel is not in SQLite database, download it
    int panelExists = [self submitSQLRequestCheckPanelExists:panelId];
    int assestsExist =  [self submitSQLRequestGetAssetsForPanel:panelId];
    //NSLog(@"PanelLoader.submitRequestGetPanelWithId. panelId=%i, panelExists=%i, assestsExist=%i", panelId, panelExists, assestsExist);
    
    //Download panel if numplacements and numannotations values in panels table are -1, means panels and annotations not downloaded yet, and the internet is accessible
    if((panelExists==0 || assestsExist==0) && [self isReachable])
    {
        //NSLog(@"Panel#%i downloading from the server", panelId);
        panelRequestType = kGetPanel;
        NSURLRequest* urlRequest = [self preparePanelRequestForGetPanelWithId:panelId];
        [self submitPanelRequest:urlRequest];
    }
    //If panels and assets are already downloadeded, or if the internet is not accessible but the panel without assets has been downloaded earlier
    else if(assestsExist>0 || (panelExists>0 && ![self isReachable]))
    //else if(panelExists>0)
    {
        //NSLog(@"Panel#%i has assets already downloaded, or the app is offline", panelId);
        NSArray* panelsLocal = [self convertPanelSQLIntoPanel:panelId];
        if(panelsLocal!=nil && [panelsLocal count]>0)
        {
            Panel* panel = [panelsLocal objectAtIndex:0];
            if(panel!=nil)
            {
                if ([self.delegate respondsToSelector:@selector(PanelLoader:didLoadPanel:forObject:)])
                    [self.delegate PanelLoader:self didLoadPanel:panel forObject:obj];
                if ([self.delegate respondsToSelector:@selector(PanelLoader:didLoadPanel:)])
                    [self.delegate PanelLoader:self didLoadPanel:panel];
            }//end if(panel!=nil)
        }//end if(panelsLocal!=nil)
    }//end else if(assestsExist>0 || (panelExists>0 && ![self isReachable]))
}

-(void)submitRequestPostPanel:(Panel*)panel{
    panelRequestType = kPostPanel;
    NSURLRequest* urlRequest = [self preparePanelRequestForPostPanel:panel];
    [self submitPanelRequest:urlRequest];
}

-(void)submitPanelRequest:(NSURLRequest*)urlRequest{
    [self initConnectionRequest];
    [self submitURLRequest:urlRequest];
}

/*
-(NSURLRequest*)preparePanelRequestForGroup:(int)groupId{
    NSString *panelURL = [APIWrapper getURLForGetPanels];
    NSString* authenticatedPanelURL = [self authenticatedGetURL:panelURL];
    NSLog(@"authenticatedPanelURL=%@", authenticatedPanelURL);
    NSURL* url = [NSURL URLWithString:authenticatedPanelURL];
    return [NSURLRequest requestWithURL:url];
}
*/

-(NSURLRequest*)preparePanelRequestForGroup{
    NSString *panelURL = [APIWrapper getURLForGetPanels];
    NSString* authenticatedPanelURL = [self authenticatedGetURL:panelURL];
    //NSLog(@"preparePanelRequestForGroup.authenticatedPanelURL=%@", authenticatedPanelURL);
    NSURL* url = [NSURL URLWithString:authenticatedPanelURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)preparePanelRequestForGetPanelWithId:(int)panelId{
    NSString* panelURL = [APIWrapper getURLForGetPanelWithId:panelId];
    NSString* authenticatedPanelURL = [self authenticatedGetURL:panelURL];
    NSURL* url = [NSURL URLWithString:authenticatedPanelURL];
    return [NSURLRequest requestWithURL:url];
}

-(NSURLRequest*)preparePanelRequestForPostPanel:(Panel*)panel{
    NSString *panelURL = [APIWrapper getURLForPostPanel];
    NSURL* url = [NSURL URLWithString:panelURL];
    self.httpMethod = @"POST";
    self.request = panelURL;
    self.postRequestType = 1;
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self setPanelPostData:panel InURLRequest:urlRequest];
    return urlRequest;
}

-(void)setPanelPostData:(Panel*)panel InURLRequest:(NSMutableURLRequest*)urlRequest{
    
    NSDictionary* paneldict = [PanelJSONHandler convertPanelIntoPanelJSON:panel];
    paneldict = [self authenticatedPostData:paneldict];
    paneldict = [PanelJSONHandler wrapJSONDictWithDataTag:paneldict];
    NSError *error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:paneldict options:NSJSONWritingPrettyPrinted error:&error];
    [urlRequest setHTTPBody:data];
}


-(void)handleGetPanelsForGroupResponse{
    NSError* error;
    NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    //NSLog(@"handleGetPanelsForGroupResponse. [jsonArray count]=%i", [jsonArray count]);
    if (jsonArray != nil){
        NSArray* panels = [PanelJSONHandler convertPanelsJSONIntoPanels:jsonArray];
        //NSLog(@"handleGetPanelsForGroupResponse. [panels count]=%i", [panels count]);
        if(panels!=nil && [panels count]>0)
        {
            currentNumPanels = [panels count];
            //NSLog(@"handleGetPanelsForGroupResponse. [panels count]=%i", [panels count]);
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
            
            [self submitSQLRequestSavePanelsForGroup:panels andGroupHashId:currentGroupHashId];
            
            if([self.delegate respondsToSelector:@selector(PanelLoader:didLoadPanels:)])
                [self.delegate PanelLoader:self didLoadPanels:panels];
            
        }//end if(panels!=nil && [panels count]>0)
        

    }else{
        [self reportErrorToDelegate:error];
    }
}

-(void)handleRefreshGetPanelsForGroupResponse{
    NSError* error;
    NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (jsonArray != nil){
        NSArray* panels = [PanelJSONHandler convertPanelsJSONIntoPanels:jsonArray];
        
        if(panels!=nil && [panels count]>0)
        {
            //[self submitSQLRequestSavePanels:panels];
            //dispatch_queue_t panelQueue = dispatch_queue_create("automics.database", NULL);
            //dispatch_async([self dispatchQueue], ^(void) {
            //[self submitSQLRequestSavePanels:panels];
            //});
            //NSLog(@"handleGetPanelsForGroupResponse. [panels count]=%i", [panels count]);
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
            
            //int previousNumPanels = [self submitSQLRequestCountPanelsForGroup:currentGroupHashId];
            
            //NSLog(@"PanelLoader.handleRefreshGetPanelsForGroupResponse. currentNumPanels=%i, [new panels count]=%i" , currentNumPanels, [panels count]);
            
            if(currentNumPanels==[panels count])
            {
                //NSLog(@"PanelLoader.handleRefreshGetPanelsForGroupResponse. No new panel added.");
            }
            
            if([panels count]>currentNumPanels)
            {
                
                NSMutableArray* panelsNew = [[NSMutableArray alloc] init];
                for(int i=currentNumPanels; i<[panels count];i++)
                {
                    Panel* panel = [panels objectAtIndex:i];
                    if(panel!=nil){
                        [panelsNew addObject:panel];
                    }
                }//end for(int i=currentNumPanels; i<[panels count];i++)
                
                [self submitSQLRequestSavePanelsForGroup:panelsNew andGroupHashId:currentGroupHashId];
                currentNumPanels = [panels count];
                
                if([self.delegate respondsToSelector:@selector(PanelLoader:didLoadRefreshedPanels:)])
                 [self.delegate PanelLoader:self didLoadRefreshedPanels:panelsNew];
                
                
            }//end if([panels count]>previousNumPanels)
        }//end if(panels!=nil && [panels count]>0)
        
             
    }else{
        [self reportErrorToDelegate:error];
    }//end else
}

-(void)handleGetPanelWithIdResponse{
    NSError* error;
    NSDictionary* paneldict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    if (paneldict != nil){
        Panel *panel = [PanelJSONHandler convertPanelJSONDictIntoPanel:paneldict];
        if(panel!=nil){
            
            //[self submitSQLRequestSaveAssetsForPanel:panel.panelId andNumPlacements:[panel.placements count] andNumAnnotations:[panel.annotations count]];
            NSMutableArray* panels = [[NSMutableArray alloc] init];
            [panels addObject:panel];

            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
            
            //[self submitSQLRequestSavePanelsForGroup:panels andGroupHashId:currentGroupHashId];
            //NSLog(@"handleGetPanelWithIdResponse.submitSQLRequestSaveAssetsForPanel.panelId=%i", panel.panelId);
            //[self submitSQLRequestSaveAssetsForPanel:panel.panelId andGroupHashId:currentGroupHashId andPlacements:panel.placements andAnnotations:panel.annotations];
            [self submitSQLRequestSavePanelsWithAssetsForGroup:panels andGroupHashId:currentGroupHashId];
            
            //NSLog(@"handleGetPanelWithIdResponse. panelId=%i  has %i placements, %i annotations", panel.panelId, [panel.placements count], [panel.annotations count]);
            if ([self.delegate respondsToSelector:@selector(PanelLoader:didLoadPanel:forObject:)])
                [self.delegate PanelLoader:self didLoadPanel:panel forObject:obj];
            if ([self.delegate respondsToSelector:@selector(PanelLoader:didLoadPanel:)])
                [self.delegate PanelLoader:self didLoadPanel:panel];
        }//end if panel!=nil
    }else{
        [self reportErrorToDelegate:error];
    }
}

-(void)handlePostPanel{
    NSError* error;
    NSDictionary* paneldict = [NSJSONSerialization JSONObjectWithData:self.downloadedData options:NSJSONReadingMutableContainers error:&error];
    NSString *responseString = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    //NSLog(@"panelData: %@", responseString);
    if(paneldict != nil)
    {
        Panel *panel = [PanelJSONHandler convertPanelJSONDictIntoPanel:paneldict];
        NSMutableArray* panels = [[NSMutableArray alloc] init];
        [panels addObject:panel];
        //[self submitSQLRequestSavePanels:panels];
        
        //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        //NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
        //[self submitSQLRequestSavePanelsForGroup:panels andGroupHashId:currentGroupHashId];
        //[self submitSQLRequestSaveAssetsForPanel:panel.panelId andPlacements:panel.placements andAnnotations:panel.annotations];
        
        if ([self.delegate respondsToSelector:@selector(PanelLoader:didSavePanel:)])
            [self.delegate PanelLoader:self didSavePanel:responseString];
    }
    
    /*
    if (paneldict != nil){
        //Panel *panel = [PanelJSONHandler convertPanelJSONDictIntoPanel:paneldict];
        if ([self.delegate respondsToSelector:@selector(PanelLoader:didSavePanel:)])
            [self.delegate PanelLoader:self didSavePanel:panel];
    }
     */
}

-(void)reportErrorToDelegate:(NSError*)error{
    if ([self.delegate respondsToSelector:@selector(PanelLoader:didFailWithError:)])
        [delegate PanelLoader:self didFailWithError:error];
}

-(void)downloadErrorWithErrorCode:(NSInteger)errorCode ForConnection:(NSURLConnection*) connection{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Application cannot download data. Please check your internet connection."
                                                         forKey:NSLocalizedDescriptionKey];
    NSError *error = [[NSError alloc] initWithDomain:@"" code:errorCode userInfo:userInfo];
    [self reportErrorToDelegate:error];
}

-(void)cancelPanelLoad{
    [self cancelRequest];
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{

    [super connectionDidFinishLoading:connection];
    //NSLog(@"self.downloadedData.length=%i", self.downloadedData.length);
    if (self.downloadedData.length > 0){
        switch (panelRequestType){
            case kGetGroupPanels:
                [self handleGetPanelsForGroupResponse];
                break;
            case kGetPanel:
                [self handleGetPanelWithIdResponse];
                break;
            case kPostPanel:
                [self handlePostPanel];
                break;
            case kRefreshGetGroupPanels:
                [self handleRefreshGetPanelsForGroupResponse];
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

