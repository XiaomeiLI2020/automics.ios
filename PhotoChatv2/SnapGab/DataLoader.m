//
//  DataLoader.m
//  PhotoChat
//
//  Created by Shakir Ali on 15/02/2013.
//  Copyright (c) 2013 Horizon. All rights reserved.
//

#import "DataLoader.h"

#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"
#import "AppDelegate.h"
//#import "DataValidator.h"
#import "Annotation.h"
#import "Placement.h"
#import "Group.h"



@implementation DataLoader
@synthesize postRequestType;
@synthesize dict;
@synthesize request;
@synthesize httpMethod;
@synthesize downloadedData;
@synthesize dataFeedConnection;
//@synthesize database;
@synthesize databasePath;

BOOL databaseUpdating;
sqlite3* database;

//dispatch_queue_t databaseQueue;

/*
+(void)changeReachability{
    reachabilityChanged = !reachabilityChanged;
}
 */

+(void)closeDatabase{
    sqlite3_close(database);
}

-(dispatch_queue_t)dispatchQueue{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.databaseQueue;
}

-(void)initConnectionRequest{
    if (dataFeedConnection)
        [dataFeedConnection cancel];
    self.dataFeedConnection = nil;
    self.downloadedData = nil;
}

-(NSString*)authenticatedGetURL:(NSString*)urlString
{
    NSString* authenticatedURL;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* sessionToken = [prefs objectForKey:@"session"];
    
    NSRange rangeValue = [urlString rangeOfString:@"?" options:NSCaseInsensitiveSearch];
    if (rangeValue.length > 0){
        
        NSLog(@"string contains ?");
        authenticatedURL = [NSString stringWithFormat:@"%@&session=%@", urlString, sessionToken];

    }
    else
        authenticatedURL = [NSString stringWithFormat:@"%@?session=%@", urlString, sessionToken];

    //NSString* authenticatedURL = [NSString stringWithFormat:@"%@?session=%@", urlString, sessionToken];
    return authenticatedURL;
}

-(NSDictionary*)authenticatedPostData:(NSDictionary*)dictionary
{

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* sessionToken = [prefs objectForKey:@"session"];
    [dictionary setValue:sessionToken forKey:@"session"];
    return dictionary;
}

