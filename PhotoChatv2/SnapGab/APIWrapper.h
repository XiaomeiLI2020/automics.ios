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
<<<<<<< HEAD
+(NSString*)getURLForGetAnnotations;
+(NSString*)getURLForGetResourcesWithTheme:(int)themeId;
+(NSString*)getURLForGetResourceWithResourceId:(int)resourceId;
+(NSString*)getURLForGetPanelWithId:(int)panelId;
+(NSString*)getURLForPostPanel;
=======

+(NSString*)getURLForGetPanelWithId:(int)panelId;

+(NSString*)getURLForPostPanel;

+(NSString*)getURLForPostPhoto;

+(NSString*)getAbsoluteURLUsingPanelImageRelativePath:(NSString*)imageURL;

+(NSString*)getURLForGetResourcesWithTheme:(int)themeId;

+(NSString*)getURLForGetResourceWithId:(int)resourceId;

+(NSString*)getURLForGetResourceWithResourceId:(int)resourceId;

+(NSString*)getURLForGetAnnotations;

>>>>>>> comicapi2
+(NSString*)getURLForGetAnnotationWithId:(int)annotationId;

//+(NSString*)getURLForGetPlacements;

+(NSString*)getURLForGetComics;

+(NSString*)getURLForGetComicWithId:(int)comicId;

+(NSString*)getURLForPostLogin;

+(NSString*)getURLForGetGroups;

+(NSString*)getURLForGetGroup;

+(NSString*)getURLForPostGroupMembership;

@end