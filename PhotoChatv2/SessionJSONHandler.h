//
//  SessionJSONHandler.h
//  PhotoChat
//
//  Created by Umar Rashid on 05/03/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@interface SessionJSONHandler : NSObject

+(Session*)getSessionFromSessionJSON:(NSDictionary*)annotationJSON;
//+(NSDictionary*)convertSessionIntoSessionJSON:(Session*)session;

@end
