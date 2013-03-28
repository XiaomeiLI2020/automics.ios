//
//  PhotoJSONHandler.m
//  scaleView
//
//  Created by horizon on 28/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "PhotoJSONHandler.h"
#import "NSData+Base64.h"
#import "DataValidator.h"


@implementation PhotoJSONHandler

NSString* ID = @"id";
NSString* DESC = @"description";
NSString* WIDTH = @"width";
NSString* HEIGHT = @"height";
NSString* IMAGE_URL = @"image_url";
NSString* THUMB_URL = @"thumb_url";
NSString* NAME = @"name";
NSString* BLOB = @"blob";


+(NSArray*)convertPhotosJSONArrayIntoPhotos:(NSArray*)photosJSON{
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:photosJSON.count];
    for (NSDictionary *obj in photosJSON){
        Photo *photo = [PhotoJSONHandler convertPhotoJSONIntoPhoto:obj];
        [photos addObject:photo];
    }
    return photos;
}

+(NSDictionary*)convertPhotoIntoPhotoJSON:(Photo*)photo{
    NSMutableDictionary *photodict = [[NSMutableDictionary alloc] init];
    if (photo.photoId > 0)
        [photodict setValue:[[NSNumber alloc] initWithInt:photo.photoId] forKey:ID];
    if (photo.description != nil)
        [photodict setValue:photo.description forKey:DESC];
    if (photo.width > 0)
        [photodict setValue:[[NSNumber alloc] initWithFloat:photo.width] forKey:WIDTH];
    if (photo.height > 0)
        [photodict setValue:[[NSNumber alloc] initWithFloat:photo.height] forKey:HEIGHT];
    if (photo.imageURL != nil)
        [photodict setValue:photo.imageURL forKey:IMAGE_URL];
    if (photo.thumbURL != nil)
        [photodict setValue:photo.thumbURL forKey:THUMB_URL];
    if (photo.image != nil){
        NSData* imageData = UIImageJPEGRepresentation(photo.image, 1.0);
        [photodict setValue:[imageData base64EncodedString] forKey:BLOB];
        //Added only due to API. Should be removed as it is unncessary.
        if (photo.name != nil){
            [photodict setValue:photo.name forKey:NAME];
        }
    }
    return photodict;
}

+(Photo*)convertPhotoJSONIntoPhoto:(NSDictionary*)photodict{
    Photo *photo = [[Photo alloc] init];
    //photo id.
    if ([photodict valueForKey:ID] != nil){
        NSNumber *photoId = [DataValidator checkKeyValueForNull:[photodict valueForKey:ID]];
        if (photoId != nil){
            photo.photoId = [photoId intValue];
        }
    }
    if ([photodict valueForKey:DESC] != nil){
        photo.description= [DataValidator checkKeyValueForNull:[photodict valueForKey:DESC]];
    }
    if ([photodict valueForKey:WIDTH] != nil){
        NSNumber *width = [DataValidator checkKeyValueForNull:[photodict valueForKey:WIDTH]];
        if (width != nil)
            photo.width = [width floatValue];
    }
    if ([photodict valueForKey:HEIGHT] != nil){
        NSNumber *height = [DataValidator checkKeyValueForNull:[photodict valueForKey:HEIGHT]];
        if (height != nil)
            photo.height = [height floatValue];
    }
    if ([photodict valueForKey:IMAGE_URL] != nil){
        photo.imageURL = [DataValidator checkKeyValueForNull:[photodict valueForKey:IMAGE_URL]];
    }
    if ([photodict valueForKey:THUMB_URL] != nil){
        photo.thumbURL = [DataValidator checkKeyValueForNull:[photodict valueForKey:THUMB_URL]];
    }
    return photo;
}

@end
