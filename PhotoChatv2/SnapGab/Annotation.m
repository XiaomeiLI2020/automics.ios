//
//  Annotation.m
//  PhotoChat
//
//  Created by Shakir Ali on 20/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation
@synthesize annotationId;
@synthesize text;
@synthesize bubbleStyle;
@synthesize formattingOptions;
@synthesize xOffset;
@synthesize yOffset;



- (void) encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInteger:annotationId forKey:@"annotationId"];
    [encoder encodeObject:text forKey:@"text"];
    [encoder encodeInteger:bubbleStyle forKey:@"bubbleStyle"];
    [encoder encodeFloat:xOffset forKey:@"xOffset"];
    [encoder encodeFloat:yOffset forKey:@"yOffset"];
    [encoder encodeObject:formattingOptions forKey:@"formattingOptions"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        
        self.annotationId = [decoder decodeIntegerForKey:@"annotationId"];
        //self.annotationId = [decoder decodeObjectForKey:@"annotationId"];
        self.text = [decoder decodeObjectForKey:@"text"];
        //self.bubbleStyle = [decoder decodeObjectForKey:@"bubbleStyle"];
        self.bubbleStyle = [decoder decodeIntegerForKey:@"bubbleStyle"];
        self.xOffset = [decoder decodeFloatForKey:@"xOffset"];
        self.yOffset = [decoder decodeFloatForKey:@"yOffset"];
        self.formattingOptions = [decoder decodeObjectForKey:@"formattingOptions"];
    }
    return self;
}



@end
