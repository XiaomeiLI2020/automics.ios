//
//  Group.h
//  PhotoChat
//
//  Created by Shakir Ali on 05/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Theme.h"

@interface Group : NSObject

@property int groupId;
@property NSString* name;
@property NSString* hashId;
@property NSDate *createdAt;
@property NSDate *updatedAt;
@property int organisationId;
@property int themeId;

@end
