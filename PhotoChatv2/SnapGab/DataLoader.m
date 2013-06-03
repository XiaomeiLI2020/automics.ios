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

@implementation DataLoader

@synthesize postRequestType;
@synthesize dict;
@synthesize request;
@synthesize httpMethod;
@synthesize downloadedData;
@synthesize dataFeedConnection;

@synthesize database;
@synthesize databasePath;

/*
+(void)changeReachability{
    reachabilityChanged = !reachabilityChanged;
}
 */
-(void)initConnectionRequest{
    if (dataFeedConnection)
        [dataFeedConnection cancel];
    self.dataFeedConnection = nil;
    self.downloadedData = nil;
}

-(NSString*)authenticatedGetURL:(NSString*)urlString
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* sessionToken = [prefs objectForKey:@"session"];
    NSString* authenticatedURL = [NSString stringWithFormat:@"%@?session=%@", urlString, sessionToken];
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

-(void)submitSQLRequestCreateTablesForGroup:(int)groupId{
    NSError *err;
    NSString *docsDir;
    NSArray *dirPaths;
    NSString* groupName = [NSString stringWithFormat: @"automics.sql"];
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:groupName]];
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
        //NSLog(@"File %@ deleted.", groupName);
    }

    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
		const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *panels_stmt = "CREATE TABLE IF NOT EXISTS PANELS (PANELID INTEGER, GROUPID INTEGER,  PHOTOID INTEGER, PHOTOURL TEXT, NUMPLACEMENTS REAL, NUMANNOTATIONS REAL, PRIMARY KEY(PANELID, GROUPID))";
            //            const char *panels_stmt = "CREATE TABLE IF NOT EXISTS PANELS (PANELID INTEGER PRIMARY KEY, PHOTOID INTEGER, PHOTOURL TEXT, NUMPLACEMENTS REAL, NUMANNOTATIONS REAL)";
            const char *photos_stmt = "CREATE TABLE IF NOT EXISTS PHOTOS (PHOTOID INTEGER PRIMARY KEY, PHOTOURL TEXT, THUMBURL TEXT, DESCRIPTION TEXT, WIDTH REAL, HEIGHT REAL)";
            const char *resources_stmt = "CREATE TABLE IF NOT EXISTS RESOURCES (RESOURCEID INTEGER NOT NULL PRIMARY KEY, THEMEID INTEGER NOT NULL, NAME TEXT, TYPE TEXT, PHOTOURL TEXT, THUMBURL TEXT)";
            //const char *placements_stmt = "CREATE TABLE PLACEMENTS (PLACEMENTID INTEGER NOT NULL AUTOINCREMENT, PANELID INTEGER NOT NULL, RESOURCEID INTEGER, XOFF REAL, YOFF REAL, SCALE REAL, ANGLE REAL, ZINDEX INT, PRIMARY KEY(PLACEMENTID, PANELID))";
            const char *placements_stmt = "CREATE TABLE PLACEMENTS (PLACEMENTID INTEGER NOT NULL PRIMARY KEY, PANELID INTEGER NOT NULL, RESOURCEID INTEGER, XOFF REAL, YOFF REAL, SCALE REAL, ANGLE REAL, ZINDEX INT)";
            const char *annotations_stmt = "CREATE TABLE IF NOT EXISTS ANNOTATIONS (ANNOTATIONID INTEGER NOT NULL PRIMARY KEY, PANELID INTEGER, TXT TEXT, XOFF REAL, YOFF REAL, BUBBLESTYLE INTEGER, FOPTIONS TEXT)";
            const char *comics_stmt = "CREATE TABLE IF NOT EXISTS COMICS (COMICID INTEGER PRIMARY KEY, NAME TEXT, DESCRIPTION TEXT, NUMPANELS INTEGER)";
            const char *comicpanels_stmt = "CREATE TABLE IF NOT EXISTS COMICPANELS (ID INTEGER PRIMARY KEY, COMICID INTEGER, PANELID INTEGER, PANELPOSITION INTEGER)";
            
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
            sqlite3_close(database);
            
        }
        else {
            NSLog(@"Failed to open/create database");
        }
    }//end if
    
}

