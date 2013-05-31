//
//  User.h
//  PhotoChat
//
//  Created by Umar Rashid on 05/03/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"
#import "Group.h"

@interface User : NSObject

@property int userId;
@property NSString* email;
@property NSString* password;
@property Session* currentSession;
@property NSString* groupHashId;
@property Group* currentGroup;

@end
