//
//  PhotoJSONHandler.h
//  scaleView
//
//  Created by horizon on 28/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "JSONHandler.h"
#import "Photo.h"

@interface PhotoJSONHandler : JSONHandler
+(NSDictionary*)convertPhotoIntoPhotoJSON:(Photo*)photo;
+(Photo*)convertPhotoJSONIntoPhoto:(NSDictionary*)photodict;
+(NSArray*)convertPhotosJSONArrayIntoPhotos:(NSArray*)photosJSON;
@end
