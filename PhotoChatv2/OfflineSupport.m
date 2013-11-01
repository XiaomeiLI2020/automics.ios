//
//  OfflineSupport.m
//  PhotoChat
//
//  Created by Kwamena Appiah-Kubi on 10/10/13.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "OfflineSupport.h"
#import "Panel.h"
#import "PanelLoader.h"
#import "Annotation.h"

@implementation OfflineSupport


+(int)initTempID{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    int tempID = [[NSString stringWithFormat:@"%0.0f", timeStamp] intValue];
    
    [OfflineSupport saveToPrefKey:@"currentTempID" forValue:[NSString stringWithFormat:@"%i", tempID]];
    return tempID;
}

+(void)matchNetworkOperationIDToTempID:(NSString *)operationID{
    [OfflineSupport saveToPrefKey:operationID forValue:[OfflineSupport retriveFromPrefKey:@"currentTempID"]];
}


+(void) createPanelOfflineVersion:(Panel *) panelOfflineVer{
    
    // 1 create and retrive temp id in global space
    int tempID = [OfflineSupport initTempID];
    
    // 2 copy photo to expected location with id
    [OfflineSupport savePhotoToFile:panelOfflineVer.photo.image
                      usingFileName:[NSString stringWithFormat:@"panelPhoto%i.png", tempID]];
    
    [OfflineSupport savePhotoToFile:panelOfflineVer.photo.image
                      usingFileName:[NSString stringWithFormat:@"thumbPhoto%i.png", tempID]];
    
    // 3 save photo to db using tempID
    /*Panel *panel = [[Panel alloc] init];
    panelOfflineVer.panelId = tempID;
    NSLog(@"ak: panel.panelId: %i", panelOfflineVer.panelId);
    panelOfflineVer.photo.photoId = tempID;
    NSLog(@"ak: panel.photo.photoId: %i", panelOfflineVer.photo.photoId);
    panelOfflineVer.photo.imageURL = @"";
    
    panelOfflineVer.photo.imageURL = @"";
    panelOfflineVer.photo.thumbURL = @"";
    
    for (int i = 0; i<[panelOfflineVer.annotations count]; i++) {
        [[panelOfflineVer.annotations objectAtIndex:i] setAnnotationId:tempID + i];
    }
    
    
    
    
    NSString *currentGroupHashId = [OfflineSupport retriveFromPrefKey:@"current_group_hash"];
    NSArray *offlinePanels = [NSArray arrayWithObject:panelOfflineVer];
    
    NSArray *photos = [NSArray arrayWithObject:panelOfflineVer.photo];
    
    // 4 save panel to db using tempID
    PanelLoader *panelLoader = [[PanelLoader alloc] init];
    [panelLoader submitSQLRequestSavePhotos:photos andGroupHashId:currentGroupHashId];
    
    [panelLoader submitSQLRequestSavePanelsWithAssetsForGroup:offlinePanels andGroupHashId:currentGroupHashId];
    */
}

+(BOOL)doesKeyExist: (NSString *)key{
    return ([OfflineSupport retriveFromPrefKey:key] != nil) ? YES : NO;
}


+(void) saveToPrefKey: (NSString *)key forValue:(NSString *)value{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:value forKey:key];
    [def synchronize];
}

+(NSString *) retriveFromPrefKey: (NSString *)key{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def stringForKey:key];
}

+(void) savePhotoToFile:(UIImage *)imageToSave usingFileName:(NSString *)fileName{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSData * binaryImageData = UIImagePNGRepresentation(imageToSave);
    
    [binaryImageData writeToFile:[basePath stringByAppendingPathComponent:fileName] atomically:YES];
}

+(NSString *) retrivePathToFile: (int)tempID ofTypePanel:(BOOL)isPanel{
    NSString *fileType = (isPanel) ? @"panel" : @"thumb";
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *imgName = [NSString stringWithFormat:@"%@Photo%i.png", fileType, tempID];

    NSString *imgFile = [documentsDirectory stringByAppendingPathComponent:imgName];
    NSLog(@"ak: imgFileName: %@", imgFile);
    return imgFile;
}

+(BOOL) checkFileExistsWithName: (NSString*)fileName{
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    return [fileMgr fileExistsAtPath:filePath];
}

+(void) updateTempIDsToNewIDs: (NSString *)operationID retrivedPanelId: (NSString *)panelId{
    //1. check and retrive operation ID already exists
    NSString *tempPanelId = [OfflineSupport retriveFromPrefKey:operationID];
    
    if (tempPanelId == nil) return;
    
    //2. update db
    //PanelLoader *panelLoader = [[PanelLoader alloc] init];
    //[panelLoader removeTempPanelsAndPhoto:[tempPanelId intValue]];
    
    //3. rename files
    NSString  *oldFileName = [NSString stringWithFormat:@"panelPhoto%@.png", tempPanelId];
    NSString *newFileName = [NSString stringWithFormat:@"panelPhoto%@.png", panelId];
    
    [OfflineSupport renameFileToNewId:oldFileName toNewName:newFileName];
    
    oldFileName = [NSString stringWithFormat:@"thumbPhoto%@.png", tempPanelId];
    newFileName = [NSString stringWithFormat:@"thumbPhoto%@.png", panelId];
    
    [OfflineSupport renameFileToNewId:oldFileName toNewName:newFileName];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:operationID];
    
    //4. profit!
}


+(void) renameFileToNewId: (NSString *) oldName toNewName:(NSString*)newName{
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    NSString* oldFileName = [documentsDirectory stringByAppendingPathComponent:oldName];
    NSString* newFileName = [documentsDirectory stringByAppendingPathComponent:newName];
        
    NSError *error;
    
    if ([fileMgr moveItemAtPath:oldFileName toPath:newFileName error:&error] != YES)
        NSLog(@"Unable to move file: %@", [error localizedDescription]);
}






@end