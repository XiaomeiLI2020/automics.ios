//
//  PlacementJSONHandler.m
//  PhotoChat
//
//  Created by Shakir Ali on 21/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "PlacementJSONHandler.h"
#import "Placement.h"
#import "DataValidator.h"

@implementation PlacementJSONHandler

+(Placement*)getPlacementFromPlacementJSON:(NSDictionary*)placementJSON{
    Placement *placement = [[Placement alloc] init];
    
    if ([placementJSON valueForKey:@"resource_id"] != nil){
        NSNumber* resourceId = [DataValidator checkKeyValueForNull:[placementJSON valueForKey:@"resource_id"]];
        if (resourceId != nil)
            placement.resourceId = [resourceId intValue];
    }
    
    if ([placementJSON valueForKey:@"scale"] != nil){
        NSNumber* scale = [DataValidator checkKeyValueForNull:[placementJSON valueForKey:@"scale"]];
        if (scale != nil)
            placement.scale = [scale floatValue];
    }
    
    if ([placementJSON valueForKey:@"xoff"] != nil){
        NSNumber* xOffset = [DataValidator checkKeyValueForNull:[placementJSON valueForKey:@"xoff"]];
        if (xOffset != nil)
            placement.xOffset = [xOffset floatValue];
    }
    
    if ([placementJSON valueForKey:@"yoff"] != nil){
        NSNumber* yOffset = [DataValidator checkKeyValueForNull:[placementJSON valueForKey:@"yoff"]];
        if (yOffset != nil)
            placement.yOffset = [yOffset floatValue];
    }
    
    if ([placementJSON valueForKey:@"z_index"] != nil){
        NSNumber* zIndex = [DataValidator checkKeyValueForNull:[placementJSON valueForKey:@"z_index"]];
        if (zIndex != nil)
            placement.zIndex = [zIndex intValue];
    }
    
    if ([placementJSON valueForKey:@"angle"] != nil){
        NSNumber* angle = [DataValidator checkKeyValueForNull:[placementJSON valueForKey:@"angle"]];
        if (angle != nil)
            placement.angle = [angle floatValue];
    }

    return placement;
}

+(NSArray*)getPlacementsFromPlacementsJSON:(NSArray*)placementsJSON{
    NSMutableArray* placements = [[NSMutableArray alloc] initWithCapacity:placementsJSON.count];
    for (NSDictionary *placementdict in placementsJSON){
        Placement *placement = [self getPlacementFromPlacementJSON:placementdict];
        [placements addObject:placement];
    }
    return placements;
}

+(NSDictionary*)convertPlacementIntoPlacementJSON:(Placement*)placement{
    NSMutableDictionary* placementdict = [[NSMutableDictionary alloc] init];
    if (placement.resourceId > 0)
    [placementdict setValue:[[NSNumber alloc] initWithInt:placement.resourceId] forKey:@"resource_id"];
    [placementdict setValue:[[NSNumber alloc] initWithFloat:placement.scale] forKey:@"scale"];
    [placementdict setValue:[[NSNumber alloc] initWithFloat:placement.angle] forKey:@"angle"];
    [placementdict setValue:[[NSNumber alloc] initWithFloat:placement.xOffset] forKey:@"xoff"];
    [placementdict setValue:[[NSNumber alloc] initWithFloat:placement.yOffset] forKey:@"yoff"];
    [placementdict setValue:[[NSNumber alloc] initWithInt:placement.zIndex] forKey:@"z_index"];
    return placementdict;
}

+(NSArray*)convertPlacementsIntoPlacementsJSON:(NSArray*)placements{
    NSMutableArray* placementsJSON = [[NSMutableArray alloc] init];
    for (Placement *placement in placements){
        NSDictionary *placementdict = [PlacementJSONHandler convertPlacementIntoPlacementJSON:placement];
        [placementsJSON addObject:placementdict];
    }
    return placementsJSON;
}

@end