-(void)submitURLRequest:(NSURLRequest*)urlRequest{
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
    [urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [urlConnection start];
    self.dataFeedConnection = urlConnection;
}

-(void)cancelRequest{
    [self initConnectionRequest];
}

-(BOOL)isReachable{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSLog(@"[appDelegate.automicsEngine isReachable]=%d", [appDelegate.automicsEngine isReachable]);
    return [appDelegate.automicsEngine isReachable];
}

-(void)submitSQLRequestCreateTablesForApp{
    NSError *err;
    NSString *docsDir;
    NSArray *dirPaths;
    NSString* appName = [NSString stringWithFormat: @"automics.sql"];
    //databaseQueue = dispatch_queue_create("automics.database", NULL);
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:appName]];
    databasePathStatic = databasePath;
    //NSLog(@"databasePath=%@, databasePathStatic=%@ ", databasePath, databasePathStatic);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    //Deleteing the previous version of the database file
    [filemgr removeItemAtPath:databasePath error:&err];
    if(err)
    {
        NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    }
    else
    {
        //NSLog(@"File %@ deleted.", appName);
    }

    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
		const char *dbpath = [databasePath UTF8String];
        if(sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *groups_stmt = "CREATE TABLE IF NOT EXISTS GROUPS (GROUPHASHID TEXT PRIMARY KEY, GROUPID INTEGER, NAME TEXT, THEMEID INTEGER, ORGANISATIONID INTEGER, PANELSDOWNLOADED INTEGER, PHOTOSDOWNLOADED INTEGER, COMICSDOWNLOADED INTEGER)";
            
            const char *organisations_stmt = "CREATE TABLE IF NOT EXISTS ORGANISATIONS (ORGANISATIONID INTEGER PRIMARY KEY, NAME TEXT)";
            
            const char *themes_stmt = "CREATE TABLE IF NOT EXISTS THEMES (THEMEID INTEGER PRIMARY KEY, ORGANISATIONID INTEGER, NAME TEXT)";
            
            const char *panels_stmt = "CREATE TABLE IF NOT EXISTS PANELS (PANELID INTEGER, GROUPHASHID TEXT,  PHOTOID INTEGER, PHOTOURL TEXT, NUMPLACEMENTS REAL, NUMANNOTATIONS REAL, PRIMARY KEY(PANELID, GROUPHASHID))";
            
            //const char *panels_stmt = "CREATE TABLE IF NOT EXISTS PANELS (PANELID INTEGER PRIMARY KEY, GROUPHASHID TEXT,  PHOTOID INTEGER, PHOTOURL TEXT, NUMPLACEMENTS REAL, NUMANNOTATIONS REAL)";
            
            const char *photos_stmt = "CREATE TABLE IF NOT EXISTS PHOTOS (PHOTOID INTEGER, GROUPHASHID TEXT, PHOTOURL TEXT, THUMBURL TEXT, DESCRIPTION TEXT, WIDTH REAL, HEIGHT REAL, PhotoData BLOB, PRIMARY KEY(PhotoID, GROUPHASHID))";
            
            //const char *photos_stmt = "CREATE TABLE IF NOT EXISTS PHOTOS (PHOTOID INTEGER PRIMARY KEY, GROUPHASHID TEXT, PHOTOURL TEXT, THUMBURL TEXT, DESCRIPTION TEXT, WIDTH REAL, HEIGHT REAL)";
            
            const char *resources_stmt = "CREATE TABLE IF NOT EXISTS RESOURCES (RESOURCEID INTEGER, THEMEID INTEGER, NAME TEXT, TYPE TEXT, PHOTOURL TEXT, THUMBURL TEXT, PRIMARY KEY(RESOURCEID, THEMEID))";
            
            const char *placements_stmt = "CREATE TABLE PLACEMENTS (PLACEMENTID INTEGER, PANELID INTEGER, GROUPHASHID TEXT, RESOURCEID INTEGER, XOFF REAL, YOFF REAL, SCALE REAL, ANGLE REAL, ZINDEX INTEGER, PRIMARY KEY(PLACEMENTID, PANELID, GROUPHASHID))";
            
            const char *annotations_stmt = "CREATE TABLE IF NOT EXISTS ANNOTATIONS (ANNOTATIONID INTEGER, PANELID INTEGER, GROUPHASHID TEXT, TXT TEXT, XOFF REAL, YOFF REAL, BUBBLESTYLE INTEGER, FOPTIONS TEXT, PRIMARY KEY(ANNOTATIONID, PANELID, GROUPHASHID))";
            
            const char *comics_stmt = "CREATE TABLE IF NOT EXISTS COMICS (COMICID INTEGER, GROUPHASHID TEXT, NAME TEXT, DESCRIPTION TEXT, NUMPANELS INTEGER, PRIMARY KEY(COMICID, GROUPHASHID))";
            
            //const char *comicpanels_stmt = "CREATE TABLE IF NOT EXISTS COMICPANELS (ID INTEGER PRIMARY KEY, COMICID INTEGER, GROUPHASHID TEXT, PANELID INTEGER, PANELPOSITION INTEGER)";
            
            const char *comicpanels_stmt = "CREATE TABLE IF NOT EXISTS COMICPANELS (COMICID INTEGER, GROUPHASHID TEXT, PANELID INTEGER, PANELPOSITION INTEGER, PRIMARY KEY(COMICID, GROUPHASHID, PANELPOSITION))";
            
            if (sqlite3_exec(database, groups_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Group table failed to create.");
            }
            if (sqlite3_exec(database, organisations_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Organisation table failed to create.");
            }
            if (sqlite3_exec(database, themes_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Theme table failed to create.");
            }
            if (sqlite3_exec(database, panels_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Panel table failed to create.");
            }
            /*
             else
             NSLog(@"Panel table created.");
             */
            
            if (sqlite3_exec(database, photos_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Photo table failed to create.");
            }
            /*
             else
             NSLog(@"Photo table created.");
             */
            if (sqlite3_exec(database, placements_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Placement table failed to create.");
            }
            /*
             else
             NSLog(@"Placement table created.");
             */
            if (sqlite3_exec(database, resources_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Resource table failed to create.");
            }
            /*
             else
             NSLog(@"Resource table created.");
             */
            if (sqlite3_exec(database, annotations_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Annotation table failed to create.");
            }
            /*
             else
             NSLog(@"Annotation table created.");
             */
            if (sqlite3_exec(database, comics_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Comic table failed to create.");
            }
            if (sqlite3_exec(database, comicpanels_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Comicpanel table failed to create.");
            }
            //sqlite3_close(database);
            
        }//end if(sqlite3_open(dbpath, &database) == SQLITE_OK)
        else {
            NSLog(@"Failed to open/create database");
        }
    }//end if ([filemgr fileExistsAtPath: databasePath ] == NO)
    
}


-(int)submitSQLRequestCheckPanelsDownloadedForGroup:(NSString*)groupHashId{
    
    __block int rowCount=0;
    //NSLog(@"DataLoader. submitSQLRequestCheckPanelsDownloadedForGroup. databaseUpdating=%d, groupHashId=%@", databaseUpdating, groupHashId);
    if(databaseUpdating)
    {
        dispatch_async([self dispatchQueue], ^(void) {
        
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select panelsdownloaded from groups where grouphashid=\"%@\"", groupHashId];
            //NSLog(@"submitSQLRequestCheckPanelsDownloadedForGroup.retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //NSLog(@"submitSQLRequestCheckPanelsDownloadedForGroup. Rowcount is %d",rowCount);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestCheckPanelsDownloadedForGroup.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        });

    }//end if
    else{
        //dispatch_async([self dispatchQueue], ^(void) {
        
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select panelsdownloaded from groups where grouphashId=\"%@\"", groupHashId];
            //NSLog(@"submitSQLRequestCheckPanelsDownloadedForGroup.retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //NSLog(@"submitSQLRequestCheckPanelsDownloadedForGroup. Rowcount is %d",rowCount);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestCheckPanelsDownloadedForGroup.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        //});

    }//end else
    
    return rowCount;
}

-(int)submitSQLRequestCheckComicsDownloadedForGroup:(NSString*)groupHashId{
    
    __block int rowCount=0;
    //NSLog(@"DataLoader. submitSQLRequestCheckComicsDownloadedForGroup. databaseUpdating=%d, groupHashId=%@", databaseUpdating, groupHashId);
    if(databaseUpdating)
    {
        //dispatch_async([self dispatchQueue], ^(void) {
        
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select comicsdownloaded from groups where grouphashid=\"%@\"", groupHashId];
            //NSLog(@"submitSQLRequestCheckPanelsDownloadedForGroup.retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //NSLog(@"submitSQLRequestCheckComicsDownloadedForGroup. Rowcount is %d",rowCount);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestCheckComicsDownloadedForGroup.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        //});

    }
    else{
        //dispatch_async([self dispatchQueue], ^(void) {
        
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select comicsdownloaded from groups where grouphashid=\"%@\"", groupHashId];
            //NSLog(@"submitSQLRequestCheckPanelsDownloadedForGroup.retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //NSLog(@"submitSQLRequestCheckComicsDownloadedForGroup. Rowcount is %d",rowCount);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestCheckComicsDownloadedForGroup.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        //});

    }
       
    return rowCount;
}

-(int)submitSQLRequestCheckPhotosDownloadedForGroup:(NSString*)groupHashId{
    
    __block int rowCount=0;
    //NSLog(@"DataLoader. submitSQLRequestCheckPhotosDownloadedForGroup. databaseUpdating=%d, groupHashId=%@", databaseUpdating, groupHashId);
    if(databaseUpdating){
        dispatch_async([self dispatchQueue], ^(void) {
        
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select photosdownloaded from groups where grouphashid=\"%@\"", groupHashId];
            //NSLog(@"submitSQLRequestCheckPanelsDownloadedForGroup.retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //NSLog(@"submitSQLRequestCheckPhotosDownloadedForGroup. Rowcount is %d",rowCount);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestCheckPhotosDownloadedForGroup.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        });

    }//end if
    else{
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select photosdownloaded from groups where grouphashid=\"%@\"", groupHashId];
            //NSLog(@"submitSQLRequestCheckPanelsDownloadedForGroup.retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //NSLog(@"submitSQLRequestCheckPhotosDownloadedForGroup. Rowcount is %d",rowCount);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestCheckPhotosDownloadedForGroup.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    }//end else
    return rowCount;
}


-(int)submitSQLRequestCheckResourceExists:(int)resourceId
{
    __block int rowCount=0;
    //NSLog(@"submitSQLRequestCheckResourceExists. resourceId=%i, databaseUpdating=%d", resourceId, databaseUpdating);
    if(databaseUpdating)
    {
        dispatch_async([self dispatchQueue], ^(void) {
            
            //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
            {
                //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
                NSString *retrieveSQL = [NSString stringWithFormat: @"select COUNT(*) from resources where resourceId=%i", resourceId];
                //NSLog(@"retrieveSQL=%@", retrieveSQL);
                const char* sqlStatement = [retrieveSQL UTF8String];
                sqlite3_stmt *statement;
                
                if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
                {
                    //Loop through all the returned rows (should be just one)
                    //if(sqlite3_step(statement)!=SQLITE_ROW)
                    //    NSLog(@"Rowcount is %d",rowCount);
                    
                    while(sqlite3_step(statement) == SQLITE_ROW )
                    {
                        rowCount = sqlite3_column_int(statement, 0);
                        //NSLog(@"Rowcount is %d",rowCount);
                    }
                }
                else
                {
                    NSLog( @"submitSQLRequestCheckResourceExists.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
                }
                
                // Finalize and close database.
                sqlite3_finalize(statement);
                //sqlite3_close(database);
            }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
            
        });

    }
    else{
            //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
            {
                //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
                NSString *retrieveSQL = [NSString stringWithFormat: @"select COUNT(*) from resources where resourceId=%i", resourceId];
                //NSLog(@"retrieveSQL=%@", retrieveSQL);
                const char* sqlStatement = [retrieveSQL UTF8String];
                sqlite3_stmt *statement;
                
                if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
                {
                    //Loop through all the returned rows (should be just one)
                    //if(sqlite3_step(statement)!=SQLITE_ROW)
                    //    NSLog(@"Rowcount is %d",rowCount);
                    
                    while(sqlite3_step(statement) == SQLITE_ROW )
                    {
                        rowCount = sqlite3_column_int(statement, 0);
                        //NSLog(@"Rowcount is %d",rowCount);
                    }
                }
                else
                {
                    NSLog( @"submitSQLRequestCheckResourceExists.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
                }
                
                // Finalize and close database.
                sqlite3_finalize(statement);
                //sqlite3_close(database);
            }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    }
    
    return rowCount;
}

-(NSArray*)convertComicSQLIntoComic:(int)comicId{
    
    //NSLog(@"DataLoader.convertComicSQLIntoComic.comicId=%i", comicId);
    
    NSMutableArray* comics = [[NSMutableArray alloc] init];
    
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSString* currentGroupHashId = [prefs objectForKey:@"current_group_hash"];
    
    if(databaseUpdating)
    {
        dispatch_async([self dispatchQueue], ^(void) {
        NSMutableArray* panels = [[NSMutableArray alloc] init];
        Comic *comic =[[Comic alloc] init];
        


            //const char* sqlStatement = "SELECT photoid, photourl FROM PANELS where panelId";
            NSString *selectSQL = [NSString stringWithFormat: @"SELECT panelid, panelposition FROM ComicPanels where comicId=%i", comicId];
            //NSLog(@"selectSQL=%@", selectSQL);
            const char *sqlStatement = [selectSQL UTF8String];
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    int panelId=sqlite3_column_int(statement, 0);
                    //int panelPosition=sqlite3_column_int(statement, 1);
                    
                    //NSLog( @"convertComicSQLIntoComic.Before panels insertObjectAtIndex:panelId=%i, panelPosition=%i", panelId, panelPosition);
                    
                    Panel* panel = [[Panel alloc] init];
                    panel.panelId = panelId;
                    [panels addObject:panel];
                    //[panels insertObject:panel atIndex:panelPosition];
                    
                }//end while
            }//end if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            else
            {
                NSLog( @"convertComicSQLIntoComic.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }

            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
            
            comic.panels = panels;
            [comics addObject:comic];
         });
        
    }//end if
    else{
        
        NSMutableArray* panels = [[NSMutableArray alloc] init];
        Comic *comic =[[Comic alloc] init];

        //const char* sqlStatement = "SELECT photoid, photourl FROM PANELS where panelId";
        NSString *selectSQL = [NSString stringWithFormat: @"SELECT panelid, panelposition FROM ComicPanels where comicId=%i", comicId];
        //NSLog(@"selectSQL=%@", selectSQL);
        const char *sqlStatement = [selectSQL UTF8String];
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                int panelId=sqlite3_column_int(statement, 0);
                //int panelPosition=sqlite3_column_int(statement, 1);
                
                //NSLog( @"convertComicSQLIntoComic.Before panels insertObjectAtIndex:panelId=%i, panelPosition=%i", panelId, panelPosition);
                
                Panel* panel = [[Panel alloc] init];
                panel.panelId = panelId;
                [panels addObject:panel];
                //[panels insertObject:panel atIndex:panelPosition];
                
            }//end while
        }//end if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        else
        {
            NSLog( @"convertComicSQLIntoComic.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        //sqlite3_close(database);
        
        comic.panels = panels;
        [comics addObject:comic];
    }
   
    return comics;
    
}

-(int)submitSQLRequestCheckComicExists:(int)comicId
{
    __block int rowCount=0;
    if(databaseUpdating)
    {
        dispatch_async([self dispatchQueue], ^(void) {
            
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select COUNT(*) from comics where comicId=%i", comicId];
            //NSLog(@"retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //NSLog(@"Rowcount is %d",rowCount);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestCheckComicExists.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
            
        });

        
    }//end if
    else{
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select COUNT(*) from comics where comicId=%i", comicId];
            //NSLog(@"retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //NSLog(@"Rowcount is %d",rowCount);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestCheckComicExists.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
    }//end else
    return rowCount;
}

-(int)submitSQLRequestCheckGroupExists:(NSString*)groupHashId{
    __block int rowCount=0;
    
    if(databaseUpdating)
    {
        dispatch_async([self dispatchQueue], ^(void) {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select COUNT(*) from groups where grouphashid=\"%@\"", groupHashId];
            //NSLog(@"retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //NSLog(@"Rowcount is %d",rowCount);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestCheckGroupExists.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
                });
    }//end if
    else{
        
        //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
        NSString *retrieveSQL = [NSString stringWithFormat: @"select COUNT(*) from groups where grouphashid=\"%@\"", groupHashId];
        //NSLog(@"retrieveSQL=%@", retrieveSQL);
        const char* sqlStatement = [retrieveSQL UTF8String];
        sqlite3_stmt *statement;
        
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            //if(sqlite3_step(statement)!=SQLITE_ROW)
            //    NSLog(@"Rowcount is %d",rowCount);
            
            while(sqlite3_step(statement) == SQLITE_ROW )
            {
                rowCount = sqlite3_column_int(statement, 0);
                //NSLog(@"Rowcount is %d",rowCount);
            }
        }
        else
        {
            NSLog( @"submitSQLRequestCheckGroupExists.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        //sqlite3_close(database);
    }
    
  
    return rowCount;
}

-(int)submitSQLRequestCheckPanelExistsSync:(int)panelId{
    

    __block int rowCount=0;
    
    //dispatch_async([self dispatchQueue], ^(void) {
    
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select COUNT(*) from panels where panelId=%i", panelId];
            //NSLog(@"retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            
            if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //NSLog(@"Rowcount is %d",rowCount);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestCheckPanelExists.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
    //});
    return rowCount;
}


-(int)submitSQLRequestCheckPanelExists:(int)panelId{

    //NSLog(@"DataLoader.submitSQLRequestCheckPanelExists.databaseUpdating=%d, panelId=%i", databaseUpdating, panelId);
    __block int rowCount=0;
    //__block int placementCount=0;
    //__block int annotationCount=0;
    //__block int panelDownloaded=0;
    
    if(databaseUpdating)
    {
        dispatch_async([self dispatchQueue], ^(void) {
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select COUNT(*) from panels where panelId=%i", panelId];
            //NSLog(@"retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //placementCount = sqlite3_column_int(statement, 1);
                    //annotationCount = sqlite3_column_int(statement, 1);
                    //NSLog(@"Rowcount is %d",rowCount);
                }//end while
            }//end if
            else
            {
                NSLog( @"submitSQLRequestCheckPanelExists.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
            
            /*
            if(rowCount>0)
            {
                panelDownloaded =  [self submitSQLRequestGetAssetsForPanel:panelId];
            }//end if(rowCount>0)
             */
            
            //NSLog(@"submitSQLRequestCheckPanelExists.panelId=%i, rowcount=%i, panelDownloaded=%i, databaseUpdating=%d", panelId, rowCount, panelDownloaded, databaseUpdating);
        });
    }
    else{
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select COUNT(*) from panels where panelId=%i", panelId];
            //NSLog(@"retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //NSLog(@"Rowcount is %d",rowCount);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestCheckPanelExists.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        /*
        if(rowCount>0)
        {
            panelDownloaded =  [self submitSQLRequestGetAssetsForPanel:panelId];
        }//end if(rowCount>0)
        */
            //NSLog(@"DataLoader.submitSQLRequestCheckPanelExists.panelId=%i, rowcount=%i, panelDownloaded=%i, databaseUpdating=%d", panelId, rowCount, panelDownloaded, databaseUpdating);
    }//end else
    
    //return panelDownloaded;
    return rowCount;
}


-(int)submitSQLRequestCheckPanelExistsLocal:(int)panelId{
    
    //NSLog(@"DataLoader.submitSQLRequestCheckPanelExists.databaseUpdating=%d, panelId=%i", databaseUpdating, panelId);
    __block int rowCount=0;
   //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select COUNT(*) from panels where panelId=%i", panelId];
            //NSLog(@"retrieveSQL=%@", retrieveSQL);
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    rowCount = sqlite3_column_int(statement, 0);
                    //NSLog(@"Rowcount is %d",rowCount);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestCheckPanelExists.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)

    return rowCount;
}



-(int)submitSQLRequestGetAssetsForPanel:(int)panelId{
    

    __block int rowCount=0;
    __block float numPlacements=-1;
    __block float numAnnotations=-1;
    //NSLog(@"DataLoader.submitSQLRequestGetAssetsForPanel.panelId=%i", panelId);
    if(databaseUpdating)
    {
        dispatch_async([self dispatchQueue], ^(void) {
            
            //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
            {
                //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
                NSString *retrieveSQL = [NSString stringWithFormat: @"select numplacements, numannotations from panels where panelId=%i", panelId];
                const char* sqlStatement = [retrieveSQL UTF8String];
                sqlite3_stmt *statement;
                
                if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
                {
                    //Loop through all the returned rows (should be just one)
                    //if(sqlite3_step(statement)!=SQLITE_ROW)
                    //    NSLog(@"Rowcount is %d",rowCount);
                    
                    while(sqlite3_step(statement) == SQLITE_ROW )
                    {
                        numPlacements = sqlite3_column_double(statement, 0);
                        numAnnotations = sqlite3_column_double(statement, 1);
                        //NSLog(@"panelId=%i has numPlacements=%f, numAnnotations=%f", panelId, numPlacements, numAnnotations);
                    }
                }
                else
                {
                    NSLog( @"submitSQLRequestGetAssetsForPanel.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
                }
                
                // Finalize and close database.
                sqlite3_finalize(statement);
                //sqlite3_close(database);
            }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
            


        });
        if(numPlacements>=0 && numAnnotations>=0)
            return 1;
        else
            return 0;
    }//end if
    else{
        
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select numplacements, numannotations from panels where panelId=%i", panelId];
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK)
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    numPlacements = sqlite3_column_double(statement, 0);
                    numAnnotations = sqlite3_column_double(statement, 1);
                    //NSLog(@"numPlacements=%f, numAnnotations=%f", numPlacements, numAnnotations);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestGetAssetsForPanel.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        if(numPlacements>=0 && numAnnotations>=0)
            return 1;
        else
            return 0;
    }//end else
    
     return rowCount;
}


-(int)submitSQLRequestGetAssetsForPanelLocal:(int)panelId{
    
    
    __block int rowCount=0;
    __block float numPlacements=-1;
    __block float numAnnotations=-1;
        
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
            NSString *retrieveSQL = [NSString stringWithFormat: @"select numplacements, numannotations from panels where panelId=%i", panelId];
            const char* sqlStatement = [retrieveSQL UTF8String];
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK)
            {
                //Loop through all the returned rows (should be just one)
                //if(sqlite3_step(statement)!=SQLITE_ROW)
                //    NSLog(@"Rowcount is %d",rowCount);
                
                while(sqlite3_step(statement) == SQLITE_ROW )
                {
                    numPlacements = sqlite3_column_double(statement, 0);
                    numAnnotations = sqlite3_column_double(statement, 1);
                    //NSLog(@"numPlacements=%f, numAnnotations=%f", numPlacements, numAnnotations);
                }
            }
            else
            {
                NSLog( @"submitSQLRequestGetAssetsForPanel.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        if(numPlacements>=0 && numAnnotations>=0)
            return 1;
        else
            return 0;
    
    return rowCount;
}


-(int)submitSQLRequestCountComicsForGroup:(NSString*)groupHashId{
    __block int rowCount=0;

    if(databaseUpdating){
        
        dispatch_async([self dispatchQueue], ^(void) {
        NSString *insertSQL = [NSString stringWithFormat: @"SELECT COUNT(*) FROM Comics where grouphashid=\"%@\"", groupHashId];
        //NSLog(@"insertSQL=%@", insertSQL);
        const char* sqlStatement = [insertSQL UTF8String];
        //const char* sqlStatement = "SELECT COUNT(*) FROM PANELS";
        sqlite3_stmt *statement;
        
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                rowCount = sqlite3_column_int(statement, 0);
                //NSLog(@"Rowcount is %d",rowCount);
            }
        }
        else
        {
            NSLog( @"submitSQLRequestCountComicsForGroup.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        //sqlite3_close(database);
        });
    }//end if
    else{
        NSString *insertSQL = [NSString stringWithFormat: @"SELECT COUNT(*) FROM Comics where grouphashid=\"%@\"", groupHashId];
        //NSLog(@"insertSQL=%@", insertSQL);
        const char* sqlStatement = [insertSQL UTF8String];
        //const char* sqlStatement = "SELECT COUNT(*) FROM PANELS";
        sqlite3_stmt *statement;
        
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                rowCount = sqlite3_column_int(statement, 0);
                //NSLog(@"Rowcount is %d",rowCount);
            }
        }
        else
        {
            NSLog( @"submitSQLRequestCountComicsForGroup.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        //sqlite3_close(database);
    }//end else

    return rowCount;
}
 


-(int)submitSQLRequestCountPanelsForGroup:(NSString*)groupHashId{
    __block int rowCount=0;
    if(databaseUpdating){
        dispatch_async([self dispatchQueue], ^(void) {
        NSString *insertSQL = [NSString stringWithFormat: @"SELECT COUNT(*) FROM PANELS where grouphashid=\"%@\"", groupHashId];
        //NSLog(@"insertSQL=%@", insertSQL);
        const char* sqlStatement = [insertSQL UTF8String];
        //const char* sqlStatement = "SELECT COUNT(*) FROM PANELS";
        sqlite3_stmt *statement;
        
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                rowCount = sqlite3_column_int(statement, 0);
                //NSLog(@"Rowcount is %d",rowCount);
            }
        }
        else
        {
            NSLog( @"submitSQLRequestCountPanelsForGroup.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        //sqlite3_close(database);
        });
    }//end if
    else{
        NSString *insertSQL = [NSString stringWithFormat: @"SELECT COUNT(*) FROM PANELS where grouphashid=\"%@\"", groupHashId];
        //NSLog(@"insertSQL=%@", insertSQL);
        const char* sqlStatement = [insertSQL UTF8String];
        //const char* sqlStatement = "SELECT COUNT(*) FROM PANELS";
        sqlite3_stmt *statement;
        
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                rowCount = sqlite3_column_int(statement, 0);
                //NSLog(@"Rowcount is %d",rowCount);
            }
        }
        else
        {
            NSLog( @"submitSQLRequestCountPanelsForGroup.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        //sqlite3_close(database);
    }//end else
    
 
    
    return rowCount;
}

-(void)submitSQLRequestSavePanelsWithAssetsForGroup:(NSArray*)panels andGroupHashId:(NSString*)groupHashId{
    
    dispatch_async([self dispatchQueue], ^(void) {
        sqlite3_stmt    *statement;
        //const char *dbpath = [databasePathStatic UTF8String];
        
        if([panels count]>0)
        {
            databaseUpdating = YES;
            for(int i=0; i<[panels count]; i++)
            {
                Panel* panel = [panels objectAtIndex:i];
                if(panel!=nil)
                {
                    
                    int panelExists = [self submitSQLRequestCheckPanelExistsLocal:panel.panelId];
                    int assestsExist =  [self submitSQLRequestGetAssetsForPanelLocal:panel.panelId];
                    
                    if(panelExists==0)
                    {
                        if(panel.photo!=nil && panel.photo.photoId>0)
                        {
                            
                            //if (sqlite3_open(dbpath, &database) == SQLITE_OK)
                            {
                                NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO PANELS (panelId, grouphashId, photoId, photourl, numplacements, numannotations) VALUES (\"%i\",\"%@\",\"%i\",\"%@\", \"%f\", \"%f\")", panel.panelId, groupHashId, panel.photo.photoId, panel.photo.imageURL, -1.0, -1.0];
                                //NSLog(@"submitSQLRequestSavePanelsForGroup.insertSQL=%@", insertSQL);
                                const char *insert_stmt = [insertSQL UTF8String];
                                /*
                                 sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                                 if (sqlite3_step(statement) == SQLITE_DONE)
                                 {
                                 //NSLog(@"submitSQLRequestSavePanelsForGroup. Panel added=%i", panel.panelId);
                                 
                                 }
                                 */
                                if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                                {
                                    while (sqlite3_step(statement) == SQLITE_DONE)
                                    {
                                        sqlite3_column_text(statement, 0);
                                        
                                    } //else
                                }
                                else {
                                    NSLog(@"submitSQLRequestSavePanelsForGroup.Failed to add panel=%i. Error is:  %s", panel.panelId, sqlite3_errmsg(database));
                                }
                                sqlite3_finalize(statement);
                                //sqlite3_close(database);
                            }//end if (sqlite3_open(dbpath, &database) == SQLITE_OK)
                            
                        }//end if(panel.photo!=nil && panel.photo.photoId>0)
                    }//end if(panelExists==0) 
                    
                    if(assestsExist==0)
                    {
                        if(panel.placements!=nil && panel.annotations!=nil)
                        {
                            float numPlacements =  [[NSNumber numberWithInt:[panel.placements count]] floatValue];
                            float numAnnotations = [[NSNumber numberWithInt:[panel.annotations count]] floatValue];
                            sqlite3_stmt    *statement;
                            //const char *dbpath = [databasePathStatic UTF8String];
                            
                            
                            if([panel.placements count]>0)
                            {
                                for(int i=0; i<[panel.placements count]; i++)
                                {
                                    Placement* placement = [panel.placements objectAtIndex:i];
                                    if(placement!=nil)
                                    {
                                        //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                                        {
                                            //(PLACEMENTID INTEGER NOT NULL, PANELID INTEGER NOT NULL, RESOURCEID INTEGER, XOFF REAL, YOFF REAL, SCALE REAL, ANGLE REAL, ZINDEX INT, PRIMARY KEY(PLACEMENTID, PANELID))"
                                            NSString *insertSQL = [NSString stringWithFormat: @"insert into placements (PLACEMENTID, PANELID, GROUPHASHID, RESOURCEID, XOFF, YOFF, SCALE, ANGLE, ZINDEX) values(%i, %i, \"%@\", %i, %f, %f, %f, %f, %i)", i, panel.panelId, groupHashId, placement.resourceId, placement.xOffset, placement.yOffset, placement.scale, placement.angle, placement.zIndex];
                                            //NSLog(@"insertSQL=%@", insertSQL);
                                            const char *insert_stmt = [insertSQL UTF8String];
                                            
                                            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                                            //if (sqlite3_step(statement) == SQLITE_DONE)
                                            {
                                                //NSLog(@"Placement added");
                                                
                                            }
                                            
                                            if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                                            {
                                                while (sqlite3_step(statement) == SQLITE_DONE)
                                                {
                                                    sqlite3_column_text(statement, 0);
                                                    
                                                } //else
                                            }
                                            else {
                                                NSLog(@"submitSQLRequestSaveAssetsForPanel.Failed to add placement.Error is:  %s", sqlite3_errmsg(database));
                                            }
                                            
                                            sqlite3_finalize(statement);
                                            //sqlite3_close(database);
                                            
                                        }//end if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                                    }//end if(placement!=nil)
                                }//end for
                            }//end if([placements count]>0)
                            
                            if([panel.annotations count]>0)
                            {
                                for(int i=0; i<[panel.annotations count]; i++)
                                {
                                    Annotation* annotation = [panel.annotations objectAtIndex:i];
                                    if(annotation!=nil)
                                    {
                                        //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                                        {
                                            //(ANNOTATIONID INTEGER, PANELID INTEGER, GROUPHASHID TEXT, TXT TEXT, XOFF REAL, YOFF REAL, BUBBLESTYLE INTEGER, FOPTIONS TEXT, PRIMARY KEY(ANNOTATIONID, PANELID, GROUPHASHID))
                                            NSString *insertSQL = [NSString stringWithFormat: @"insert into Annotations (ANNOTATIONID, PANELID, GROUPHASHID, TXT, XOFF, YOFF, BUBBLESTYLE) values(%i, %i, \"%@\",\"%@\", %f, %f, %i)", annotation.annotationId, panel.panelId, groupHashId,annotation.text, annotation.xOffset, annotation.yOffset, annotation.bubbleStyle];
                                            //NSLog(@"insertSQL=%@", insertSQL);
                                            const char *insert_stmt = [insertSQL UTF8String];
                                            
                                            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                                            //if (sqlite3_step(statement) == SQLITE_DONE)
                                            {
                                                //NSLog(@"Placement added");
                                                
                                            }
                                            
                                            if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                                            {
                                                while (sqlite3_step(statement) == SQLITE_DONE)
                                                {
                                                    sqlite3_column_text(statement, 0);
                                                    
                                                } //else
                                            }
                                            else {
                                                NSLog(@"submitSQLRequestSaveAssetsForPanel.Failed to add placement.Error is:  %s", sqlite3_errmsg(database));
                                            }
                                            
                                            sqlite3_finalize(statement);
                                            //sqlite3_close(database);
                                            
                                        }//end if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                                    }//end if(placement!=nil)
                                }//end for
                            }//end if([placements count]>0)
                            
                            
                            //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                            {
                                NSString *insertSQL = [NSString stringWithFormat: @"update PANELS set numplacements=%f, numannotations=%f where panelId=%i and grouphashid=\"%@\"", numPlacements, numAnnotations, panel.panelId, groupHashId];
                                //NSLog(@"submitSQLRequestSaveAssetsForPanel.insertSQL=%@", insertSQL);
                                const char *insert_stmt = [insertSQL UTF8String];
                                
                                if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                                {
                                    while (sqlite3_step(statement) == SQLITE_DONE)
                                    {
                                        sqlite3_column_text(statement, 0);
                                        
                                    } //else
                                }
                                else
                                {
                                    NSLog(@"submitSQLRequestSaveAssetsForPanel. Failed to update panel.Error is:  %s", sqlite3_errmsg(database));
                                }
                                
                                sqlite3_finalize(statement);
                                //sqlite3_close(database);
                            }//end if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                            
                        }//end if(panel.placements!=nil && panel.annotations!=nil)
                    }//end if(assestsExist==0)
                    
                    
                    
                    
                }//end if(panel!=nil)
            }//end for

            databaseUpdating=NO;
            //NSLog(@"submitSQLRequestSavePanelsForGroup. All panels downloaded. databaseUpdating=%d", databaseUpdating);
        }//end if([panels count]>0)
        
    });

    
}

-(void)submitSQLRequestSaveAssetsForPanel:(int)panelId andGroupHashId:(NSString*)groupHashId andPlacements:(NSArray*)placements andAnnotations:(NSArray*)annotations
{
    //NSLog(@"submitSQLRequestSaveAssetsForPanel. panelId=%i", panelId);
    //NSLog(@"DataLoader.submitSQLRequestSaveAssetsForPanel. panelId=%i, databaseUpdating=%d, placements=%i, annotations=%i", panelId, databaseUpdating, [placements count], [annotations count]);
    if(panelId>0 && placements!=nil && annotations!=nil)
    {
        dispatch_async([self dispatchQueue], ^(void) {
            
            databaseUpdating = YES;
            //NSLog(@"submitSQLRequestSaveAssetsForPanel. panelId=%i, databaseUpdating=%d, placements=%i, annotations=%i", panelId, databaseUpdating, [placements count], [annotations count]);
            
            float numPlacements =  [[NSNumber numberWithInt:[placements count]] floatValue];
            float numAnnotations = [[NSNumber numberWithInt:[annotations count]] floatValue];
            sqlite3_stmt    *statement;
            //const char *dbpath = [databasePathStatic UTF8String];
            
            
            if([placements count]>0)
            {
                for(int i=0; i<[placements count]; i++)
                {
                    Placement* placement = [placements objectAtIndex:i];
                    if(placement!=nil)
                    {
                        //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                        {
                            //(PLACEMENTID INTEGER NOT NULL, PANELID INTEGER NOT NULL, RESOURCEID INTEGER, XOFF REAL, YOFF REAL, SCALE REAL, ANGLE REAL, ZINDEX INT, PRIMARY KEY(PLACEMENTID, PANELID))"
                            NSString *insertSQL = [NSString stringWithFormat: @"insert into placements (PLACEMENTID, PANELID, GROUPHASHID, RESOURCEID, XOFF, YOFF, SCALE, ANGLE, ZINDEX) values(%i, %i, \"%@\", %i, %f, %f, %f, %f, %i)", i, panelId, groupHashId, placement.resourceId, placement.xOffset, placement.yOffset, placement.scale, placement.angle, placement.zIndex];
                            //NSLog(@"insertSQL=%@", insertSQL);
                            const char *insert_stmt = [insertSQL UTF8String];
                            
                            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                            //if (sqlite3_step(statement) == SQLITE_DONE)
                            {
                                //NSLog(@"Placement added");
                                
                            }
                            
                            if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                            {
                                while (sqlite3_step(statement) == SQLITE_DONE)
                                {
                                    sqlite3_column_text(statement, 0);
                                    
                                } //else
                            }
                            else {
                                NSLog(@"submitSQLRequestSaveAssetsForPanel.Failed to add placement.Error is:  %s", sqlite3_errmsg(database));
                            }
                            
                            sqlite3_finalize(statement);
                            //sqlite3_close(database);
                            
                        }//end if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                    }//end if(placement!=nil)
                }//end for
            }//end if([placements count]>0)
            
            if([annotations count]>0)
            {
                for(int i=0; i<[annotations count]; i++)
                {
                    Annotation* annotation = [annotations objectAtIndex:i];
                    if(annotation!=nil)
                    {
                        //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                        {
                            //(ANNOTATIONID INTEGER, PANELID INTEGER, GROUPHASHID TEXT, TXT TEXT, XOFF REAL, YOFF REAL, BUBBLESTYLE INTEGER, FOPTIONS TEXT, PRIMARY KEY(ANNOTATIONID, PANELID, GROUPHASHID))
                            NSString *insertSQL = [NSString stringWithFormat: @"insert into Annotations (ANNOTATIONID, PANELID, GROUPHASHID, TXT, XOFF, YOFF, BUBBLESTYLE) values(%i, %i, \"%@\",\"%@\", %f, %f, %i)", annotation.annotationId, panelId, groupHashId,annotation.text, annotation.xOffset, annotation.yOffset, annotation.bubbleStyle];
                            //NSLog(@"insertSQL=%@", insertSQL);
                            const char *insert_stmt = [insertSQL UTF8String];
                            
                            //sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                            //if (sqlite3_step(statement) == SQLITE_DONE)
                            {
                                //NSLog(@"Placement added");
                                
                            }
                            
                            if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                            {
                                while (sqlite3_step(statement) == SQLITE_DONE)
                                {
                                    sqlite3_column_text(statement, 0);
                                    
                                } //else
                            }
                            else {
                                NSLog(@"submitSQLRequestSaveAssetsForPanel.Failed to add placement.Error is:  %s", sqlite3_errmsg(database));
                            }
                            
                            sqlite3_finalize(statement);
                            //sqlite3_close(database);
                            
                        }//end if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                    }//end if(placement!=nil)
                }//end for
            }//end if([placements count]>0)
            
            
            //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
            {
                NSString *insertSQL = [NSString stringWithFormat: @"update PANELS set numplacements=%f, numannotations=%f where panelId=%i and grouphashid=\"%@\"", numPlacements, numAnnotations, panelId, groupHashId];
                //NSLog(@"submitSQLRequestSaveAssetsForPanel.insertSQL=%@", insertSQL);
                const char *insert_stmt = [insertSQL UTF8String];
                
                if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                {
                    while (sqlite3_step(statement) == SQLITE_DONE)
                    {
                        sqlite3_column_text(statement, 0);
                        
                    } //else
                }
                else
                {
                    NSLog(@"submitSQLRequestSaveAssetsForPanel. Failed to update panel.Error is:  %s", sqlite3_errmsg(database));
                }
                
                sqlite3_finalize(statement);
                //sqlite3_close(database);
            }//end if(sqlite3_open(dbpath, &database) == SQLITE_OK)
            
            
            databaseUpdating = NO;
        });
        
    }//end if(panelId>0 && placements!=nil && annotations!=nil)
    
}

-(int)submitSQLRequestCheckThemeExists:(int)themeId{
    int rowCount=0;
    
    //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"select Count(*) from resources where themeId=%i", themeId];
        //NSLog(@"insertSQL=%@", insertSQL);
        const char *sqlStatement = [insertSQL UTF8String];
        
        //const char* sqlStatement = "SELECT COUNT(*) FROM resources where themeId=%i";
        sqlite3_stmt *statement;
        
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                rowCount = sqlite3_column_int(statement, 0);
                //NSLog(@"Rowcount is %d",rowCount);
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        //sqlite3_close(database);
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
    return rowCount;
}

-(void)submitSQLRequestSaveResources:(NSArray*)resources{
    if(resources!=nil){
        if([resources count]>0){
            dispatch_async([self dispatchQueue], ^(void) {
                databaseUpdating = YES;
                //NSLog(@"submitSQLRequestSaveResources. [resources count]=%i, dataBaseUpdating=%d", [resources count], databaseUpdating);
                for(int i=0; i<[resources count]; i++)
                {
                    Resource* resource = [resources objectAtIndex:i];
                    if(resource!=nil)
                    {
                        sqlite3_stmt    *statement;
                        //const char *dbpath = [databasePathStatic UTF8String];
                        
                        //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                        {
                            NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO resources(resourceid, themeId, TYPE, PHOTOURL, THUMBURL) VALUES(%i, %i, \"%@\",\"%@\",\"%@\")", resource.resourceId, 1, resource.type, resource.imageURL, resource.thumbURL];
                            //NSLog(@"insertSQL=%@", insertSQL);
                            const char *insert_stmt = [insertSQL UTF8String];
                            /*
                             sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                             if (sqlite3_step(statement) == SQLITE_DONE)
                             {
                             //NSLog(@"Resource added");
                             
                             }
                             */
                            if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                            {
                                while (sqlite3_step(statement) == SQLITE_DONE)
                                {
                                    sqlite3_column_text(statement, 0);
                                    
                                } //else
                            }
                            else {
                                //NSLog(@"Failed to add resource");
                            }
                            sqlite3_finalize(statement);
                            //sqlite3_close(database);
                        }
                        

                    }
                    //[self submitSQLRequestSaveResource:resource.resourceId andThemeId:1 andType:resource.type andImageURL:resource.imageURL andThumbURL:resource.thumbURL];
                }//end for
                databaseUpdating = NO;
            });

            
        }//end if([resources count]>0)
    }//end if(resources!=nil)
}

//-(void)submitSQLRequestSaveResource:(int)resourceId
-(void)submitSQLRequestSaveResource:(int)resourceId andThemeId:(int)themeId andType:(NSString*)type andImageURL:(NSString*)imageURL andThumbURL:(NSString*)thumbURL
{
    dispatch_async([self dispatchQueue], ^(void) {
        databaseUpdating = YES;
    //NSLog(@"Resource being stored in the database yet");
    sqlite3_stmt    *statement;
    //const char *dbpath = [databasePathStatic UTF8String];
    
    //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO resources(resourceid, themeId, TYPE, PHOTOURL, THUMBURL) VALUES(%i, %i, \"%@\",\"%@\",\"%@\")", resourceId, 1, type, imageURL, thumbURL];
        //NSLog(@"insertSQL=%@", insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        /*
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            //NSLog(@"Resource added");
            
        }
        */
        if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_DONE)
            {
                sqlite3_column_text(statement, 0);
                
            } //else
        }
        else {
            //NSLog(@"Failed to add resource");
        }
        sqlite3_finalize(statement);
        //sqlite3_close(database);
    }
        databaseUpdating = NO;
        
    });
    
}

-(void)submitSQLRequestLeaveGroup:(NSString*)groupHashId{
    
    if(databaseUpdating){
        
            dispatch_async([self dispatchQueue], ^(void) {
        sqlite3_stmt    *statement;
        //const char *dbpath = [databasePathStatic UTF8String];
        
        NSString *insertSQL = [NSString stringWithFormat: @"delete from groups where grouphashid=\"%@\"", groupHashId];
        
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            //NSLog(@"Panel added");
            
        } else {
            //NSLog(@"Failed to add panel");
        }
        sqlite3_finalize(statement);
        //sqlite3_close(database);
            });
    }
    else{
        sqlite3_stmt    *statement;
        //const char *dbpath = [databasePathStatic UTF8String];
        
        NSString *insertSQL = [NSString stringWithFormat: @"delete from groups where grouphashid=\"%@\"", groupHashId];
        
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            //NSLog(@"Panel added");
            
        } else {
            //NSLog(@"Failed to add panel");
        }
        sqlite3_finalize(statement);
        //sqlite3_close(database);
    }

}


-(void)submitSQLRequestSavePanelsForGroup:(NSArray*)panels andGroupHashId:(NSString*)groupHashId{
    //NSLog(@"submitSQLRequestSavePanelsForGroup.");

    dispatch_async([self dispatchQueue], ^(void) {
    sqlite3_stmt    *statement;
    //const char *dbpath = [databasePathStatic UTF8String];
 
    if([panels count]>0)
    {
        databaseUpdating = YES;
        for(int i=0; i<[panels count]; i++)
        {
            Panel* panel = [panels objectAtIndex:i];
            if(panel!=nil)
            {
                int panelExists = [self submitSQLRequestCheckPanelExistsLocal:panel.panelId];
                if(panelExists==0)
                {
                    if(panel.photo!=nil && panel.photo.photoId>0)
                    {
                        //if (sqlite3_open(dbpath, &database) == SQLITE_OK)
                        {
                            NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO PANELS (panelId, grouphashId, photoId, photourl, numplacements, numannotations) VALUES (\"%i\",\"%@\",\"%i\",\"%@\", \"%f\", \"%f\")", panel.panelId, groupHashId, panel.photo.photoId, panel.photo.imageURL, -1.0, -1.0];
                            //NSLog(@"submitSQLRequestSavePanelsForGroup.insertSQL=%@", insertSQL);
                            const char *insert_stmt = [insertSQL UTF8String];
                            /*
                             sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                             if (sqlite3_step(statement) == SQLITE_DONE)
                             {
                             //NSLog(@"submitSQLRequestSavePanelsForGroup. Panel added=%i", panel.panelId);
                             
                             }
                             */
                            if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                            {
                                while (sqlite3_step(statement) == SQLITE_DONE)
                                {
                                    sqlite3_column_text(statement, 0);
                                    
                                } //else
                            }
                            else {
                                NSLog(@"submitSQLRequestSavePanelsForGroup.Failed to add panel=%i. Error is:  %s", panel.panelId, sqlite3_errmsg(database));
                            }
                            sqlite3_finalize(statement);
                            //sqlite3_close(database);
                        }//end if (sqlite3_open(dbpath, &database) == SQLITE_OK)
                        
                    }//end if(panel.photo!=nil && panel.photo.photoId>0)
                }//end if(panelExists==0)

            }//end if(panel!=nil)
        }//end for
        
        //if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            NSString *insertSQL = [NSString stringWithFormat: @"update GROUPS set panelsdownLoaded=%i where grouphashId=\"%@\"", 1, groupHashId];
            //NSLog(@"insertSQL=%@", insertSQL);
            const char *insert_stmt = [insertSQL UTF8String];
            /*
            sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                //NSLog(@"Panel updated");
                
            }
            */
            if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
            {
                while (sqlite3_step(statement) == SQLITE_DONE)
                {
                    sqlite3_column_text(statement, 0);
                    
                } //else
            }
            else {
                NSLog(@"submitSQLRequestSavePanelsForGroup. Failed to update group.panelsDownloaded. Error is:  %s", sqlite3_errmsg(database));
            }
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }
        
        databaseUpdating=NO;
        //NSLog(@"submitSQLRequestSavePanelsForGroup. All panels downloaded. databaseUpdating=%d", databaseUpdating);
    }//end if([panels count]>0)
             
    });
}

-(void)submitSQLRequestSaveComicsForGroup:(NSArray*)comics andGroupHashId:(NSString*)groupHashId{
    
    dispatch_async([self dispatchQueue], ^(void) {

        sqlite3_stmt    *statement;
        //const char *dbpath = [databasePathStatic UTF8String];
        if([comics count]>0)
        {
            databaseUpdating = YES;  
            for(int i=0; i<[comics count]; i++)
            {
                Comic* comic = [comics objectAtIndex:i];
                NSArray* panels = comic.panels;
                if(comic!=nil)
                {
                    //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                    {
                        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO COMICS (comicId, grouphashId, numpanels) VALUES (\"%i\",\"%@\", \"%i\")", comic.comicId, groupHashId, [panels count]];
                        //NSLog(@"insertSQL=%@", insertSQL);
                        const char *insert_stmt = [insertSQL UTF8String];
                        if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                        {
                            while (sqlite3_step(statement) == SQLITE_DONE)
                            {
                                sqlite3_column_text(statement, 0);
                                
                            } //else
                        }
                        
                        else
                        {
                            NSLog(@"submitSQLRequestSaveComicsForGroup.Failed to add comic=%i. Error is:  %s", comic.comicId, sqlite3_errmsg(database));
                        }
                        sqlite3_finalize(statement);
                        //sqlite3_close(database);
                    }//end if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                    
                    for(int j=0; j<[panels count]; j++)
                    {
                        Panel* panel = [comic.panels objectAtIndex:j];
                        if(panel!=nil)
                        {
                            //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                            {
                                NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO COMICPANELS (comicid, panelid, panelposition) VALUES (\"%i\", \"%i\", \"%i\")", comic.comicId, panel.panelId, j];
                                //NSLog(@"insertSQL=%@", insertSQL);
                                const char *insert_stmt = [insertSQL UTF8String];
                                
                                /*
                                sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                                if (sqlite3_step(statement) == SQLITE_DONE)
                                {
                                    //NSLog(@"Panel added");
                                    
                                }
                                */
                                if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                                {
                                    while (sqlite3_step(statement) == SQLITE_DONE)
                                    {
                                        sqlite3_column_text(statement, 0);
                                        
                                    } //else
                                }
                                else
                                {
                                    NSLog(@"submitSQLRequestSaveComicsForGroup. Failed to add panel. Error is:  %s", sqlite3_errmsg(database));
                                }
                                
                                //if(j==[panels count]-1)
                                {
                                sqlite3_finalize(statement);
                                    //sqlite3_close(database);
                                }
                            }
                            
                        }//end if(panel!=nil)
                    }//end for(int j=0; j<[panels count]; j++)
                    
                }//end if(comic!=nil)
            }//end for(int i=0; i<[comics count]; i++)
            
            //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
            {
                NSString *insertSQL = [NSString stringWithFormat: @"update GROUPS set comicsdownLoaded=%i where grouphashId=\"%@\"", 1, groupHashId];
                //NSLog(@"insertSQL=%@", insertSQL);
                const char *insert_stmt = [insertSQL UTF8String];
                /*
                sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    //NSLog(@"Panel updated");
                    
                }
                 */
                if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                {
                    while (sqlite3_step(statement) == SQLITE_DONE)
                    {
                        sqlite3_column_text(statement, 0);
                        
                    } //else
                }
                else
                {
                    NSLog(@"submitSQLRequestSaveComicsForGroup. Failed to update group.Error is:  %s", sqlite3_errmsg(database));
                }
                sqlite3_finalize(statement);
                //sqlite3_close(database);
            }
            databaseUpdating = NO;
        }//end if([comics count]>0)
        
    });
}

