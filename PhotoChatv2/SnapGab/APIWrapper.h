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
+(NSString*)getURLForGetPhotos;
+(NSString*)getURLForGetAnnotations;

+(NSString*)getURLForGetResourcesWithTheme:(int)themeId;
+(NSString*)getURLForGetResourceWithResourceId:(int)resourceId;
+(NSString*)getURLForGetPlacements;

+(NSString*)getURLForGetPanelWithId:(int)panelId;
+(NSString*)getURLForGetAnnotationWithId:(int)annotationId;
+(NSString*)getAbsoluteURLUsingPanelImageRelativePath:(NSString*)imageURL;
+(NSString*)getURLForGetComics;
+(NSString*)getURLForGetComicWithId:(int)comicId;

@end