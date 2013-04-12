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
+(NSString*)getURLForGetPhotosForGroup:(NSString*)groupHashId;
+(NSString*)getAbsoluteURLUsingImageRelativePath:(NSString*)imageURL;
+(NSString*)getURLForGetResourceWithId:(int)resourceId;
+(NSString*)getURLForGetAnnotationWithId:(int)annotationId;
+(NSString*)getURLForGetComics;
+(NSString*)getURLForGetComicWithId:(int)comicId;
+(NSString*)getURLForPostLogin;
+(NSString*)getURLForGetGroups;
+(NSString*)getURLForGetGroup;
+(NSString*)getURLForJoinGroupWithHashId:(NSString*)hashId;
+(NSString*)getURLForPostGroupMembership;

@end