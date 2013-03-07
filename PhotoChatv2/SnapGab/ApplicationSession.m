//
//  AutomicsSession.m
//  scaleView
//
//  Created by horizon on 06/03/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "ApplicationSession.h"

@implementation ApplicationSession

static NSMutableString* sessionToken;

+(NSString*)getSessionToken{
    return [sessionToken copy];
}

+(void)setSessionToken:(NSString*)token{
    if (sessionToken == nil){
        sessionToken = [[NSMutableString alloc] init];
    }
    [sessionToken setString:token];
}

@end
