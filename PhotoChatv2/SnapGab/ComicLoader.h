//
//  ComicLoader.h
//  PhotoChat
//
//  Created by Shakir Ali on 22/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "DataLoader.h"
#import "Comic.h"

@protocol ComicLoaderDelegate;

@interface ComicLoader : DataLoader

extern int const kGetGroupComics;
extern int const kGetComic;

@property (weak) id<ComicLoaderDelegate> delegate;
-(void)submitRequestGetComicsForGroup:(int)groupId;
-(void)submitRequestGetComicWithId:(int)comicId;

@end


@protocol ComicLoaderDelegate<NSObject>
@optional
-(void)ComicLoader:(ComicLoader*)loader didFailWithError:(NSError*)error;
-(void)ComicLoader:(ComicLoader*)loader didLoadComics:(NSArray*)comics;
-(void)ComicLoader:(ComicLoader*)loader didLoadComic:(Comic*)comic;
@end
