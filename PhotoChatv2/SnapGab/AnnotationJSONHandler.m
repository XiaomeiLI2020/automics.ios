//
//  AnnotationHandler.m
//  PhotoChat
//
//  Created by Shakir Ali on 21/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "AnnotationJSONHandler.h"
#import "DataValidator.h"

@implementation AnnotationJSONHandler

+(Annotation*)getAnnotationFromAnnotationJSON:(NSDictionary*)annotationJSON{
    Annotation *annotation = [[Annotation alloc] init];
    
    if ([annotationJSON valueForKey:@"bubble_style"] != nil){
        NSNumber* bubbleStyle = [DataValidator checkKeyValueForNull:[annotationJSON valueForKey:@"bubble_style"]];
        if (bubbleStyle != nil)
            annotation.bubbleStyle = [bubbleStyle integerValue];
    }
    
    if ([annotationJSON valueForKey:@"foptions"] != nil){
        NSString* formattingOptions = [DataValidator checkKeyValueForNull:[annotationJSON valueForKey:@"foptions"]];
        if (formattingOptions != nil)
            annotation.formattingOptions = formattingOptions;
    }
    
    if ([annotationJSON valueForKey:@"id"] != nil){
        NSNumber* annotationId = [DataValidator checkKeyValueForNull:[annotationJSON valueForKey:@"id"]];
        if (annotationId != nil)
            annotation.annotationId = [annotationId integerValue];
    }
    
    if ([annotationJSON valueForKey:@"text"] != nil){
        NSString* text = [DataValidator checkKeyValueForNull:[annotationJSON valueForKey:@"text"]];
        if (text != nil)
            annotation.text = text;
    }
    
    if ([annotationJSON valueForKey:@"xoff"] != nil){
        NSNumber* xOffset = [DataValidator checkKeyValueForNull:[annotationJSON valueForKey:@"xoff"]];
        if (xOffset != nil)
            annotation.xOffset = [xOffset floatValue];
    }
    
    if ([annotationJSON valueForKey:@"yoff"] != nil){
        NSNumber* yOffset = [DataValidator checkKeyValueForNull:[annotationJSON valueForKey:@"yoff"]];
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

+(NSArray*)convertAnnotationsIntoAnnotationsJSON:(NSArray*)annotations{
    NSMutableArray* annotationsJSON = [[NSMutableArray alloc] initWithCapacity:annotations.count];
    for (Annotation *annotation in annotations){
        NSDictionary *annotationdict = [self convertAnnotationIntoAnnotationJSON:annotation];
        [annotationsJSON addObject:annotationdict];
    }
    return annotationsJSON;
}

+(NSDictionary*)convertAnnotationIntoAnnotationJSON:(Annotation*)annotation{
    NSMutableDictionary *annotationdict;
    if (annotation != nil){
        annotationdict = [[NSMutableDictionary alloc] init];
        [annotationdict setValue:[[NSNumber alloc] initWithInt:annotation.bubbleStyle] forKey:@"bubble_style"];
        if (annotation.formattingOptions != nil)
            [annotationdict setValue:annotation.formattingOptions forKey:@"foptions"];
        if (annotation.annotationId > 0)
            [annotationdict setValue:[[NSNumber alloc] initWithInt:annotation.annotationId] forKey:@"id"];
        if (annotation.text != nil)
            [annotationdict setValue:annotation.text forKey:@"text"];
        [annotationdict setValue:[[NSNumber alloc] initWithFloat:annotation.xOffset] forKey:@"xoff"];
        [annotationdict setValue:[[NSNumber alloc] initWithFloat:annotation.yOffset] forKey:@"yoff"];
    }
    return annotationdict;
}


@end
