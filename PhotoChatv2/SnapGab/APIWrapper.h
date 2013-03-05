//
//  APIWrapper.h
//  PhotoChat
//
//  Created by Shakir Ali on 15/02/2013.
//  Copyright (c) 2013 Horizon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIWrapper : NSObject

+(NSString*)getURLForGetPanels;

+(NSString*)getURLForGetPanelWithId:(int)panelId;

+(NSString*)getURLForPostPanel;

+(NSString*)getURLForPostPhoto;

+(NSString*)getAbsoluteURLUsingPanelImageRelativePath:(NSString*)imageURL;

+(NSString*)getURLForGetResourcesWithTheme:(int)themeId;

+(NSString*)getURLForGetResourceWithId:(int)resourceId;

+(NSString*)getURLForGetResourceWithResourceId:(int)resourceId;

+(NSString*)getURLForGetAnnotations;

+(NSString*)getURLForGetAnnotationWithId:(int)annotationId;

//+(NSString*)getURLForGetPlacements;

+(NSString*)getURLForGetComics;

+(NSString*)getURLForGetComicWithId:(int)comicId;

+(NSString*)getURLForPostLogin;

+(NSString*)getURLForGetGroups;

+(NSString*)getURLForGetGroup;

+(NSString*)getURLForPostGroupMembership;

@end