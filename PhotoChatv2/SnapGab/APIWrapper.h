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
<<<<<<< HEAD
+(NSString*)getURLForGetResourceWithId:(int)resourceId;
=======
+(NSString*)getURLForGetResourceWithResourceId:(int)resourceId;
+(NSString*)getURLForGetPlacements;

>>>>>>> comicapi
+(NSString*)getURLForGetPanelWithId:(int)panelId;
+(NSString*)getURLForPostPanel;
+(NSString*)getURLForGetAnnotationWithId:(int)annotationId;
+(NSString*)getAbsoluteURLUsingPanelImageRelativePath:(NSString*)imageURL;
+(NSString*)getURLForGetComics;
+(NSString*)getURLForGetComicWithId:(int)comicId;
+(NSString*)getURLForPostPhoto;

@end