//
//  GroupJSONHandler.h
//  PhotoChat
//
//  Created by Umar Rashid on 05/03/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONHandler.h"
#import "Group.h"

@interface GroupJSONHandler : JSONHandler

+(NSArray*)convertGroupsJSONIntoGroups:(NSArray*)groupsJSON;
+(Group*)convertGroupJSONIntoGroup:(NSDictionary*)groupJSON;

@end