-(void)submitSQLRequestSavePhotos:(NSArray*)photos andGroupHashId:(NSString*)groupHashId{
    if([photos count]>0)
    {
        dispatch_async([self dispatchQueue], ^(void) {
        databaseUpdating = YES;
        sqlite3_stmt    *statement;
        //const char *dbpath = [databasePathStatic UTF8String];
        //NSLog(@"DataLoader.submitSQLRequestSavePhotos.groupHashId=%@", groupHashId);
        for(int i=0; i<[photos count]; i++)
        {
            Photo* photo = [photos objectAtIndex:i];
            if(photo!=nil)
            {

                //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                {
                    
                    NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO PHOTOS (photoId, GROUPHASHID, PHOTOURL, THUMBURL, DESCRIPTION, WIDTH, HEIGHT) VALUES (\"%i\",\"%@\",\"%@\",\"%@\",\"%@\", \"%f\", \"%f\")", photo.photoId, groupHashId, photo.imageURL, photo.thumbURL, @"description", 320.0, 320.0];
                    //NSLog(@"submitSQLRequestSavePhotos.INSERTsql=%@", insertSQL);
                    const char *insert_stmt = [insertSQL UTF8String];
                    
                    /*
                    sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                    if (sqlite3_step(statement) == SQLITE_DONE)
                    {
                        //NSLog(@"Photo added");
                        
                    }
                    */
                    
                    if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                    {
                        while (sqlite3_step(statement) == SQLITE_DONE)
                        {
                            sqlite3_column_text(statement, 0);
                            
                        } //else
                    }
                    
                    else {
                        NSLog(@"submitSQLRequestSavePhotos. Failed to add photo.Error is:  %s", sqlite3_errmsg(database));
                    }
                    sqlite3_finalize(statement);
                    //sqlite3_close(database);
                }
            }//end if(photo!=nil)
        }//end for
            
            //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
            {
                NSString *insertSQL = [NSString stringWithFormat: @"update GROUPS set photosdownLoaded=%i where grouphashId=\"%@\"", 1, groupHashId];
                //NSLog(@"insertSQL=%@", insertSQL);
                const char *insert_stmt = [insertSQL UTF8String];
                /*
                sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    //NSLog(@"Panel updated");
                    
                }
                 */
                if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                {
                    while (sqlite3_step(statement) == SQLITE_DONE)
                    {
                        sqlite3_column_text(statement, 0);
                        
                    } //else
                }
                
                else {
                    NSLog(@"submitSQLRequestSavePanelsForGroup. Failed to update group.photosdownLoaded. Error is:  %s", sqlite3_errmsg(database));
                }
                sqlite3_finalize(statement);
                //sqlite3_close(database);
            }
            
            databaseUpdating = NO;
        });

    }
    
  }

