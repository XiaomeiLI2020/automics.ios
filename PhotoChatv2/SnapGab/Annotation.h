//
//  Annotation.h
//  scaleView
//
//  Created by horizon on 20/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Annotation : NSObject
@property int annotationId;
@property NSString* text;
@property int bubbleStyle;
@property NSString* formattingOptions;
@property CGFloat xOffset;
@property CGFloat yOffset;
@end