-(void)submitSQLRequestCreateTablesForApp{
    NSError *err;
    NSString *docsDir;
    NSArray *dirPaths;
    NSString* groupName = [NSString stringWithFormat: @"automics.sql"];
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:groupName]];
    //databasePathStatic = databasePath;
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
        //NSLog(@"File %@ deleted.", groupName);
    }

    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
		const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *panels_stmt = "CREATE TABLE IF NOT EXISTS PANELS (PANELID INTEGER, GROUPID INTEGER,  PHOTOID INTEGER, PHOTOURL TEXT, NUMPLACEMENTS REAL, NUMANNOTATIONS REAL, PRIMARY KEY(PANELID, GROUPID))";
            const char *photos_stmt = "CREATE TABLE IF NOT EXISTS PHOTOS (PHOTOID INTEGER, GROUPID INTEGER, PHOTOURL TEXT, THUMBURL TEXT, DESCRIPTION TEXT, WIDTH REAL, HEIGHT REAL)";
            const char *resources_stmt = "CREATE TABLE IF NOT EXISTS RESOURCES (RESOURCEID INTEGER, THEMEID INTEGER, NAME TEXT, TYPE TEXT, PHOTOURL TEXT, THUMBURL TEXT, PRIMARY KEY(RESOURCEID, THEMEID))";
            const char *placements_stmt = "CREATE TABLE PLACEMENTS (PLACEMENTID INTEGER, PANELID INTEGER, GROUPID INTEGER, RESOURCEID INTEGER, XOFF REAL, YOFF REAL, SCALE REAL, ANGLE REAL, ZINDEX INTEGER, PRIMARY KEY(PLACEMENTID, PANELID, GROUPID))";
            const char *annotations_stmt = "CREATE TABLE IF NOT EXISTS ANNOTATIONS (ANNOTATIONID INTEGER, PANELID INTEGER, GROUPID INTEGER, TXT TEXT, XOFF REAL, YOFF REAL, BUBBLESTYLE INTEGER, FOPTIONS TEXT, PRIMARY KEY(ANNOTATIONID, PANELID, GROUPID))";
            const char *comics_stmt = "CREATE TABLE IF NOT EXISTS COMICS (COMICID INTEGER, GROUPID INTEGER, NAME TEXT, DESCRIPTION TEXT, NUMPANELS INTEGER, PRIMARY KEY(COMICID, GROUPID))";
            const char *comicpanels_stmt = "CREATE TABLE IF NOT EXISTS COMICPANELS (ID INTEGER PRIMARY KEY, COMICID INTEGER, GROUPID INTEGER, PANELID INTEGER, PANELPOSITION INTEGER)";
            
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
            sqlite3_close(database);
            
        }
        else {
            NSLog(@"Failed to open/create database");
        }
    }//end if
    
}



-(int)submitSQLRequestCheckResourceExists:(int)resourceId
{
    int rowCount=0;
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
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
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
    return rowCount;
}

-(NSArray*)convertComicSQLIntoComic:(int)comicId{
    NSMutableArray* comics = [[NSMutableArray alloc] init];
    NSMutableArray* panels = [[NSMutableArray alloc] init];
    Comic *comic =[[Comic alloc] init];
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
    {
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
                int panelPosition=sqlite3_column_int(statement, 1);
                
                Panel* panel = [[Panel alloc] init];
                panel.panelId = panelId;
                [panels insertObject:panel atIndex:panelPosition];
                
            }//end while
        }//end if
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        //sqlite3_finalize(statement);
        //sqlite3_close(database);
        
               
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
    comic.panels = panels;
    [comics addObject:comic];
    return comics;
    
}