-(void)submitSQLRequestSaveGroups:(NSArray*)groups{
    //NSLog(@"submitSQLRequestSaveGroups. Total #groups=%i", [groups count]);
    dispatch_async([self dispatchQueue], ^(void) {
        if([groups count]>0)
        {
            databaseUpdating = YES;
            for(int i=0; i<[groups count]; i++)
            {
                Group* group = [groups objectAtIndex:i];
                if(group!=nil)
                {
                    sqlite3_stmt    *statement;
                    //const char *dbpath = [databasePathStatic UTF8String];
                    //if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                    {
                        //const char *groups_stmt = "CREATE TABLE IF NOT EXISTS GROUPS (GROUPID INTEGER PRIMARY KEY, NAME TEXT, GROUPHASHID TEXT, THEMEID INTEGER, ORGANISATIONID INTEGER)";
                        
                        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO GROUPS (GROUPHASHID, GROUPID, NAME,  THEMEID, PANELSDOWNLOADED, PHOTOSDOWNLOADED, COMICSDOWNLOADED) VALUES (\"%@\",\"%i\",\"%@\",\"%i\", \"%i\", \"%i\", \"%i\")", group.hashId, group.groupId, group.name, group.theme.themeId, 0, 0, 0];
                        //NSLog(@"submitSQLRequestSaveGroups.insertSQL=%@", insertSQL);
                        const char *insert_stmt = [insertSQL UTF8String];
                        
                        /*
                        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                        if (sqlite3_step(statement) == SQLITE_DONE)
                        {
                            //NSLog(@"Panel added");
                            
                        }
                         */
                        if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL)==SQLITE_OK)
                        {
                            while (sqlite3_step(statement) == SQLITE_DONE)
                            {
                                sqlite3_column_text(statement, 0);
                                
                            } //else
                        }
                        else {
                            NSLog(@"submitSQLRequestSaveGroups. Failed to add group. Error is:  %s", sqlite3_errmsg(database));
                        }
                        sqlite3_finalize(statement);
                        //sqlite3_close(database);
                    }
                }//end if(group!=nil)
            }//end for
            databaseUpdating = NO;

        }//end if([groups count]>0)
          });
}
/*
-(void)submitSQLRequestSaveComics:(NSArray*)comics{
    NSLog(@"submitSQLRequestSaveComics.=%i", [comics count]);
    dispatch_async([self dispatchQueue], ^(void) {
        for(int i=0; i<[comics count]; i++)
        {
            Comic* comic = [comics objectAtIndex:i];
            NSArray* panels = comic.panels;
            if(comic!=nil)
            {
                sqlite3_stmt    *statement;
                const char *dbpath = [databasePathStatic UTF8String];
                
                if (sqlite3_open(dbpath, &database) == SQLITE_OK)
                {
                    NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO COMICS (comicid, numpanels) VALUES (\"%i\", \"%i\")",
                                           comic.comicId, [panels count]];
                    //NSLog(@"insertSQL=%@", insertSQL);
                    
                    const char *insert_stmt = [insertSQL UTF8String];
                    
                    sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                    if (sqlite3_step(statement) == SQLITE_DONE)
                    {
                        //NSLog(@"Panel added");
                        
                    } else {
                        //NSLog(@"Failed to add panel");
                    }
                    //sqlite3_finalize(statement);
                    //sqlite3_close(database);
                }//end if
                
                for(int j=0; j<[panels count]; j++)
                {
                    Panel* panel = [comic.panels objectAtIndex:j];
                    if(panel!=nil)
                    {
                        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
                        {
                            NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO COMICPANELS (comicid, panelid, panelposition) VALUES (\"%i\", \"%i\", \"%i\")", comic.comicId, panel.panelId, j];
                            //NSLog(@"insertSQL=%@", insertSQL);
                            const char *insert_stmt = [insertSQL UTF8String];
                            
                            sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                            if (sqlite3_step(statement) == SQLITE_DONE)
                            {
                                //NSLog(@"Panel added");
                                
                            } else {
                                //NSLog(@"Failed to add panel");
                            }
                            
                            if(i==[panels count]-1)
                            {
                                sqlite3_finalize(statement);
                                sqlite3_close(database);
                            }
                        }
                        
                    }//end if(panel!=nil)
                    
                }//end for
                
            }//end if(comic!=nil)
        }//end for
    });
}
*/

