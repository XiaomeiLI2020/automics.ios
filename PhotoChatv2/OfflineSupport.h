//
//  OfflineSupport.h
//  PhotoChat
//
//  Created by Kwamena Appiah-Kubi on 10/10/13.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Panel.h"

@interface OfflineSupport : NSObject

+(void) createPanelOfflineVersion:(Panel *) panelOfflineVer;

+(void)matchNetworkOperationIDToTempID:(NSString *)operationID;

+(void) saveToPrefKey: (NSString *)key forValue:(NSString *)value;

+(NSString *) retriveFromPrefKey:(NSString *)key;

+(NSString *) retrivePathToFile: (int)tempID ofTypePanel:(BOOL)isPanel;

+(void) updateTempIDsToNewIDs: (NSString *)operationID retrivedPanelId: (NSString *)panelId;

+(BOOL) checkFileExistsWithName: (NSString*)fileName;

@end