-(int)submitSQLRequestCheckComicExists:(int)comicId
{
    int rowCount=0;
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
    {
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
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
    return rowCount;
}


-(int)submitSQLRequestCheckPanelExists:(int)panelId{
    int rowCount=0;
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
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
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
    return rowCount;
}

-(int)submitSQLRequestGetAssetsForPanel:(int)panelId{
    int rowCount=0;
    float numPlacements=-1;
    float numAnnotations=-1;
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
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
                //NSLog(@"numPlacements=%f, numAnnotations=%f", numPlacements, numAnnotations);
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
    if(numPlacements>=0 && numAnnotations>=0)
        return 1;
    else
        return 0;
    return rowCount;
}

-(void)submitSQLRequestGetPanelForId:(int)panelId{
    int rowCount=0;
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
    {
        //NSString *querySQL = [NSString stringWithFormat: @"SELECT address, phone FROM contacts WHERE name=\"%@\"", name.text];
        NSString *retrieveSQL = [NSString stringWithFormat: @"select annotationId from annotations where panelid=\"%i\"", panelId];
        const char* sqlStatement = [retrieveSQL UTF8String];
        sqlite3_stmt *statement;
        
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            if(sqlite3_step(statement)!=SQLITE_ROW)
                //NSLog(@"Rowcount is %d",rowCount);
            
            while(sqlite3_step(statement) == SQLITE_ROW )
            {
                rowCount = sqlite3_column_int(statement, 0);
                NSLog(@"Rowcount is %d",rowCount);
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
}

-(int)submitSQLRequestCountComicsForGroup:(int)groupId{
    int rowCount=0;
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
    {
        const char* sqlStatement = "SELECT COUNT(*) FROM COMICS";
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
        sqlite3_close(database);
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
    return rowCount;
}


-(int)submitSQLRequestCountPanelsForGroup:(int)groupId{
    int rowCount=0;
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat: @"SELECT COUNT(*) FROM PANELS where groupId=%i", groupId];
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
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
    return rowCount;
}

-(void)submitSQLRequestSaveAssetsForPanel:(int)panelId andPlacements:(NSArray*)placements andAnnotations:(NSArray*)annotations
{
    float numPlacements =  [[NSNumber numberWithInt:[placements count]] floatValue];
    float numAnnotations = [[NSNumber numberWithInt:[annotations count]] floatValue];
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePathStatic UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"update PANELS set numplacements=%f, numannotations=%f where panelId=%i", numPlacements, numAnnotations, panelId];
        //NSLog(@"insertSQL=%@", insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            //NSLog(@"Panel updated");
            
        } else {
            //NSLog(@"Failed to update panel");
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    if([placements count]>0)
    {
        for(int i=0; i<[placements count]; i++)
        {
            Placement* placement = [placements objectAtIndex:i];
            if(placement!=nil)
            {
                if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                {
                    //(PLACEMENTID INTEGER NOT NULL, PANELID INTEGER NOT NULL, RESOURCEID INTEGER, XOFF REAL, YOFF REAL, SCALE REAL, ANGLE REAL, ZINDEX INT, PRIMARY KEY(PLACEMENTID, PANELID))"
                    NSString *insertSQL = [NSString stringWithFormat: @"insert into placements (PANELID, RESOURCEID, XOFF, YOFF, SCALE, ANGLE, ZINDEX) values(%i, %i, %f, %f, %f, %f, %i)", panelId, placement.resourceId, placement.xOffset, placement.yOffset, placement.scale, placement.angle, placement.zIndex];
                    //NSLog(@"insertSQL=%@", insertSQL);
                    const char *insert_stmt = [insertSQL UTF8String];
                    
                    sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                    if (sqlite3_step(statement) == SQLITE_DONE)
                    {
                        //NSLog(@"Placement added");
                        
                    } else {
                        //NSLog(@"Failed to add placement");
                    }
                    sqlite3_finalize(statement);
                    sqlite3_close(database);
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
                if(sqlite3_open(dbpath, &database) == SQLITE_OK)
                {
                    //(ANNOTATIONID INTEGER NOT NULL PRIMARY KEY, PANELID INTEGER, TXT TEXT, XOFF REAL, YOFF REAL, BUBBLESTYLE INTEGER, FOPTIONS TEXT)
                    NSString *insertSQL = [NSString stringWithFormat: @"insert into annotations(ANNOTATIONID, PANELID, TXT, XOFF, YOFF, BUBBLESTYLE, FOPTIONS) values(%i, %i, \"%@\", %f, %f, %i, \"%@\")", annotation.annotationId, panelId, annotation.text, annotation.xOffset, annotation.yOffset, annotation.bubbleStyle, annotation.formattingOptions];
                    //NSLog(@"insertSQL=%@", insertSQL);
                    const char *insert_stmt = [insertSQL UTF8String];
                    
                    sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                    if (sqlite3_step(statement) == SQLITE_DONE)
                    {
                        //NSLog(@"Annotation added");
                        
                    } else {
                        //NSLog(@"Failed to add annotation");
                    }
                    sqlite3_finalize(statement);
                    sqlite3_close(database);
                }//end if(sqlite3_open(dbpath, &database) == SQLITE_OK)
            }//end if(placement!=nil)
        }//end for
    }//end if([placements count]>0)
    
}

//-(void)submitSQLRequestSaveAssetsForPanel:(Panel*)panel{
-(void)submitSQLRequestSaveAssetsForPanel:(int)panelId andNumPlacements:(int)placements andNumAnnotations:(int)annotations
{
    float numPlacements =  [[NSNumber numberWithInt:placements] floatValue];
    float numAnnotations = [[NSNumber numberWithInt:annotations] floatValue];
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePathStatic UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"update PANELS set numplacements=%f, numannotations=%f where panelId=%i", numPlacements, numAnnotations, panelId];
        //NSLog(@"insertSQL=%@", insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            //NSLog(@"Panel updated");
            
        } else {
            //NSLog(@"Failed to update panel");
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }

    
}

-(int)submitSQLRequestCheckThemeExists:(int)themeId{
    int rowCount=0;
    
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
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
        sqlite3_close(database);
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
    return rowCount;
}

-(void)submitSQLRequestSaveResources:(NSArray*)resources{
    if(resources!=nil){
        
        for(int i=0; i<[resources count]; i++)
        {
            Resource* resource = [resources objectAtIndex:i];
            [self submitSQLRequestSaveResource:resource.resourceId andThemeId:1 andType:resource.type andImageURL:resource.imageURL andThumbURL:resource.thumbURL];
        }//end for
        
    }//end if(resources!=nil)
}

//-(void)submitSQLRequestSaveResource:(int)resourceId
-(void)submitSQLRequestSaveResource:(int)resourceId andThemeId:(int)themeId andType:(NSString*)type andImageURL:(NSString*)imageURL andThumbURL:(NSString*)thumbURL
{
    //NSLog(@"Resource being stored in the database yet");
    sqlite3_stmt    *statement;
    const char *dbpath = [databasePathStatic UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO resources(resourceid, themeId, TYPE, PHOTOURL, THUMBURL) VALUES(%i, %i, \"%@\",\"%@\",\"%@\")", resourceId, themeId, type, imageURL, thumbURL];
        //NSLog(@"insertSQL=%@", insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            //NSLog(@"Resource added");
            
        } else {
            //NSLog(@"Failed to add resource");
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }

    
}

-(void)submitSQLRequestSavePanels:(NSArray*)panels{
    
    for(int i=0; i<[panels count]; i++)
    {
        Panel* panel = [panels objectAtIndex:i];
        if(panel!=nil)
        {
            sqlite3_stmt    *statement;
            const char *dbpath = [databasePathStatic UTF8String];
            
            if (sqlite3_open(dbpath, &database) == SQLITE_OK)
            {
                NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO PANELS (panelid, photoid, photourl, numplacements, numannotations) VALUES (\"%i\", \"%i\", \"%@\", \"%f\", \"%f\")", panel.panelId, panel.photo.photoId, panel.photo.imageURL, -1.0, -1.0];
                
                const char *insert_stmt = [insertSQL UTF8String];
                
                sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    //NSLog(@"Panel added");

                } else {
                    //NSLog(@"Failed to add panel");
                }
                sqlite3_finalize(statement);
                sqlite3_close(database);
            }
        }//end if(panel!=nil)
    }//end for
}