-(NSArray*)convertResourcesSQLIntoResources:(int)themeId{
    
    NSMutableArray* resources = [[NSMutableArray alloc] init];
    if(databaseUpdating)
    {
        dispatch_async([self dispatchQueue], ^(void) {
        //const char* sqlStatement = "SELECT photoid, photourl FROM PANELS where panelId";
        //RESOURCEID INTEGER NOT NULL PRIMARY KEY, THEMEID INTEGER NOT NULL, NAME TEXT, TYPE TEXT, PHOTOURL TEXT, THUMBURL TEXT
        NSString *selectSQL = [NSString stringWithFormat: @"SELECT resourceId, type, PHOTOURL, THUMBURL FROM Resources where themeId=%i", themeId];
        //NSLog(@"selectSQL=%@", selectSQL);
        const char *sqlStatement = [selectSQL UTF8String];
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                Resource* resource= [[Resource alloc] init];
                resource.resourceId = sqlite3_column_int(statement, 0);
                resource.type = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                resource.imageURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                resource.thumbURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                
                [resources addObject:resource];
            }//end while
        }//end if
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        //sqlite3_close(database);
        });
    }//end if
    else{
        //const char* sqlStatement = "SELECT photoid, photourl FROM PANELS where panelId";
        //RESOURCEID INTEGER NOT NULL PRIMARY KEY, THEMEID INTEGER NOT NULL, NAME TEXT, TYPE TEXT, PHOTOURL TEXT, THUMBURL TEXT
        NSString *selectSQL = [NSString stringWithFormat: @"SELECT resourceId, type, PHOTOURL, THUMBURL FROM Resources where themeId=%i", themeId];
        //NSLog(@"selectSQL=%@", selectSQL);
        const char *sqlStatement = [selectSQL UTF8String];
        sqlite3_stmt *statement;
        
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                Resource* resource= [[Resource alloc] init];
                resource.resourceId = sqlite3_column_int(statement, 0);
                resource.type = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                resource.imageURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                resource.thumbURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                
                [resources addObject:resource];
            }//end while
        }//end if
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        //sqlite3_close(database);
    }//end else
    
    return resources;
}

