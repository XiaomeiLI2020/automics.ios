//
//  JSONHandler.m
//  scaleView
//
//  Created by horizon on 27/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "JSONHandler.h"

@implementation JSONHandler

+(NSDictionary*)wrapJSONDictWithDataTag:(NSDictionary*)jsondict{
    NSMutableDictionary *datadict = [[NSMutableDictionary alloc] init];
    [datadict setValue:jsondict forKey:@"data"];
    return datadict;
}

@end
