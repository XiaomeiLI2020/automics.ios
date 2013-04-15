//
//  Placement.m
//  PhotoChat
//
//  Created by Shakir Ali on 20/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "Placement.h"

@implementation Placement

@synthesize resourceId;
@synthesize xOffset;
@synthesize yOffset;
@synthesize scale;
@synthesize angle;
@synthesize zIndex;

- (void) encodeWithCoder:(NSCoder *)encoder {

    [encoder encodeInteger:resourceId forKey:@"resourceId"];
    [encoder encodeFloat:xOffset forKey:@"xOffset"];
    [encoder encodeFloat:yOffset forKey:@"yOffset"];
    [encoder encodeFloat:scale forKey:@"scale"];
    [encoder encodeFloat:angle forKey:@"angle"];
    [encoder encodeInteger:zIndex forKey:@"zIndex"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        //self.resourceId = [decoder decodeObjectForKey:@"resourceId"];
        self.resourceId = [decoder decodeIntegerForKey:@"resourceId"];
        self.xOffset = [decoder decodeFloatForKey:@"xOffset"];
        self.yOffset = [decoder decodeFloatForKey:@"yOffset"];
        self.scale = [decoder decodeFloatForKey:@"scale"];
        self.angle = [decoder decodeFloatForKey:@"angle"];
        //self.zIndex = [decoder decodeObjectForKey:@"zIndex"];
        self.zIndex = [decoder decodeIntegerForKey:@"zIndex"];
    }
    return self;
}


@end