-(NSArray*)convertResourceSQLIntoResource:(int)resourceId{
    //NSLog(@"convertResourceSQLIntoResource:resourceId=%i, databaseUpdating=%d", resourceId, databaseUpdating);
    NSMutableArray* resources = [[NSMutableArray alloc] init];

    if(databaseUpdating)
    {
        dispatch_async([self dispatchQueue], ^(void) {
            Resource* resource= [[Resource alloc] init];
            //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
            {
                //const char* sqlStatement = "SELECT photoid, photourl FROM PANELS where panelId";
                //RESOURCEID INTEGER NOT NULL PRIMARY KEY, THEMEID INTEGER NOT NULL, NAME TEXT, TYPE TEXT, PHOTOURL TEXT, THUMBURL TEXT
                NSString *selectSQL = [NSString stringWithFormat: @"SELECT type, PHOTOURL, THUMBURL FROM Resources where resourceId=%i", resourceId];
                //NSLog(@"selectSQL=%@", selectSQL);
                const char *sqlStatement = [selectSQL UTF8String];
                sqlite3_stmt *statement;
                
                if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
                {
                    //Loop through all the returned rows (should be just one)
                    while( sqlite3_step(statement) == SQLITE_ROW )
                    {
                        resource.resourceId = resourceId;
                        resource.type = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                        resource.imageURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                        resource.thumbURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                        
                    }//end while
                }//end if
                else
                {
                    NSLog( @"convertResourceSQLIntoResource. Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
                }
                
                // Finalize and close database.
                sqlite3_finalize(statement);
                //sqlite3_close(database);
            }//end if
            
            [resources addObject:resource];
        });
    }
    
    else{
        Resource* resource= [[Resource alloc] init];
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //const char* sqlStatement = "SELECT photoid, photourl FROM PANELS where panelId";
            //RESOURCEID INTEGER NOT NULL PRIMARY KEY, THEMEID INTEGER NOT NULL, NAME TEXT, TYPE TEXT, PHOTOURL TEXT, THUMBURL TEXT
            NSString *selectSQL = [NSString stringWithFormat: @"SELECT type, PHOTOURL, THUMBURL FROM Resources where resourceId=%i", resourceId];
            //NSLog(@"selectSQL=%@", selectSQL);
            const char *sqlStatement = [selectSQL UTF8String];
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    resource.resourceId = resourceId;
                    resource.type = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                    resource.imageURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                    resource.thumbURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                    
                }//end while
            }//end if
            else
            {
                NSLog( @"convertResourceSQLIntoResource.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if
        
        [resources addObject:resource];
    }

    return resources;
}

-(NSArray*)convertPanelSQLIntoPanel:(int)panelId{
    //NSLog(@"convertPanelSQLIntoPanel.panelId=%i, databaseUpdating=%d", panelId, databaseUpdating);
    NSMutableArray* panels = [[NSMutableArray alloc] init];
    
    if(databaseUpdating)
    {
        dispatch_sync([self dispatchQueue], ^(void) {
            
            NSMutableArray* placements = [[NSMutableArray alloc] init];
            NSMutableArray* annotations = [[NSMutableArray alloc] init];
            
            Panel *panel =[[Panel alloc] init];
            __block int numPlacements=0;
            __block int numAnnotations=0;
            
            //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
            {
                //const char* sqlStatement = "SELECT photoid, photourl FROM PANELS where panelId";
                NSString *selectSQL = [NSString stringWithFormat: @"SELECT photoId, photourl, numplacements, numannotations FROM PANELS where panelId=%i", panelId];
                //NSLog(@"selectSQL=%@", selectSQL);
                const char *sqlStatement = [selectSQL UTF8String];
                sqlite3_stmt *statement;
                
                if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
                {
                    //Loop through all the returned rows (should be just one)
                    while( sqlite3_step(statement) == SQLITE_ROW )
                    {
                        int photoId= sqlite3_column_int(statement, 0);
                        //NSLog(@"photoId=%i", photoId);
                        //const char* date = (const char*)sqlite3_column_text(statement, 3);
                        //NSString *enddate = date == NULL ? nil : [[NSString alloc] initWithUTF8String:date];
                        const char* url = (const char*)sqlite3_column_text(statement, 1);
                        NSString *photoURL = url == NULL ? nil : [[NSString alloc] initWithUTF8String:url];
                        //NSString *photoURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                        numPlacements = (int) sqlite3_column_double(statement, 2);
                        numAnnotations = (int) sqlite3_column_double(statement, 3);
                        
                        NSLog(@"convertPanelSQLIntoPanel.panelId=%i, numPlacements=%i, numAnnotations=%i", panelId, numPlacements, numAnnotations);
                        
                        panel.panelId = panelId;
                        Photo *photo = [[Photo alloc] init];
                        photo.photoId = photoId;
                        photo.imageURL = photoURL;
                        panel.photo = photo;
                        
                    }//end while
                }//end if
                else
                {
                    NSLog( @"convertPanelSQLIntoPanel.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
                }
                
                // Finalize and close database.
                sqlite3_finalize(statement);
                //sqlite3_close(database);
                
                
                if(numPlacements>0)
                {
                    NSString *selectSQL = [NSString stringWithFormat: @"SELECT RESOURCEID, XOFF, YOFF, SCALE, ANGLE, ZINDEX FROM placements where panelId=%i", panelId];
                    //selectSQL = [NSString stringWithFormat: @"SELECT count(*) FROM placements"];
                    //NSLog(@"selectSQL=%@", selectSQL);
                    const char *sqlStatement1 = [selectSQL UTF8String];
                    sqlite3_stmt *statement;
                    
                    
                    if(sqlite3_prepare_v2(database, sqlStatement1, -1, &statement, NULL) == SQLITE_OK )
                    {
                        
                        //Loop through all the returned rows (should be just one)
                        while( sqlite3_step(statement) == SQLITE_ROW )
                        {
                            Placement* placement = [[Placement alloc] init];
                            placement.resourceId= sqlite3_column_int(statement, 0);
                            placement.xOffset=sqlite3_column_double(statement, 1);
                            placement.yOffset=sqlite3_column_double(statement, 2);
                            placement.scale=sqlite3_column_double(statement, 3);
                            placement.angle=sqlite3_column_double(statement, 4);
                            placement.zIndex=sqlite3_column_int(statement, 5);
                            
                            [placements addObject:placement];
                            
                            //NSLog(@"photoId=%i", photoId);
                            //numPlacements = (int) sqlite3_column_double(statement, 2);
                            //numAnnotations = (int) sqlite3_column_double(statement, 3);
                            
                            
                            
                        }//end while
                        
                    }//end if
                    else
                    {
                        NSLog( @"convertPanelSQLIntoPanel.Failed to select placements. Error is:  %s", sqlite3_errmsg(database) );
                    }
                    
                    // Finalize and close database.
                    sqlite3_finalize(statement);
                    //sqlite3_close(database);
                }//end if(numPlacements>0)
                
                if(numAnnotations>0)
                {
                    //ANNOTATIONID INTEGER NOT NULL PRIMARY KEY, PANELID INTEGER, TXT TEXT, XOFF REAL, YOFF REAL, BUBBLESTYLE INTEGER, FOPTIONS TEXT
                    NSString *selectSQL = [NSString stringWithFormat: @"SELECT ANNOTATIONID, XOFF, YOFF, TXT, BUBBLESTYLE FROM annotations where panelId=%i", panelId];
                    //NSLog(@"selectSQL=%@", selectSQL);
                    const char *sqlStatement1 = [selectSQL UTF8String];
                    sqlite3_stmt *statement;
                    
                    
                    if(sqlite3_prepare_v2(database, sqlStatement1, -1, &statement, NULL) == SQLITE_OK )
                    {
                        
                        //Loop through all the returned rows (should be just one)
                        while( sqlite3_step(statement) == SQLITE_ROW )
                        {
                            Annotation* annotation = [[Annotation alloc] init];
                            annotation.annotationId = sqlite3_column_int(statement, 0);
                            annotation.xOffset=sqlite3_column_double(statement, 1);
                            annotation.yOffset=sqlite3_column_double(statement, 2);
                            
                            const char* text = (const char*)sqlite3_column_text(statement, 3);
                            annotation.text = text == NULL ? nil : [[NSString alloc] initWithUTF8String:text];
                            //annotation.text = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(statement, 3)];
                            annotation.bubbleStyle = sqlite3_column_int(statement, 4);
                            [annotations addObject:annotation];
                            
                        }//end while
                        
                    }//end if
                    else
                    {
                        NSLog( @"convertPanelSQLIntoPanel.Failed to select annotations. Error is:  %s", sqlite3_errmsg(database) );
                    }
                    
                    // Finalize and close database.
                    sqlite3_finalize(statement);
                    //sqlite3_close(database);
                }//end if(numAnnotations>0)
                
                // Finalize and close database.
                //sqlite3_finalize(statement);
                //sqlite3_close(database);
                
            }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
            
            panel.placements = placements;
            panel.annotations = annotations;
            [panels addObject:panel];

            
        });
    }//end if(databaseUpdating)
    else if(!databaseUpdating)
    {
        NSMutableArray* placements = [[NSMutableArray alloc] init];
        NSMutableArray* annotations = [[NSMutableArray alloc] init];
        
        Panel *panel =[[Panel alloc] init];
        __block int numPlacements=0;
        __block int numAnnotations=0;
        
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //const char* sqlStatement = "SELECT photoid, photourl FROM PANELS where panelId";
            NSString *selectSQL = [NSString stringWithFormat: @"SELECT photoId, photourl, numplacements, numannotations FROM PANELS where panelId=%i", panelId];
            //NSLog(@"selectSQL=%@", selectSQL);
            const char *sqlStatement = [selectSQL UTF8String];
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    int photoId= sqlite3_column_int(statement, 0);
                    //NSLog(@"photoId=%i", photoId);
                    //NSString *photoURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                    const char* url = (const char*)sqlite3_column_text(statement, 1);
                    NSString *photoURL = url == NULL ? nil : [[NSString alloc] initWithUTF8String:url];
                    numPlacements = (int) sqlite3_column_double(statement, 2);
                    numAnnotations = (int) sqlite3_column_double(statement, 3);
                    
                    NSLog(@"convertPanelSQLIntoPanel.panelId=%i, numPlacements=%i, numAnnotations=%i", panelId, numPlacements, numAnnotations);
                    
                    panel.panelId = panelId;
                    Photo *photo = [[Photo alloc] init];
                    photo.photoId = photoId;
                    photo.imageURL = photoURL;
                    panel.photo = photo;
                    
                }//end while
            }//end if
            else
            {
                NSLog( @"convertPanelSQLIntoPanel.Failed to select panel. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
            
            
            if(numPlacements>0)
            {
                NSString *selectSQL = [NSString stringWithFormat: @"SELECT RESOURCEID, XOFF, YOFF, SCALE, ANGLE, ZINDEX FROM placements where panelId=%i", panelId];
                //selectSQL = [NSString stringWithFormat: @"SELECT count(*) FROM placements"];
                //NSLog(@"selectSQL=%@", selectSQL);
                const char *sqlStatement1 = [selectSQL UTF8String];
                sqlite3_stmt *statement;
                
                
                if(sqlite3_prepare_v2(database, sqlStatement1, -1, &statement, NULL) == SQLITE_OK )
                {
                    
                    //Loop through all the returned rows (should be just one)
                    while( sqlite3_step(statement) == SQLITE_ROW )
                    {
                        Placement* placement = [[Placement alloc] init];
                        placement.resourceId= sqlite3_column_int(statement, 0);
                        placement.xOffset=sqlite3_column_double(statement, 1);
                        placement.yOffset=sqlite3_column_double(statement, 2);
                        placement.scale=sqlite3_column_double(statement, 3);
                        placement.angle=sqlite3_column_double(statement, 4);
                        placement.zIndex=sqlite3_column_int(statement, 5);
                        
                        [placements addObject:placement];
                        
                        //NSLog(@"photoId=%i", photoId);
                        //numPlacements = (int) sqlite3_column_double(statement, 2);
                        //numAnnotations = (int) sqlite3_column_double(statement, 3);
                        
                        
                        
                    }//end while
                    
                }//end if
                else
                {
                    NSLog( @"convertPanelSQLIntoPanel.Failed from to select placements. Error is:  %s", sqlite3_errmsg(database) );
                }
                
                // Finalize and close database.
                sqlite3_finalize(statement);
                //sqlite3_close(database);
            }//end if(numPlacements>0)
            
            if(numAnnotations>0)
            {
                //ANNOTATIONID INTEGER NOT NULL PRIMARY KEY, PANELID INTEGER, TXT TEXT, XOFF REAL, YOFF REAL, BUBBLESTYLE INTEGER, FOPTIONS TEXT
                NSString *selectSQL = [NSString stringWithFormat: @"SELECT ANNOTATIONID, XOFF, YOFF, TXT, BUBBLESTYLE FROM annotations where panelId=%i", panelId];
                //NSLog(@"selectSQL=%@", selectSQL);
                const char *sqlStatement1 = [selectSQL UTF8String];
                sqlite3_stmt *statement;
                
                
                if(sqlite3_prepare_v2(database, sqlStatement1, -1, &statement, NULL) == SQLITE_OK )
                {
                    
                    //Loop through all the returned rows (should be just one)
                    while( sqlite3_step(statement) == SQLITE_ROW )
                    {
                        Annotation* annotation = [[Annotation alloc] init];
                        annotation.annotationId = sqlite3_column_int(statement, 0);
                        annotation.xOffset=sqlite3_column_double(statement, 1);
                        annotation.yOffset=sqlite3_column_double(statement, 2);
                        //annotation.text = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                        const char* text = (const char*)sqlite3_column_text(statement, 3);
                        annotation.text = text == NULL ? nil : [[NSString alloc] initWithUTF8String:text];
                        annotation.bubbleStyle = sqlite3_column_int(statement, 4);
                        [annotations addObject:annotation];
                        
                    }//end while
                    
                }//end if
                else
                {
                    NSLog( @"convertPanelSQLIntoPanel.Failed to select annotations. Error is:  %s", sqlite3_errmsg(database) );
                }
                
                // Finalize and close database.
                sqlite3_finalize(statement);
                //sqlite3_close(database);
            }//end if(numAnnotations>0)
            
            // Finalize and close database.
            //sqlite3_finalize(statement);
            //sqlite3_close(database);
            
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        panel.placements = placements;
        panel.annotations = annotations;
        [panels addObject:panel];
    }//end else
    
    //NSLog(@"convertPanelSQLIntoPanel. [panels count]=%i", [panels count]);
    return panels;
}

/*
-(NSArray*)convertPanelsSQLIntoPanels:(int)groupId{
 
    NSMutableArray* panels = [[NSMutableArray alloc] init];
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
    {
        const char* sqlStatement = "SELECT panelid, photoid, photourl FROM PANELS";
        sqlite3_stmt *statement;
 
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                int panelId= sqlite3_column_int(statement, 0);
                //NSLog(@"panelId=%i", panelId);
                int photoId= sqlite3_column_int(statement, 1);
                //NSLog(@"photoId=%i", photoId);
                NSString *photoURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];

                Panel *panel =[[Panel alloc] init];
                panel.panelId = panelId;
                
                Photo *photo = [[Photo alloc] init];
                photo.photoId = photoId;
                photo.imageURL = photoURL;
                panel.photo = photo;
                
                [panels addObject:panel];

            }//end while
        }//end if
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
    //NSArray* panelsArray = [[NSArray alloc] initWithArray:panels];
    return panels;
}
*/

-(NSArray*)convertPanelsSQLIntoPanels:(NSString*)groupHashId{
    NSMutableArray* panels = [[NSMutableArray alloc] init];
    //NSLog(@"convertPanelsSQLIntoPanels. databaseUpdating=%d", databaseUpdating);
    
    if(databaseUpdating)
    {
                dispatch_sync([self dispatchQueue], ^(void) {
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //const char* sqlStatement = "SELECT panelid, photoid, photourl FROM PANELS";
            //sqlite3_stmt *statement;
            
            NSString *selectSQL = [NSString stringWithFormat: @"SELECT panelid, photoid, photourl FROM PANELS where groupHashId=\"%@\"", groupHashId];
            //NSLog(@"selectSQL=%@", selectSQL);
            const char *sqlStatement = [selectSQL UTF8String];
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    int panelId= sqlite3_column_int(statement, 0);
                    //NSLog(@"panelId=%i", panelId);
                    int photoId= sqlite3_column_int(statement, 1);
                    //NSLog(@"photoId=%i", photoId);
                    NSString *photoURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                    
                    Panel *panel =[[Panel alloc] init];
                    panel.panelId = panelId;
                    
                    Photo *photo = [[Photo alloc] init];
                    photo.photoId = photoId;
                    photo.imageURL = photoURL;
                    panel.photo = photo;
                    
                    [panels addObject:panel];
                    
                }//end while
            }//end if
            else
            {
                NSLog( @"convertPanelsSQLIntoPanels. Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        //NSArray* panelsArray = [[NSArray alloc] initWithArray:panels];
        });
    }//end if
    else{
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            //const char* sqlStatement = "SELECT panelid, photoid, photourl FROM PANELS";
            //sqlite3_stmt *statement;
            
            NSString *selectSQL = [NSString stringWithFormat: @"SELECT panelid, photoid, photourl FROM PANELS where groupHashId=\"%@\"", groupHashId];
            //NSLog(@"selectSQL=%@", selectSQL);
            const char *sqlStatement = [selectSQL UTF8String];
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    int panelId= sqlite3_column_int(statement, 0);
                    //NSLog(@"panelId=%i", panelId);
                    int photoId= sqlite3_column_int(statement, 1);
                    //NSLog(@"photoId=%i", photoId);
                    NSString *photoURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                    
                    Panel *panel =[[Panel alloc] init];
                    panel.panelId = panelId;
                    
                    Photo *photo = [[Photo alloc] init];
                    photo.photoId = photoId;
                    photo.imageURL = photoURL;
                    panel.photo = photo;
                    
                    [panels addObject:panel];
                    
                }//end while
            }//end if
            else
            {
                NSLog( @"convertPanelsSQLIntoPanels. Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        //NSArray* panelsArray = [[NSArray alloc] initWithArray:panels];
    }//end else
    
    return panels;
}


-(NSArray*)convertPhotosSQLIntoPhotos:(NSString*)groupHashId{
    NSMutableArray* photos = [[NSMutableArray alloc] init];
    //NSLog(@"DataLoader.convertPhotosSQLIntoPhotos. databaseUpdating=%d", databaseUpdating);
    if(databaseUpdating){
        dispatch_sync([self dispatchQueue], ^(void) {
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            
            NSString *selectSQL = [NSString stringWithFormat: @"SELECT PhotoId, Photourl, Thumburl FROM photos where grouphashId=\"%@\"", groupHashId];
            const char *sqlStatement = [selectSQL UTF8String];
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    
                    int photoId= sqlite3_column_int(statement, 0);
                    NSString *imageURL = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(statement, 1)];
                    NSString *thumbURL = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(statement, 2)];
                    
                    Photo* photo = [[Photo alloc] init];
                    photo.photoId = photoId;
                    photo.imageURL = imageURL;
                    photo.thumbURL = thumbURL;
                    
                    [photos addObject:photo];
                }//end while
            }//end if
            else
            {
                NSLog( @"convertPhotosSQLIntoPhotos.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        });

    }//end if
    else{
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            
            NSString *selectSQL = [NSString stringWithFormat: @"SELECT photoid, photourl, thumburl FROM photos where grouphashid=\"%@\"", groupHashId];
            const char *sqlStatement = [selectSQL UTF8String];
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    
                    int photoId= sqlite3_column_int(statement, 0);
                    NSString *imageURL = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(statement, 1)];
                    NSString *thumbURL = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(statement, 2)];
                    
                    Photo* photo = [[Photo alloc] init];
                    photo.photoId = photoId;
                    photo.imageURL = imageURL;
                    photo.thumbURL = thumbURL;
                    
                    [photos addObject:photo];
                }//end while
            }//end if
            else
            {
                NSLog( @"convertPhotosSQLIntoPhotos.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)

    }//end else
       
    //NSArray* panelsArray = [[NSArray alloc] initWithArray:panels];
    return photos;

}

