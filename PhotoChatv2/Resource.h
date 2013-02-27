//
//  Resource.h
//  PhotoChat
//
//  Created by Umar Rashid on 26/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Resource : NSObject

@property int resourceId;
@property NSString* type;
@property NSString* imageURL;
@property NSString* thumbURL;
@property NSString* text;

@end
