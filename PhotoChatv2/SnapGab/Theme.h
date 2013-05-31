//
//  Theme.h
//  PhotoChat
//
//  Created by Shakir Ali on 11/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Organisation.h"

@interface Theme : NSObject

@property int themeId;
@property NSString *name;
@property Organisation* organisation;
@property NSArray* resources;

@end
