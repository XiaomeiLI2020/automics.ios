//
//  APIWrapper.h
//  PhotoChat
//
//  Created by Shakir Ali on 15/02/2013.
//  Copyright (c) 2013 Horizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataLoader.h"

@protocol PanelLoaderDelegate;

@interface APIWrapper : DataLoader
@property (weak) id<PanelLoaderDelegate> delegate;
-(void)submitRequestGetPanelsForGroup:(int)groupId;
@end

@protocol PanelLoaderDelegate<NSObject>
@optional
-(void)PanelLoader:(APIWrapper*)loader didFailWithError:(NSError*)error;
-(void)PanelLoader:(APIWrapper *)loader didLoadPanels:(NSArray*)panels;
@end
