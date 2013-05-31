//
//  OrganisationLoader.h
//  PhotoChat
//
//  Created by Umar Rashid on 24/05/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataLoader.h"
#import "Organisation.h"

@protocol OrganisationLoaderDelegate;

@interface OrganisationLoader : DataLoader

@property (weak) id<OrganisationLoaderDelegate> delegate;
-(void)submitRequestGetOrganisations;
-(void)submitRequestGetOrganisation:(int)organisationId;
-(void)submitRequestGetThemesForOrganisation:(int)organisationId;

@end

@protocol OrganisationLoaderDelegate<NSObject>
@optional
-(void)OrganisationLoader:(OrganisationLoader*)organisationLoader didLoadOrganisations:(NSArray*)organisations;
-(void)OrganisationLoader:(OrganisationLoader*)organisationLoader didLoadOrganisation:(Organisation*)organisation;
-(void)OrganisationLoader:(OrganisationLoader*)organisationLoader didLoadThemesForOrganisation:(Organisation*)organisation;
-(void)OrganisationLoader:(OrganisationLoader*)organisationLoader didFailWithError:(NSError*)errors;

@end
