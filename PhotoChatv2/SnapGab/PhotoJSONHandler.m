//
//  PhotoJSONHandler.m
//  scaleView
//
//  Created by horizon on 28/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "PhotoJSONHandler.h"
#import "NSData+Base64.h"


@implementation PhotoJSONHandler

+(NSDictionary*)convertPhotoIntoPhotoJSON:(Photo*)photo{
    NSMutableDictionary *photodict = [[NSMutableDictionary alloc] init];
    if (photo.photoId > 0)
        [photodict setValue:[[NSNumber alloc] initWithInt:photo.photoId] forKey:@"photo_id"];
    if (photo.description != nil)
        [photodict setValue:photo.description forKey:@"description"];
    if (photo.width > 0)
        [photodict setValue:[[NSNumber alloc] initWithFloat:photo.width] forKey:@"width"];
    if (photo.height > 0)
        [photodict setValue:[[NSNumber alloc] initWithFloat:photo.height] forKey:@"height"];
    if (photo.imageURL != nil)
        [photodict setValue:photo.imageURL forKey:@"image_url"];
    if (photo.thumbURL != nil)
        [photodict setValue:photo.thumbURL forKey:@"thumb_url"];
    if (photo.image != nil){
        NSData* imageData = UIImageJPEGRepresentation(photo.image, 1.0);
        [photodict setValue:[imageData base64EncodedString] forKey:@"blob"];
        //Added only due to API. Should be removed as it is unncessary.
        if (photo.name != nil){
            [photodict setValue:photo.name forKey:@"name"];
        }
    }
    return photodict;
}
@end