-(void)submitSQLRequestSavePanelsForGroup:(NSArray *)panels andGroupId:(int)groupId{
    
    for(int i=0; i<[panels count]; i++)
    {
        Panel* panel = [panels objectAtIndex:i];
        if(panel!=nil)
        {
            sqlite3_stmt    *statement;
            const char *dbpath = [databasePathStatic UTF8String];
            if (sqlite3_open(dbpath, &database) == SQLITE_OK)
            {
                NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO PANELS (panelId, groupId, photoId, photourl, numplacements, numannotations) VALUES (\"%i\",\"%i\",\"%i\",\"%@\", \"%f\", \"%f\")", panel.panelId, groupId, panel.photo.photoId, panel.photo.imageURL, -1.0, -1.0];
                
                const char *insert_stmt = [insertSQL UTF8String];
                
                sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    //NSLog(@"Panel added");
                    
                } else {
                    //NSLog(@"Failed to add panel");
                }
                sqlite3_finalize(statement);
                sqlite3_close(database);
            }
        }//end if(panel!=nil)
    }//end for
}


-(void)submitSQLRequestSaveComics:(NSArray*)comics{
    
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
}


-(NSArray*)convertResourcesSQLIntoResources:(int)themeId{
    
    NSMutableArray* resources = [[NSMutableArray alloc] init];
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
    {
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
        sqlite3_close(database);
    }//end if
    

    return resources;
}

