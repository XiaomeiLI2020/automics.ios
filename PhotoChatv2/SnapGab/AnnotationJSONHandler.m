//
//  AnnotationHandler.m
//  scaleView
//
//  Created by horizon on 21/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "AnnotationJSONHandler.h"
#import "DataValidator.h"

@implementation AnnotationJSONHandler

+(Annotation*)getAnnotationFromAnnotationJSON:(NSDictionary*)annotationJSON{
    Annotation *annotation = [[Annotation alloc] init];
    
    if ([annotationJSON valueForKey:@"bubble_style"] != nil){
        NSString* bubbleStyle = [DataValidator checkKeyValueForNull:[annotationJSON valueForKey:@"bubble_style"]];
        if (bubbleStyle != nil)
            annotation.bubbleStyle = [bubbleStyle integerValue];
    }
    
    if ([annotationJSON valueForKey:@"foptions"] != nil){
        NSString* formattingOptions = [DataValidator checkKeyValueForNull:[annotationJSON valueForKey:@"foptions"]];
        if (formattingOptions != nil)
            annotation.formattingOptions = formattingOptions;
    }
    
    if ([annotationJSON valueForKey:@"id"] != nil){
        NSString* annotationId = [DataValidator checkKeyValueForNull:[annotationJSON valueForKey:@"id"]];
        if (annotationId != nil)
            annotation.annotationId = [annotationId integerValue];
    }
    
    if ([annotationJSON valueForKey:@"text"] != nil){
        NSString* text = [DataValidator checkKeyValueForNull:[annotationJSON valueForKey:@"text"]];
        if (text != nil)
            annotation.text = text;
    }
    
    if ([annotationJSON valueForKey:@"xoff"] != nil){
        NSString* xOffset = [DataValidator checkKeyValueForNull:[annotationJSON valueForKey:@"xoff"]];
        if (xOffset != nil)
            annotation.xOffset = [xOffset floatValue];
    }
    
    if ([annotationJSON valueForKey:@"yoff"] != nil){
        NSString* yOffset = [DataValidator checkKeyValueForNull:[annotationJSON valueForKey:@"yoff"]];
        if (yOffset != nil)
            annotation.yOffset = [yOffset floatValue];
    }
    return annotation;
}

+(NSArray*)getAnnotationsFromAnnotationsJSON:(NSArray*)annotationsJSON{
    NSMutableArray* annotations = [[NSMutableArray alloc] initWithCapacity:annotationsJSON.count];
    for (NSDictionary *annotationdict in annotationsJSON){
        Annotation *annotation = [self getAnnotationFromAnnotationJSON:annotationdict];
        [annotations addObject:annotation];
    }
    return annotations;
}


@end
