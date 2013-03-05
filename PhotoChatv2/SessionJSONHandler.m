//
//  SessionJSONHandler.m
//  PhotoChat
//
//  Created by Umar Rashid on 05/03/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "SessionJSONHandler.h"
#import "DataValidator.h"

@implementation SessionJSONHandler

+(Session*)getSessionFromSessionJSON:(NSDictionary*)sessionJSON
{
    Session *session = [[Session alloc] init];
    
    if ([sessionJSON valueForKey:@"session"] != nil){
        NSString* token = [DataValidator checkKeyValueForNull:[sessionJSON valueForKey:@"session"]];
        if (token != nil)
            session.token = token;
    }
    


    return session;

}


+(NSDictionary*)convertSessionIntoSessionJSON:(Session*)session{
    NSMutableDictionary *sessiondict;
    if (session != nil){
        sessiondict = [[NSMutableDictionary alloc] init];
        if (session.token != nil)
            [sessiondict setValue:session.token forKey:@"session"];
    }
    return sessiondict;
}

@end
