//
//  ThemeJSONHandler.m
//  PhotoChat
//
//  Created by Umar Rashid on 27/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ThemeJSONHandler.h"
#import "DataValidator.h"

@implementation ThemeJSONHandler

+(Theme*)getThemeFromThemeJSON:(NSDictionary*)themeJSON{
    Theme* theme = [[Theme alloc] init];
    if ([themeJSON valueForKey:@"id"] != nil){
        NSString* themeId = [DataValidator checkKeyValueForNull:[themeJSON valueForKey:@"id"]];
        if (themeId != nil)
            theme.themeId = [themeId integerValue];
    }
    if ([themeJSON valueForKey:@"name"] != nil){
        NSString* name = [DataValidator checkKeyValueForNull:[themeJSON valueForKey:@"name"]];
        if (name != nil)
            theme.name = name;
    }
    return theme;
}
+(NSArray*)getThemesFromThemesJSON:(NSArray*)themesJSON{
    NSMutableArray* themes = [[NSMutableArray alloc] initWithCapacity:themesJSON.count];
    for (NSDictionary *themedict in themesJSON){
        Theme *theme = [self getThemeFromThemeJSON:themedict];
        [themes addObject:theme];
    }
    return themes;
}


@end
