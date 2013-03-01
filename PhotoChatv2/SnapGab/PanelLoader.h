//
//  PanelLoader.h
//  PhotoChat
//
//  Created by Shakir Ali on 20/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "DataLoader.h"
#import "Panel.h"

@protocol PanelLoaderDelegate;

@interface PanelLoader : DataLoader

@property (weak) id<PanelLoaderDelegate> delegate;
-(void)submitRequestGetPanelsForGroup:(int)groupId;
-(void)submitRequestGetPanelWithId:(int)panelId;
-(void)submitRequestPostPanel:(Panel*)panel;

@end


@protocol PanelLoaderDelegate<NSURLConnectionDataDelegate>
@optional
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error;
-(void)PanelLoader:(PanelLoader *)loader didLoadPanels:(NSArray*)panels;
-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel*)panel;
-(void)PanelLoader:(PanelLoader *)loader didSavePanel:(Panel*)panel;
@end
