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

extern int const kGetGroupPanels;
extern int const kGetPanel;
extern int const kPostPanel;

@property (weak) id<PanelLoaderDelegate> delegate;
-(void)submitRequestGetPanelsForGroup:(int)groupId;
-(void)submitRequestGetPanelWithId:(int)panelId;
-(void)submitRequestPostPanel:(Panel*)panel;

@end


@protocol PanelLoaderDelegate<NSObject>
@optional
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error;
-(void)PanelLoader:(PanelLoader *)loader didLoadPanels:(NSArray*)panels;
-(void)PanelLoader:(PanelLoader *)loader didLoadPanel:(Panel*)panel;
-(void)PanelLoader:(PanelLoader *)loader didSavePanel:(NSString*)response;
@end
