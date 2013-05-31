//
//  OrganisationJSONHandler.h
//  PhotoChat
//
//  Created by Umar Rashid on 24/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Organisation.h"
#import "JSONHandler.h"

@interface OrganisationJSONHandler : JSONHandler

+(Organisation*)convertOrganisationJSONDictIntoOrganisation:(NSDictionary*)organisationJSON;
+(NSArray*)convertOrganisationsJSONIntoOrganisations:(NSArray*)organisationsJSON;
+(NSDictionary*)convertOrganisationIntoOrganisationJSON:(Organisation*)organisation;

@end
