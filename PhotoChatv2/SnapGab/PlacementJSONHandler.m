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
        NSString* resourceId = [DataValidator checkKeyValueForNull:[placementJSON valueForKey:@"resource_id"]];
        if (resourceId != nil)
            placement.resourceId = [resourceId integerValue];
    }
    
    if ([placementJSON valueForKey:@"scale"] != nil){
        NSString* scale = [DataValidator checkKeyValueForNull:[placementJSON valueForKey:@"scale"]];
        if (scale != nil)
            placement.scale = [scale floatValue];
    }
    
    if ([placementJSON valueForKey:@"xoff"] != nil){
        NSString* xOffset = [DataValidator checkKeyValueForNull:[placementJSON valueForKey:@"xoff"]];
        if (xOffset != nil)
            placement.xOffset = [xOffset floatValue];
    }
    
    if ([placementJSON valueForKey:@"yoff"] != nil){
        NSString* yOffset = [DataValidator checkKeyValueForNull:[placementJSON valueForKey:@"yoff"]];
        if (yOffset != nil)
            placement.yOffset = [yOffset floatValue];
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
    [placementdict setValue:[[NSNumber alloc] initWithFloat:placement.xOffset] forKey:@"xoff"];
    [placementdict setValue:[[NSNumber alloc] initWithFloat:placement.yOffset] forKey:@"yoff"];
    return placementdict;
}

@end
