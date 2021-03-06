//
//  PanelJSONHandler.m
//  PhotoChat
//
//  Created by Shakir Ali on 21/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "PanelJSONHandler.h"
#import "APIWrapper.h"
#import "PlacementJSONHandler.h"
#import "AnnotationJSONHandler.h"
#import "DataValidator.h"
#import "Photo.h"

@implementation PanelJSONHandler

+(Panel*)convertPanelJSONDictIntoPanel:(NSDictionary*)panelJSON{
    Panel *panel = [[Panel alloc] init];
    //id.
    NSNumber *panelId = [panelJSON valueForKey:@"id"];
    panelId = [DataValidator checkKeyValueForNull:panelId];
    panel.panelId = [panelId intValue];
    
    //photoid dict string object uses NSNull value in json deserilization.
    NSNumber *photoId = [panelJSON valueForKey:@"photo_id"];
    photoId = [DataValidator checkKeyValueForNull:photoId];
    if (photoId != nil && [photoId intValue] > 0){
        Photo *photo = [[Photo alloc] init];
        photo.photoId = [photoId intValue];
        //url dict string object uses NSNull value in json deserilization.
        NSString* url = [panelJSON objectForKey:@"photo_url"];
        url = [DataValidator checkKeyValueForNull:url];
        if (url != nil){
            url = [APIWrapper getAbsoluteURLUsingImageRelativePath:url];
            photo.imageURL = url;
            
        }
        panel.photo = photo;
    }
    //placements
    if ([panelJSON valueForKey:@"placements"] != nil){
        NSArray* placementArray = [panelJSON valueForKey:@"placements"];
        if (![placementArray isEqual:[NSNull null]]){
            NSArray *placements = [PlacementJSONHandler getPlacementsFromPlacementsJSON:placementArray];
            panel.placements = placements;
        }
    }
    
    //annotations
    if ([panelJSON valueForKey:@"annotations"] != nil){
        NSArray* annotationArray = [panelJSON valueForKey:@"annotations"];
        if (![annotationArray isEqual:[NSNull null]]){
            NSArray* annotations = [AnnotationJSONHandler getAnnotationsFromAnnotationsJSON:annotationArray];
            panel.annotations = annotations;
        }
    }

    return panel;
}

+(NSArray*)convertPanelsJSONIntoPanels:(NSArray*)panelsJSON{
    NSMutableArray *panels = [[NSMutableArray alloc] initWithCapacity:panelsJSON.count];
    for (NSDictionary *obj in panelsJSON){
        Panel *panel = [PanelJSONHandler convertPanelJSONDictIntoPanel:obj];
        [panels addObject:panel];
    }
    return panels;
}

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

@end
