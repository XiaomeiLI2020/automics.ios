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
+(NSString*)getAbsoluteURLUsingPanelImageRelativePath:(NSString*)imageURL;
+(NSString*)getURLForGetComics;
+(NSString*)getURLForGetComicWithId:(int)comicId;

@end