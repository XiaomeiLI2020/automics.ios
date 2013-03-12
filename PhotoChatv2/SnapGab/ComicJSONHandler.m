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


+(NSDictionary*)convertComicIntoComicJSON:(Comic*)comic{
    
    NSMutableDictionary* comicdict = [[NSMutableDictionary alloc] init];
    if (comic.comicId > 0)
        [comicdict setValue:[[NSNumber alloc] initWithInt:comic.comicId] forKey:@"id"];
    
    if(comic.name != nil)
    {
        [comicdict setValue:comic.name forKey:@"name"];
    }
    
    if(comic.description != nil)
    {
        [comicdict setValue:comic.description forKey:@"description"];
    }
    
    if (comic.panels != nil){
        
        NSString* panelIds;
        
        for(int i=0; i<[comic.panels count]; i++)
        {
            if(panelIds==NULL)
            {
                panelIds= [NSString stringWithFormat:@"%i",[[comic.panels objectAtIndex:i] integerValue]];
            }
            else
                panelIds= [NSString stringWithFormat:@"%@,%i", panelIds, [[comic.panels objectAtIndex:i] integerValue]];
        }
        
        if(panelIds!=NULL)
        {
            [comicdict setValue:panelIds forKey:@"panels"];
        }
    }

    
    /*
    if (panel.panelId > 0)
        [paneldict setValue:[[NSNumber alloc] initWithInt:panel.panelId] forKey:@"id"];
    if (panel.photo != nil){
        if (panel.photo.photoId > 0)
            [paneldict setValue:[[NSNumber alloc] initWithInt:panel.photo.photoId] forKey:@"photo_id"];
        if (panel.photo.imageURL != nil)
            [paneldict setValue:panel.photo.imageURL forKey:@"photo_url"];
    }
    if (panel.placements != nil){
        NSArray* placementsJSON = [PlacementJSONHandler convertPlacementsIntoPlacementsJSON:panel.placements];
        if (placementsJSON.count > 0)
            [paneldict setValue:placementsJSON forKey:@"placements"];
    }
    if (panel.annotations != nil){
        NSArray* annotationsJSON = [AnnotationJSONHandler convertAnnotationsIntoAnnotationsJSON:panel.annotations];
        if (annotationsJSON.count > 0)
            [paneldict setValue:annotationsJSON forKey:@"annotations"];
    }
     */
    return comicdict;
}

/*

 +(NSDictionary*)convertPanelIntoPanelJSON:(Panel *)panel{
 NSMutableDictionary* paneldict = [[NSMutableDictionary alloc] init];
 if (panel.panelId > 0)
 [paneldict setValue:[[NSNumber alloc] initWithInt:panel.panelId] forKey:@"id"];
 if (panel.photo != nil){
 if (panel.photo.photoId > 0)
 [paneldict setValue:[[NSNumber alloc] initWithInt:panel.photo.photoId] forKey:@"photo_id"];
 if (panel.photo.imageURL != nil)
 [paneldict setValue:panel.photo.imageURL forKey:@"photo_url"];
 }
 if (panel.placements != nil){
 NSArray* placementsJSON = [PlacementJSONHandler convertPlacementsIntoPlacementsJSON:panel.placements];
 if (placementsJSON.count > 0)
 [paneldict setValue:placementsJSON forKey:@"placements"];
 }
 if (panel.annotations != nil){
 NSArray* annotationsJSON = [AnnotationJSONHandler convertAnnotationsIntoAnnotationsJSON:panel.annotations];
 if (annotationsJSON.count > 0)
 [paneldict setValue:annotationsJSON forKey:@"annotations"];
 }
 return paneldict;
 }

 
 */


@end