-(NSArray*)convertResourceSQLIntoResource:(int)resourceId{
    NSMutableArray* resources = [[NSMutableArray alloc] init];
    Resource* resource= [[Resource alloc] init];
    
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
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
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }//end if
    
    [resources addObject:resource];
    return resources;
}

-(NSArray*)convertPanelSQLIntoPanel:(int)panelId{
    
    NSMutableArray* panels = [[NSMutableArray alloc] init];
    NSMutableArray* placements = [[NSMutableArray alloc] init];
    NSMutableArray* annotations = [[NSMutableArray alloc] init];
    
    Panel *panel =[[Panel alloc] init];
    int numPlacements=0;
    int numAnnotations=0;
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
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
                NSString *photoURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                numPlacements = (int) sqlite3_column_double(statement, 2);
                numAnnotations = (int) sqlite3_column_double(statement, 3);

                panel.panelId = panelId;
                Photo *photo = [[Photo alloc] init];
                photo.photoId = photoId;
                photo.imageURL = photoURL;
                panel.photo = photo;
                
            }//end while
        }//end if
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        //sqlite3_finalize(statement);
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
                NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            //sqlite3_finalize(statement);
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
                    annotation.text = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                    annotation.bubbleStyle = sqlite3_column_int(statement, 4);
                    [annotations addObject:annotation];
                    
                }//end while
                
            }//end if
            else
            {
                NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
            }
            
            // Finalize and close database.
            //sqlite3_finalize(statement);
            //sqlite3_close(database);
        }//end if(numAnnotations>0)

        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
    panel.placements = placements;
    panel.annotations = annotations;
    [panels addObject:panel];
    return panels;
}

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

-(NSArray*)convertComicsSQLIntoComics:(int)groupId{
    
    NSMutableArray* comics = [[NSMutableArray alloc] init];
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
    {
        const char* sqlStatement = "SELECT comicid FROM Comics";
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
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    
    //NSArray* panelsArray = [[NSArray alloc] initWithArray:panels];
    return comics;
}


-(void)submitSQLRequestGetPanelsForGroup:(int)groupId{

    //NSLog(@"databasePath=%@, databasePathStatic=%@ ", databasePath, databasePathStatic);
    if(sqlite3_open([databasePathStatic UTF8String], &database) == SQLITE_OK)
    {
        const char* sqlStatement = "SELECT COUNT(*) FROM PANELS";
        sqlite3_stmt *statement;
        
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                //NSInteger count = sqlite3_column_int(statement, 0);
                //NSLog(@"Rowcount is %d",count);
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }//end if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)

}


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
