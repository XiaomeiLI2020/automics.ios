//
//  Photo.m
//  PhotoChat
//
//  Created by Shakir Ali on 28/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@synthesize photoId;
@synthesize description;
@synthesize width;
@synthesize height;
@synthesize imageURL;
@synthesize image;
@synthesize name;
@synthesize thumbURL;


/*
- (void) encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInteger:photoId forKey:@"photoId"];
    [encoder encodeObject:description forKey:@"description"];
    [encoder encodeFloat:width forKey:@"width"];
    [encoder encodeFloat:height forKey:@"height"];
    [encoder encodeObject:imageURL forKey:@"imageURL"];
    [encoder encodeObject:thumbURL forKey:@"thumbURL"];
    [encoder encodeObject:name forKey:@"name"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        //self.resourceId = [decoder decodeObjectForKey:@"resourceId"];
        self.photoId = [decoder decodeIntegerForKey:@"photoId"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.thumbURL = [decoder decodeObjectForKey:@"thumbURL"];
        self.width = [decoder decodeFloatForKey:@"width"];
        self.height = [decoder decodeFloatForKey:@"height"];
    }
    return self;
}
*/

@end
