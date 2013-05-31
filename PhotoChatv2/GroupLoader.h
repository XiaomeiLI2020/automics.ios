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
@property (weak) id<GroupLoaderDelegate> delegate;
-(void)submitRequestGetGroups;
-(void)submitRequestGetGroupForHashId:(NSString*)groupHashId;
-(void)submitRequestPostGroup:(Group*)group;
-(void)submitRequestPostMembershipForGroup:(Group*)group;
-(void)submitRequestPostThemeForGroup:(NSString*)groupHashId andThemeId:(int)themeId;
@end

@protocol GroupLoaderDelegate<NSObject>
@optional
-(void)GroupLoader:(GroupLoader*)groupLoader didLoadGroup:(Group*)group;
-(void)GroupLoader:(GroupLoader*)groupLoader didSaveGroup:(Group*)group;
-(void)GroupLoader:(GroupLoader*)groupLoader didJoinGroup:(Group*)group;
-(void)GroupLoader:(GroupLoader*)groupLoader didLoadGroups:(NSArray*)groups;
-(void)GroupLoader:(GroupLoader*)groupLoader didFailWithError:(NSError*)errors;
@end