//
//  GroupLoader.h
//  PhotoChat
//
//  Created by Umar Rashid on 05/03/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "DataLoader.h"
#import "Group.h"

@protocol GroupLoaderDelegate;

@interface GroupLoader : DataLoader

-(void)submitRequestGetGroups;

@end

@protocol GroupLoaderDelegate
@optional
-(void)GroupLoader:(GroupLoader*)groupLoader didLoadGroups:(NSArray*)groups;
-(void)GroupLoader:(GroupLoader*)groupLoader didFailWithError:(NSError*)errors;
@end