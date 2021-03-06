//
//  PanelLoader.h
//  PhotoChat
//
//  Created by Shakir Ali on 20/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "DataLoader.h"
#import "Panel.h"
#import "SQLiteLoader.h"

@protocol PanelLoaderDelegate;

@interface PanelLoader : DataLoader
@property id obj;
@property (weak) id<PanelLoaderDelegate> delegate;
//-(void)submitRequestGetPanelsForGroup:(int)groupId;
-(void)submitRequestGetPanelsForGroup;
-(void)submitRequestRefreshGetPanelsForGroup;
//-(void)submitRequestRefreshGetPanelsForGroup:(int)oldNmPanels;
-(void)submitRequestGetPanelWithId:(int)panelId;
-(void)submitRequestPostPanel:(Panel*)panel;
-(NSURLRequest*)preparePanelRequestForPostPanel:(Panel*)panel;

@end


@protocol PanelLoaderDelegate<NSURLConnectionDataDelegate>
//@protocol PanelLoaderDelegate<NSObject>
@optional
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error;
-(void)PanelLoader:(PanelLoader*)loader didLoadPanels:(NSArray*)panels;
-(void)PanelLoader:(PanelLoader*)loader didLoadRefreshedPanels:(NSArray*)panels;
-(void)PanelLoader:(PanelLoader*)loader didLoadPanelsLocal:(NSArray*)panels;
-(void)PanelLoader:(PanelLoader*)loader didLoadPanel:(Panel*)panel forObject:(id)obj;
-(void)PanelLoader:(PanelLoader*)loader didLoadPanel:(Panel*)panel;
//-(void)PanelLoader:(PanelLoader *)loader didSavePanel:(Panel*)panel;
-(void)PanelLoader:(PanelLoader *)loader didSavePanel:(NSString*)responseString;
@end
