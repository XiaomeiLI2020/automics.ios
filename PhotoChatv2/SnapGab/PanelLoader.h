//
//  PanelLoader.h
//  scaleView
//
//  Created by horizon on 20/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "DataLoader.h"

@protocol PanelLoaderDelegate;

@interface PanelLoader : DataLoader
@property (weak) id<PanelLoaderDelegate> delegate;
-(void)submitRequestGetPanelsForGroup:(int)groupId;
@end

@protocol PanelLoaderDelegate<NSObject>
@optional
-(void)PanelLoader:(PanelLoader*)loader didFailWithError:(NSError*)error;
-(void)PanelLoader:(PanelLoader *)loader didLoadPanels:(NSArray*)panels;
@end
