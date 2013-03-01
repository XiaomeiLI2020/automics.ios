//
//  Photo.h
//  PhotoChat
//
//  Created by Shakir Ali on 28/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "ImageDownloader.h"

@interface Photo : NSObject
@property int photoId;
@property NSString *description;
@property CGFloat width;
@property CGFloat height;
@property NSString *imageURL;
@property UIImage *image;
@property NSString *name;
@property NSString *thumbURL;
@property UIImage *thumb;
@end
