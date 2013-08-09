//
//  DataLoader.h
//  PhotoChat
//
//  Created by Shakir Ali on 15/02/2013.
//  Copyright (c) 2013 Horizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

//sqlite3* database;
NSString *databasePathStatic;


//BOOL reachabilityChanged = NO;
//extern dispatch_queue_t databaseQueue1;

@interface DataLoader : NSObject<NSURLConnectionDataDelegate>{
    NSMutableData  *downloadedData;
    NSURLConnection *dataFeedConnection;
}

//@property sqlite3* database;
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
-(dispatch_queue_t)dispatchQueue;

//+(void)changeReachability;

//check online/offline status
-(BOOL)isReachable;

//Close database when the app terminates
+(void)closeDatabase;

//Tables
//-(void)submitSQLRequestCreateTablesForGroup:(int)groupId;
-(void)initiateSQL;
-(void)submitSQLRequestCreateTablesForApp;

//Organisations: Insert into database
-(void)submitSQLRequestSaveOrganisations:(NSArray*)organisations;

//Themes: Insert into database
//-(void)submitSQLRequestSavePanelsForGroup:(NSArray*)panels andGroupHashId:(NSString*)groupHashId;

//Panels: Insert into database
-(void)submitSQLRequestSavePanelsForGroup:(NSArray*)panels andGroupHashId:(NSString*)groupHashId;
//-(void)submitSQLRequestSaveAssetsForPanel:(int)panelId andPlacements:(NSArray*)placements andAnnotations:(NSArray*)annotations;
-(void)submitSQLRequestSaveAssetsForPanel:(int)panelId andGroupHashId:(NSString*)groupHashId andPlacements:(NSArray*)placements andAnnotations:(NSArray*)annotations;
-(void)submitSQLRequestSavePanelsWithAssetsForGroup:(NSArray*)panels andGroupHashId:(NSString*)groupHashId;

//Panels: Retrieve from database
-(int)submitSQLRequestCheckPanelsDownloadedForGroup:(NSString*)groupHashId;
-(int)submitSQLRequestCountPanelsForGroup:(NSString*)groupHashId;
-(NSArray*)convertPanelsSQLIntoPanels:(NSString*)groupHashId;
-(NSArray*)convertPanelSQLIntoPanel:(int)panelId;
//-(void)submitSQLRequestGetPanelForId:(int)panelId;
-(int)submitSQLRequestGetAssetsForPanel:(int)panelId;
-(int)submitSQLRequestCheckPanelExists:(int)panelId;
-(int)submitSQLRequestCheckPanelExistsSync:(int)panelId;


//Photos: Insert into database
-(void)submitSQLRequestSavePhotos:(NSArray*)photos andGroupHashId:(NSString*)groupHashId;

//Photos: Retrieve from database
-(int)submitSQLRequestCheckPhotosDownloadedForGroup:(NSString*)groupHashId;
-(NSArray*)convertPhotosSQLIntoPhotos:(NSString*)groupHashId;

//Groups: Insert into database
-(void)submitSQLRequestSaveGroups:(NSArray*)groups;

//Groups: Retrieve from database
-(int)submitSQLRequestCheckGroupExists:(NSString*)groupHashId;
-(NSArray*)convertGroupsSQLIntoGroups;
-(NSArray*)convertGroupSQLIntoGroup:(NSString*)groupHashId;
-(void)submitSQLRequestLeaveGroup:(NSString*)groupHashId;

//Resources: Insert into database
-(void)submitSQLRequestSaveResource:(int)resourceId andThemeId:(int)themeId andType:(NSString*)type andImageURL:(NSString*)imageURL andThumbURL:(NSString*)thumbURL;
//-(void)submitSQLRequestSaveResources:(NSArray*)resources;
-(void)submitSQLRequestSaveResources:(NSArray*)resources andThemeId:(int)themeId;
-(void)submitSQLRequestSaveAllResources:(NSArray*)resources andThemeId:(int)themeId;

//Resources: Retrieve from database
-(int)submitSQLRequestCheckThemeExists:(int)themeId;
-(int)submitSQLRequestCheckResourcesDownloadedForTheme:(int)themeId;
-(int)submitSQLRequestCheckResourceExists:(int)resourceId;
-(NSArray*)convertResourcesSQLIntoResources:(int)themeId;
-(NSArray*)convertResourceSQLIntoResource:(int)resourceId;

//Comics: Insert into database
-(void)submitSQLRequestSaveComicsForGroup:(NSArray*)comics andGroupHashId:(NSString*)groupHashId;

//Comics: Retrieve from database
-(int)submitSQLRequestCheckComicsDownloadedForGroup:(NSString*)groupHashId;
-(int)submitSQLRequestCountComicsForGroup:(NSString*)groupHashId;
-(NSArray*)convertComicsSQLIntoComics:(NSString*)groupHashId;
-(int)submitSQLRequestCheckComicExists:(int)comicId;
-(NSArray*)convertComicSQLIntoComic:(int)comicId;

//Users: Insert into database
-(void)submitSQLRequestSaveUsers:(NSArray*)users;
-(void)submitSQLRequestUpdateCurrentGroup:(NSString*)groupHashId andUserId:(int)userId;
-(void)submitSQLRequestUpdateGroupsDownloaded:(int)groupsDownloaded andUserId:(int)userId;

//Users: Retrieve from database
-(int)submitSQLRequestCheckUserExists:(int)userId;
-(int)submitSQLRequestCheckUserLoggedOut:(int)userId;
-(int)submitSQLRequestCheckGroupsDownloaded:(int)userId;
-(int)submitSQLRequestCheckLoggedInUser;
-(NSArray*)convertUsersSQLIntoUsers:(int)userId;


@end