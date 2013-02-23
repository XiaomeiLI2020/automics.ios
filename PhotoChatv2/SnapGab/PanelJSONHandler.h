//
//  PanelJSONHandler.h
//  PhotoChat
//
//  Created by Shakir Ali on 21/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Panel.h"

@interface PanelJSONHandler : NSObject

+(Panel*)convertPanelJSONDictIntoPanel:(NSDictionary*)panelJSON;
+(NSArray*)convertPanelsJSONArrayIntoPanels:(NSArray*)panelsJSON;
+(NSInteger)countPanels:(id)panelsJSON;

@end
