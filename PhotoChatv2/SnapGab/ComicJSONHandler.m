//
//  ComicJSONHandler.m
//  PhotoChat
//
//  Created by Shakir Ali on 25/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "ComicJSONHandler.h"
#import "DataValidator.h"
#import "Panel.h"

@implementation ComicJSONHandler

+(Comic*)convertComicJSONDictIntoComic:(NSDictionary*)comicJSON{
    Comic *comic = [[Comic alloc] init];
    //id.
    comic.comicId = [(NSString*)[comicJSON valueForKey:@"id"] integerValue];
    //name dict string object uses NSNull value in json deserilization.
    NSString* name = [comicJSON objectForKey:@"name"];
    comic.name = [DataValidator checkKeyValueForNull:name];
    //description dict string object uses NSNull value in json deserilization.
    NSString* desc = [comicJSON objectForKey:@"description"];
    comic.description = [DataValidator checkKeyValueForNull:desc];
    //panels
    if ([comicJSON valueForKey:@"panels"] != nil){
        NSString* panelsValue = [comicJSON objectForKey:@"panels"];
        panelsValue = [DataValidator checkKeyValueForNull:panelsValue];
        if (panelsValue != nil){
            NSArray* panelIds = [panelsValue componentsSeparatedByString:@","];
            NSMutableArray* panels = [[NSMutableArray alloc] initWithCapacity:panelIds.count];
            for (NSString* panelId in panelIds){
                Panel *panel = [[Panel alloc] init];
                panel.panelId = [panelId intValue];
                [panels addObject:panel];
            }
            comic.panels = panels;
        }
    }
    return comic;
}

+(NSArray*)convertComicsJSONArrayIntoComics:(NSArray*)comicsJSON{
    NSMutableArray *comics = [[NSMutableArray alloc] initWithCapacity:comicsJSON.count];
    for (NSDictionary *obj in comicsJSON){
        Comic *comic = [ComicJSONHandler convertComicJSONDictIntoComic:obj];
        [comics addObject:comic];
    }
    return comics;
}

@end
