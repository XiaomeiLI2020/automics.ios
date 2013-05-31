//
//  ThemeJSONHandler.h
//  PhotoChat
//
//  Created by Umar Rashid on 27/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "JSONHandler.h"
#import "Theme.h"

@interface ThemeJSONHandler : JSONHandler

+(Theme*)getThemeFromThemeJSON:(NSDictionary*)themeJSON;
+(NSArray*)getThemesFromThemesJSON:(NSArray*)themesJSON;

@end
