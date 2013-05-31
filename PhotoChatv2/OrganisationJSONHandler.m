//
//  OrganisationJSONHandler.m
//  PhotoChat
//
//  Created by Umar Rashid on 24/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "OrganisationJSONHandler.h"
#import "DataValidator.h"
#import "ThemeJSONHandler.h"

@implementation OrganisationJSONHandler

+(Organisation*)convertOrganisationJSONDictIntoOrganisation:(NSDictionary*)organisationJSON{
    Organisation* organisation = [[Organisation alloc] init];
    organisation.organisationId = [(NSString*)[organisationJSON valueForKey:@"id"] integerValue];
    //name dict string object uses NSNull value in json deserilization.
    NSString* name = [organisationJSON objectForKey:@"name"];
    organisation.name = [DataValidator checkKeyValueForNull:name];
    
    if ([organisationJSON valueForKey:@"themes"] != nil){
        NSLog(@"convertOrganisationJSONDictIntoOrganisation.THEMES");
        NSArray* themesArray = [organisationJSON valueForKey:@"themes"];
        if (![themesArray isEqual:[NSNull null]]){
            NSArray *themes = [ThemeJSONHandler getThemesFromThemesJSON:themesArray];
            organisation.themes = themes;
        }
    }

    return organisation;
}
+(NSArray*)convertOrganisationsJSONIntoOrganisations:(NSArray*)organisationsJSON{
    NSMutableArray *organisations = [[NSMutableArray alloc] initWithCapacity:organisationsJSON.count];
    for (NSDictionary *obj in organisationsJSON){
        Organisation *organisation = [OrganisationJSONHandler convertOrganisationJSONDictIntoOrganisation:obj];
        [organisations addObject:organisation];
    }
    return organisations;
}
+(NSDictionary*)convertOrganisationIntoOrganisationJSON:(Organisation*)organisation{
    NSMutableDictionary* organisationDict = [[NSMutableDictionary alloc] init];
    if(organisation.organisationId > 0)
        [organisationDict setValue:[[NSNumber alloc] initWithInt:organisation.organisationId] forKey:@"id"];
    
    if(organisation.name != nil)
    {
        [organisationDict setValue:organisation.name forKey:@"name"];
    }
    return organisationDict;
}

@end
