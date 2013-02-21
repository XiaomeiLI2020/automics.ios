//
//  Panel.h
//  PhotoChat
//
//  Created by Shakir Ali on 19/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Placement.h"

@interface Panel : NSObject
@property NSInteger panelId;
@property NSString* imageURL;
@property NSArray* placements;
@property NSArray* annotations;
@end
