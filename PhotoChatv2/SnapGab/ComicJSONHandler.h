//
//  ComicJSONHandler.h
//  PhotoChat
//
//  Created by Shakir Ali on 25/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comic.h"
#import "JSONHandler.h"

@interface ComicJSONHandler : JSONHandler

+(Comic*)convertComicJSONDictIntoComic:(NSDictionary*)comicJSON;
+(NSArray*)convertComicsJSONArrayIntoComics:(NSArray*)comicsJSON;
+(NSDictionary*)convertComicIntoComicJSON:(Comic*)comic;

@end
