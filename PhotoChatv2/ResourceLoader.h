//
//  ResourceLoader.h
//  PhotoChat
//
//  Created by Umar Rashid on 26/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "DataLoader.h"
#import "Resource.h"

@protocol ResourceLoaderDelegate;

@interface ResourceLoader : DataLoader
@property id obj;
extern int const kGetThemeResources;
extern int const kGetResource;



//@property int resourceRequestType;

extern int numResources;

@property (weak) id<ResourceLoaderDelegate> delegate;
-(void)submitRequestGetResourcesForTheme:(int)themeId;
-(void)submitRequestGetResourceWithId:(int)resourceId;
-(void)submitRequestGetResourceWithResourceId:(int)resourceId;
+(void)setResourcesDownloaded:(BOOL)resourcesDownloaded;

@end

//@protocol ResourceLoaderDelegate<NSURLConnectionDataDelegate>
@protocol ResourceLoaderDelegate<NSObject>
@optional
-(void)ResourceLoader:(ResourceLoader*)loader didFailWithError:(NSError*)error;
-(void)ResourceLoader:(ResourceLoader*)loader didLoadResources:(NSArray*)resources;
-(void)ResourceLoader:(ResourceLoader*)loader didLoadResources:(NSArray*)resources forObject:(NSObject*)obj;
-(void)ResourceLoader:(ResourceLoader*)loader didLoadResource:(Resource*)resource;
@end