//
//  PlacementJSONHandler.h
//  PhotoChat
//
//  Created by Shakir Ali on 21/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Placement.h"

@interface PlacementJSONHandler : NSObject

+(Placement*)getPlacementFromPlacementJSON:(NSDictionary*)placementJSON;
+(NSArray*)getPlacementsFromPlacementsJSON:(NSArray*)placementsJSON;
+(NSDictionary*)convertPlacementIntoPlacementJSON:(Placement*)placement;
+(NSArray*)convertPlacementsIntoPlacementsJSON:(NSArray*)placements;

@end
