//
//  AnnotationHandler.h
//  PhotoChat
//
//  Created by Shakir Ali on 21/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Annotation.h"

@interface AnnotationJSONHandler : NSObject

+(Annotation*)getAnnotationFromAnnotationJSON:(NSDictionary*)annotationJSON;
+(NSArray*)getAnnotationsFromAnnotationsJSON:(NSArray*)annotationsJSON;

@end
