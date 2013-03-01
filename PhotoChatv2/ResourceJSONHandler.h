//
//  ResourceJSONHandler.h
//  PhotoChat
//
//  Created by Umar Rashid on 26/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"

@interface ResourceJSONHandler : NSObject

+(Resource*)getResourceFromResourceJSON:(NSDictionary*)resourceJSON;
+(NSArray*)getResourcesFromResourcesJSON:(NSArray*)resourcesJSON;

@end
