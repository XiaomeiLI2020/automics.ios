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
+(NSString*)getURLForGetAnnotations;
+(NSString*)getURLForGetResourcesWithTheme:(int)themeId;
+(NSString*)getURLForGetResourceWithResourceId:(int)resourceId;
+(NSString*)getURLForGetPanelWithId:(int)panelId;
+(NSString*)getURLForPostPanel;
+(NSString*)getURLForPostPhoto;
+(NSString*)getURLForGetPhotoWithId:(int)photoId;
+(NSString*)getURLForGetPhotosForGroup:(NSString*)groupHashId;
+(NSString*)getURLForGetPhotosForTheme:(int)groupHashId;
+(NSString*)getAbsoluteURLUsingImageRelativePath:(NSString*)imageURL;
+(NSString*)getURLForGetResourceWithId:(int)resourceId;
+(NSString*)getURLForGetAnnotationWithId:(int)annotationId;
+(NSString*)getURLForGetComics;
+(NSString*)getURLForGetComicWithId:(int)comicId;
+(NSString*)getURLForPostLogin;
+(NSString*)getURLForGetGroups;
+(NSString*)getURLForGetGroup;
+(NSString*)getURLForGetGroup:(NSString*)groupHashId;
+(NSString*)getURLForJoinGroupWithHashId:(NSString*)hashId;
+(NSString*)getURLForPostGroupMembership;
+(NSString*)getURLForGetOrganisations;
+(NSString*)getURLForGetOrganisation:(int)organisationId;
+(NSString*)getURLForGetThemesForOrganisation:(int)organisationId;
+(NSString*)getURLForPostRegister;
+(NSString*)getURLForPostUser;
+(NSString*)getURLForPostUserWithId:(int)userId;
+(NSString*)getURLForPostNotification;

//ak
+(int)genRandomID;
//an end

@end