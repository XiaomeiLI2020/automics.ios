//
//  SQLiteLoader.h
//  PhotoChat
//
//  Created by Umar Rashid on 16/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SQLiteLoader : NSObject


@property sqlite3* database;
@property NSString *databasePath;


-(void)createGroupTables:(int)groupId;
-(void)submitRequestGetPanelsForGroup:(int)groupId;

@end
