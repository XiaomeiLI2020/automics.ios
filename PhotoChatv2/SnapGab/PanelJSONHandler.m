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

@implementation PanelJSONHandler

+(Panel*)convertPanelJSONDictIntoPanel:(NSDictionary*)panelJSON{
    Panel *panel = [[Panel alloc] init];
    //id.
    panel.panelId = [(NSString*)[panelJSON valueForKey:@"id"] integerValue];
    
    //url dict string object uses NSNull value in json deserilization.
    panel.photoId = [(NSString*)[panelJSON valueForKey:@"photo_id"] integerValue];

    
    //url dict string object uses NSNull value in json deserilization.
    NSString* url = [panelJSON objectForKey:@"image_url"];
    url = [DataValidator checkKeyValueForNull:url];
    if (url != nil)
        url = [APIWrapper getAbsoluteURLUsingPanelImageRelativePath:url];
    panel.imageURL = url;
    
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
    if (panel.photoId > 0)
        [paneldict setValue:[[NSNumber alloc] initWithInt:panel.photoId] forKey:@"photo_id"];
    if (panel.imageURL != nil)
        [paneldict setValue:panel.imageURL forKey:@"image_url"];
    if (panel.placements != nil){
        NSArray* placementsJSON = [PlacementJSONHandler convertPlacementsIntoPlacementsJSON:panel.placements];
        if (placementsJSON.count > 0)
            [panel setValue:placementsJSON forKey:@"placements"];
    }
    if (panel.annotations != nil){
        NSArray* annotationsJSON = [AnnotationJSONHandler convertAnnotationsIntoAnnotationsJSON:panel.annotations];
        if (annotationsJSON.count > 0)
            [panel setValue:annotationsJSON forKey:@"annotations"];
    }
    return paneldict;
}

@end
