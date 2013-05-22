//
//  SQLiteLoader.m
//  PhotoChat
//
//  Created by Umar Rashid on 16/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "SQLiteLoader.h"

@implementation SQLiteLoader

@synthesize database;
@synthesize databasePath;


/*
-(void)createGroupsTables
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"groups"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
		const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *groups_stmt = "CREATE TABLE IF NOT EXISTS GROUPS (GROUPID INTEGER PRIMARY KEY, PHOTOID INTEGER, PHOTOURL TEXT)";
            
            if (sqlite3_exec(database, groups_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Group table failed to create.");
            }
            else
                NSLog(@"Group table created.");
            
            sqlite3_close(database);
            
        } else {
            NSLog(@"Failed to open/create database");
        }
    }//end if
    
}
*/

-(void)createGroupTables:(int)groupId
{
    NSError *err;
    NSString *docsDir;
    NSArray *dirPaths;
    NSString* groupName = [NSString stringWithFormat: @"group%i", groupId];
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:groupName]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    //Deleteing the previous version of the database file
    [filemgr removeItemAtPath:databasePath error:&err];
    if(err)
    {
        NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    }
    else
    {
        NSLog(@"File %@ deleted.", groupName);
    }
    
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
		const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *panels_stmt = "CREATE TABLE IF NOT EXISTS PANELS (PANELID INTEGER PRIMARY KEY, PHOTOID INTEGER, PHOTOURL TEXT)";
            const char *photos_stmt = "CREATE TABLE IF NOT EXISTS PHOTOS (PHOTOID INTEGER PRIMARY KEY, PHOTOURL TEXT, THUMBURL TEXT, DESCRIPTION TEXT, WIDTH REAL, HEIGHT REAL)";
            const char *resources_stmt = "CREATE TABLE IF NOT EXISTS RESOURCES (RESOURCEID INTEGER NOT NULL, THEMEID INTEGER NOT NULL, NAME TEXT, TYPE TEXT, PHOTOURL TEXT, THUMBURL TEXT, PRIMARY KEY(RESOURCEID, THEMEID))";
            const char *placements_stmt = "CREATE TABLE PLACEMENTS (PLACEMENTID INTEGER NOT NULL, PANELID INTEGER NOT NULL, RESOURCEID INTEGER, XOFF REAL, YOFF REAL, SCALE REAL, ANGLE REAL, ZINDEX INT, PRIMARY KEY(PLACEMENTID, PANELID))";
            const char *annotations_stmt = "CREATE TABLE IF NOT EXISTS ANNOTATIONS (ANNOTATIONID INTEGER PRIMARY KEY, PANELID INTEGER, TXT TEXT, XOFF REAL, YOFF REAL, BUBBLESTYLE INTEGER, FOPTIONS TEXT)";
            
            if (sqlite3_exec(database, panels_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Panel table failed to create.");
            }
            else
                NSLog(@"Panel table created.");
            
            
            if (sqlite3_exec(database, photos_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Photo table failed to create.");
            }
            else
                NSLog(@"Photo table created.");
            
            if (sqlite3_exec(database, placements_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Placement table failed to create.");
            }
            else
                NSLog(@"Placement table created.");
            
            if (sqlite3_exec(database, resources_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Resource table failed to create.");
            }
            else
                NSLog(@"Resource table created.");
            
            if (sqlite3_exec(database, annotations_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Annotation table failed to create.");
            }
            else
                NSLog(@"Annotation table created.");
            
            sqlite3_close(database);
            
        }
        else {
            NSLog(@"Failed to open/create database");
        }
    }//end if
    
}



-(void)submitRequestGetPanelsForGroup:(int)groupId
{
    
    sqlite3_stmt    *statement;
    NSString* groupName = [NSString stringWithFormat: @"group%i", groupId];
    NSFileManager *filemgr = [NSFileManager defaultManager];    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
		const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            NSString *querySQL = [NSString stringWithFormat: @"SELECT PANELID, PHOTOID, PHOTOURL FROM %@", groupName];
            const char *query_stmt = [querySQL UTF8String];
            if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                if (sqlite3_step(statement) == SQLITE_ROW)
                {
                    NSLog(@"Match found");
                }
                else
                {
                    NSLog(@"Match not found");
                }
                sqlite3_finalize(statement);
            }//end if
            
            sqlite3_close(database);

        }//end if
    }//end if
    
 
}

@end
