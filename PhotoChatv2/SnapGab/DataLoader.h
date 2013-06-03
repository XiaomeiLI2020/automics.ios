//
//  DataLoader.h
//  PhotoChat
//
//  Created by Shakir Ali on 15/02/2013.
//  Copyright (c) 2013 Horizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


NSString *databasePathStatic;
//BOOL reachabilityChanged = NO;

@interface DataLoader : NSObject<NSURLConnectionDataDelegate>{
    NSMutableData  *downloadedData;
    NSURLConnection *dataFeedConnection;
}

@property sqlite3* database;
@property NSString *databasePath;


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

//+(void)changeReachability;

//check online/offline status
-(BOOL)isReachable;

//Tables
-(void)submitSQLRequestCreateTablesForGroup:(int)groupId;
-(void)submitSQLRequestCreateTablesForApp;

//Panels
-(int)submitSQLRequestCountPanelsForGroup:(int)groupId;
-(void)submitSQLRequestGetPanelsForGroup:(int)groupId;
-(void)submitSQLRequestSavePanels:(NSArray*)panels;
-(void)submitSQLRequestSavePanelsForGroup:(NSArray*)panels andGroupId:(int)groupId;
-(NSArray*)convertPanelsSQLIntoPanels:(int)groupId;
-(NSArray*)convertPanelSQLIntoPanel:(int)panelId;
-(void)submitSQLRequestGetPanelForId:(int)panelId;
-(int)submitSQLRequestGetAssetsForPanel:(int)panelId;
-(int)submitSQLRequestCheckPanelExists:(int)panelId;
//-(void)submitSQLRequestSaveAssetsForPanel:(int)panelId andNumPlacements:(int)numPlacements andNumAnnotations:(int)numAnnotations;
-(void)submitSQLRequestSaveAssetsForPanel:(int)panelId andPlacements:(NSArray*)placements andAnnotations:(NSArray*)annotations;

//Resources
-(int)submitSQLRequestCheckThemeExists:(int)themeId;
-(int)submitSQLRequestCheckResourceExists:(int)resourceId;
-(NSArray*)convertResourcesSQLIntoResources:(int)themeId;
-(NSArray*)convertResourceSQLIntoResource:(int)resourceId;
-(void)submitSQLRequestSaveResource:(int)resourceId andThemeId:(int)themeId andType:(NSString*)type andImageURL:(NSString*)imageURL andThumbURL:(NSString*)thumbURL;
-(void)submitSQLRequestSaveResources:(NSArray*)resources;

//Comics
-(int)submitSQLRequestCountComicsForGroup:(int)groupId;
-(void)submitSQLRequestSaveComics:(NSArray*)comics;
-(NSArray*)convertComicsSQLIntoComics:(int)groupId;
-(int)submitSQLRequestCheckComicExists:(int)comicId;
-(NSArray*)convertComicSQLIntoComic:(int)comicId;

@end