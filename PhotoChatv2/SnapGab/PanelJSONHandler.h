//
//  PanelJSONHandler.h
//  PhotoChat
//
//  Created by Shakir Ali on 21/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Panel.h"
#import "JSONHandler.h"

@interface PanelJSONHandler : JSONHandler

+(Panel*)convertPanelJSONDictIntoPanel:(NSDictionary*)panelJSON;
+(NSArray*)convertPanelsJSONIntoPanels:(NSArray*)panelsJSON;
+(NSDictionary*)convertPanelIntoPanelJSON:(Panel*)panel;

@end
