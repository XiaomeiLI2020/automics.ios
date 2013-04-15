//
//  Panel.m
//  PhotoChat
//
//  Created by Shakir Ali on 19/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "Panel.h"
#import "DataValidator.h"

@implementation Panel
@synthesize panelId;
@synthesize photo;
@synthesize placements;
@synthesize annotations;
@synthesize resources;
@synthesize thumbnail;

/*
- (void) encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInteger:panelId forKey:@"panelId"];
    [encoder encodeObject:photo forKey:@"photo"];
    [encoder encodeObject:placements forKey:@"placements"];
    [encoder encodeObject:annotations forKey:@"annotations"];
    [encoder encodeObject:resources forKey:@"resources"];
    [encoder encodeObject:thumbnail forKey:@"thumbnail"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        //self.resourceId = [decoder decodeObjectForKey:@"resourceId"];
        self.panelId = [decoder decodeIntegerForKey:@"panelId"];
        self.photo = [decoder decodeObjectForKey:@"photo"];
        self.placements = [decoder decodeObjectForKey:@"placements"];
        self.annotations = [decoder decodeObjectForKey:@"annotations"];
        self.resources = [decoder decodeObjectForKey:@"resources"];
        self.thumbnail = [decoder decodeObjectForKey:@"thumbnail"];
    }
    return self;
}
*/


@end