-(NSArray*)convertGroupSQLIntoGroup:(NSString*)groupHashId{
    NSMutableArray* groups = [[NSMutableArray alloc] init];
    
    if(databaseUpdating)
    {
                dispatch_sync([self dispatchQueue], ^(void) {
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            
            NSString *selectSQL = [NSString stringWithFormat: @"SELECT groupid, name, themeid FROM groups where grouphashid=%@", groupHashId];
            const char *sqlStatement = [selectSQL UTF8String];
            //const char* sqlStatement = "SELECT groupid, name, grouphashid, themeid FROM groups where grouphashid=";
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    
                    int groupId= sqlite3_column_int(statement, 0);
                    NSString *name = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(statement, 1)];
                    int themeId= sqlite3_column_int(statement, 2);
                    
                    Group* group= [[Group alloc] init];
                    group.groupId = groupId;
                    group.name = name;
                    group.hashId = groupHashId;
                    group.theme = [[Theme alloc] init];
                    group.theme.themeId = themeId;
                    
                    [groups addObject:group];
                }//end while
            }//end if
            else
            {
                NSLog( @"convertGroupSQLIntoGroup.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        });
        //NSArray* panelsArray = [[NSArray alloc] initWithArray:panels];
    }
    else{
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            
            NSString *selectSQL = [NSString stringWithFormat: @"SELECT groupid, name, themeid FROM groups where grouphashid=%@", groupHashId];
            const char *sqlStatement = [selectSQL UTF8String];
            //const char* sqlStatement = "SELECT groupid, name, grouphashid, themeid FROM groups where grouphashid=";
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    
                    int groupId= sqlite3_column_int(statement, 0);
                    NSString *name = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(statement, 1)];
                    int themeId= sqlite3_column_int(statement, 2);
                    
                    Group* group= [[Group alloc] init];
                    group.groupId = groupId;
                    group.name = name;
                    group.hashId = groupHashId;
                    group.theme = [[Theme alloc] init];
                    group.theme.themeId = themeId;
                    
                    [groups addObject:group];
                }//end while
            }//end if
            else
            {
                NSLog( @"convertGroupSQLIntoGroup.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        //NSArray* panelsArray = [[NSArray alloc] initWithArray:panels];
    }
 
    return groups;
}

