//
//  AutomicsSession.h
//  scaleView
//
//  Created by horizon on 06/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationSession : NSObject
+(NSString*)getSessionToken;
+(void)setSessionToken:(NSString*)token;
@end
