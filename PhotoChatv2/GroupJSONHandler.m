//
//  GroupJSONHandler.m
//  PhotoChat
//
//  Created by Umar Rashid on 05/03/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "GroupJSONHandler.h"
#import "DataValidator.h"

@implementation GroupJSONHandler

NSString *GROUP_ID = @"id";
NSString *GROUP_NAME = @"name";
NSString *HASH_ID = @"hashid";
NSString *CURRENT_HASH_ID = @"current_hash_id";
NSString *THEME_ID = @"current_theme_id";
NSString *ORGANISATION_ID = @"organisation_id";
NSString *CREATED_AT = @"created_at";
NSString *UPDATED_AT = @"updated_at";


+(NSArray*)convertGroupsJSONIntoGroups:(NSArray*)groupsJSON{
    NSMutableArray *groups = [[NSMutableArray alloc] initWithCapacity:groupsJSON.count];
    for (NSDictionary *obj in groupsJSON){
        Group *group = [self convertGroupJSONIntoGroup:obj];
        [groups addObject:group];
    }
    return groups;

}

+(Group*)convertGroupJSONIntoGroup:(NSDictionary*)groupdict{
    Group* group = [[Group alloc] init];
    
    if( [groupdict valueForKey:GROUP_ID] != nil){
        NSNumber *groupId = [DataValidator checkKeyValueForNull:[groupdict valueForKey:GROUP_ID]];
        if (groupId != nil){
            group.groupId = [groupId intValue];
        }
    }
    if ([groupdict valueForKey:GROUP_NAME] != nil)
        group.name = [DataValidator checkKeyValueForNull:[groupdict valueForKey:GROUP_NAME]];
    if ([groupdict valueForKey:HASH_ID] != nil)
        group.hashId = [DataValidator checkKeyValueForNull:[groupdict valueForKey:HASH_ID]];
    if ([groupdict valueForKey:THEME_ID] != nil){
        NSNumber *themeId = [DataValidator checkKeyValueForNull:[groupdict valueForKey:THEME_ID]];
        if (themeId != nil){
            Theme* theme = [[Theme alloc] init];
            theme.themeId = [themeId intValue];
            group.theme = theme;
            //group.themeId = [themeId intValue];
        }
    }
    if ([groupdict valueForKey:ORGANISATION_ID] != nil){
        NSNumber *organisationId = [DataValidator checkKeyValueForNull:[groupdict valueForKey:ORGANISATION_ID]];
        if (organisationId != nil)
            group.organisation = [[Organisation alloc] init];
            group.organisation.organisationId = [organisationId intValue];
    }
    if ([groupdict valueForKey:CREATED_AT] != nil){
        NSString *createdAtString = [DataValidator checkKeyValueForNull:[groupdict valueForKey:CREATED_AT]];
        if (createdAtString != nil){
            group.createdAt = [self convertDateTimeStringIntoDate:createdAtString];
        }
    }
    if ([groupdict valueForKey:UPDATED_AT] != nil){
        NSString *updatedAtString = [DataValidator checkKeyValueForNull:[groupdict valueForKey:UPDATED_AT]];
        if (updatedAtString != nil){
            group.updatedAt = [self convertDateTimeStringIntoDate:updatedAtString];
        }
    }
    return group;
}


+(NSDictionary*)convertGroupIntoGroupJSON:(Group*)group{
    NSMutableDictionary* groupdict = [[NSMutableDictionary alloc] init];
    
    if(group.groupId > 0)
      [groupdict setValue:[[NSNumber alloc] initWithInt:group.groupId] forKey:GROUP_ID];
    
    if(group.hashId != nil)
    {
        [groupdict setValue:group.hashId forKey:HASH_ID];
    }
    
    if(group.name != nil)
    {
        [groupdict setValue:group.name forKey:@"name"];
    }
    
    if(group.theme!=nil)
    {
        int themeId=group.theme.themeId;
        if(themeId>0)
            [groupdict setValue:[[NSNumber alloc] initWithInt:themeId] forKey:THEME_ID];
    }
    
    if(group.organisation!=nil)
    {
        int organisationId=group.organisation.organisationId;
        if(organisationId>0)
            [groupdict setValue:[[NSNumber alloc] initWithInt:organisationId] forKey:ORGANISATION_ID];
    }
    
    
    return groupdict;
}

/*
 Convert RFC3339 date time string to an NSDate. String date format is : yyyy-MM-ddTHH:mm:ssZ
 */
+(NSDate*)convertDateTimeStringIntoDate:(NSString*)dateTimeString{
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate* date = [rfc3339DateFormatter dateFromString:dateTimeString];
    return date;
}

@end