-(NSArray*)convertGroupsSQLIntoGroups{
    NSMutableArray* groups = [[NSMutableArray alloc] init];

        if(databaseUpdating)
        {
            dispatch_sync([self dispatchQueue], ^(void) {
            
                const char* sqlStatement = "SELECT groupid, name, grouphashid, themeid FROM groups";
                sqlite3_stmt *statement;
                
                if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
                {
                    //Loop through all the returned rows (should be just one)
                    while( sqlite3_step(statement) == SQLITE_ROW )
                    {
                        
                        int groupId= sqlite3_column_int(statement, 0);
                        NSString *name = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(statement, 1)];
                        NSString *hashId = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(statement, 2)];
                        int themeId= sqlite3_column_int(statement, 3);
                        
                        Group* group= [[Group alloc] init];
                        group.groupId = groupId;
                        group.name = name;
                        group.hashId = hashId;
                        group.theme = [[Theme alloc] init];
                        group.theme.themeId = themeId;
                        
                        [groups addObject:group];
                    }//end while
                }//end if
                else
                {
                    NSLog( @"convertGroupsSQLIntoGroups. Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
                }
                
                // Finalize and close database.
                sqlite3_finalize(statement);
                //sqlite3_close(database);
            });
        }
        else{
            
            const char* sqlStatement = "SELECT groupid, name, grouphashid, themeid FROM groups";
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    
                    int groupId= sqlite3_column_int(statement, 0);
                    NSString *name = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(statement, 1)];
                    NSString *hashId = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(statement, 2)];
                    int themeId= sqlite3_column_int(statement, 3);
                    
                    Group* group= [[Group alloc] init];
                    group.groupId = groupId;
                    group.name = name;
                    group.hashId = hashId;
                    group.theme = [[Theme alloc] init];
                    group.theme.themeId = themeId;
                    
                    [groups addObject:group];
                }//end while
            }//end if
            else
            {
                NSLog( @"convertGroupsSQLIntoGroups. Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
    
    //NSArray* panelsArray = [[NSArray alloc] initWithArray:panels];
        }
        
 
    return groups;
}



-(NSArray*)convertComicsSQLIntoComics:(NSString*)groupHashId{
    //NSLog(@"convertComicsSQLIntoComics.");
    NSMutableArray* comics = [[NSMutableArray alloc] init];
    
    if(databaseUpdating){
        dispatch_sync([self dispatchQueue], ^(void) {
            
            NSString *insertSQL = [NSString stringWithFormat: @"SELECT comicid FROM comics where grouphashid=\"%@\"", groupHashId];
            //NSLog(@"insertSQL=%@", insertSQL);
            const char* sqlStatement = [insertSQL UTF8String];
            //const char* sqlStatement = "SELECT COUNT(*) FROM PANELS";
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    int comicId= sqlite3_column_int(statement, 0);
                    
                    NSArray* comicDetails = [self convertComicSQLIntoComic:comicId];
                    Comic *comic =[comicDetails objectAtIndex:0];
                    //Comic *comic =[[Comic alloc] init];
                    comic.comicId = comicId;
                    
                    [comics addObject:comic];
                    
                }//end while
            }//end if
            else
            {
                NSLog( @"convertComicsSQLIntoComics.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        });

    }//end if
    else{
        //dispatch_sync(databaseQueue, ^(void) {
        //if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
        {
            
            NSString *insertSQL = [NSString stringWithFormat: @"SELECT comicid FROM comics where grouphashid=\"%@\"", groupHashId];
            //NSLog(@"insertSQL=%@", insertSQL);
            const char* sqlStatement = [insertSQL UTF8String];
            //const char* sqlStatement = "SELECT COUNT(*) FROM PANELS";
            sqlite3_stmt *statement;
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
            {
                //Loop through all the returned rows (should be just one)
                while( sqlite3_step(statement) == SQLITE_ROW )
                {
                    int comicId= sqlite3_column_int(statement, 0);
                    
                    NSArray* comicDetails = [self convertComicSQLIntoComic:comicId];
                    Comic *comic =[comicDetails objectAtIndex:0];
                    //Comic *comic =[[Comic alloc] init];
                    comic.comicId = comicId;
                    
                    [comics addObject:comic];
                    
                }//end while
            }//end if
            else
            {
                NSLog( @"convertComicsSQLIntoComics.Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        
        //NSArray* panelsArray = [[NSArray alloc] initWithArray:panels];
        // });

    }//end else
     return comics;
}

/*
- (void)dealloc {
    sqlite3_close(database);
}
*/

#pragma mark NSURLConnection functions.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
       self.downloadedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.downloadedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    self.dataFeedConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    self.dataFeedConnection = nil;
}

@end
