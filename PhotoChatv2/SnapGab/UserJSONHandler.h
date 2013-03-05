//
//  UserJSONHandler.h
//  PhotoChat
//
//  Created by Umar Rashid on 05/03/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserJSONHandler : NSObject

+(User*)getUserFromUserJSON:(NSDictionary*)userJSON;
+(NSDictionary*)convertUserIntoUserJSON:(User*)user;

@end
