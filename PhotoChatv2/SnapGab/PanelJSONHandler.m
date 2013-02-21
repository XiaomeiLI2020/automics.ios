//
//  PanelJSONHandler.m
//  PhotoChar
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

+(NSArray*)convertPanelsJSONArrayIntoPanels:(NSArray*)panelsJSON{
    NSMutableArray *panels = [[NSMutableArray alloc] initWithCapacity:panelsJSON.count];
    for (NSDictionary *obj in panelsJSON){
        Panel *panel = [PanelJSONHandler convertPanelJSONDictIntoPanel:obj];
        [panels addObject:panel];
    }
    return panels;
}

@end
