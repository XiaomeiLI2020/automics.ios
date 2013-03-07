//
//  ResourceJSONHandler.m
//  PhotoChat
//
//  Created by Umar Rashid on 26/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ResourceJSONHandler.h"
#import "DataValidator.h"
#import "APIWrapper.h"

@implementation ResourceJSONHandler



+(Resource*)getResourceFromResourceJSON:(NSDictionary*)resourceJSON{
    Resource *resource = [[Resource alloc] init];
    
    if ([resourceJSON valueForKey:@"id"] != nil){
        NSString* resourceId = [DataValidator checkKeyValueForNull:[resourceJSON valueForKey:@"id"]];
        if (resourceId != nil)
            resource.resourceId = [resourceId integerValue];
    }
    
    if ([resourceJSON valueForKey:@"typ"] != nil){
        NSString* type = [DataValidator checkKeyValueForNull:[resourceJSON valueForKey:@"typ"]];
        if (type != nil)
            resource.type = type;
    }

    if ([resourceJSON valueForKey:@"image_url"] != nil){
        NSString* imageURL = [DataValidator checkKeyValueForNull:[resourceJSON valueForKey:@"image_url"]];
        if (imageURL != nil)
        {
            imageURL = [APIWrapper getAbsoluteURLUsingPanelImageRelativePath:imageURL];
            resource.imageURL = imageURL;
        }
    }
    
    if ([resourceJSON valueForKey:@"thumb_url"] != nil){
        NSString* thumbURL = [DataValidator checkKeyValueForNull:[resourceJSON valueForKey:@"thumb_url"]];
        if (thumbURL != nil)
        {
            thumbURL = [APIWrapper getAbsoluteURLUsingPanelImageRelativePath:thumbURL];
            resource.thumbURL = thumbURL;
        }
    }
    
    return resource;
}

+(NSArray*)getResourcesFromResourcesJSON:(NSArray*)resourcesJSON{
    
    NSMutableArray* resources = [[NSMutableArray alloc] initWithCapacity:resourcesJSON.count];
    
    for (NSDictionary *resourcedict in resourcesJSON){

        Resource *resource = [self getResourceFromResourceJSON:resourcedict];
        [resources addObject:resource];
    }
    
    return resources;
}


@end
