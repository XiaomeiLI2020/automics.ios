//
//  DataValidator.m
//  PhotoChat
//
//  Created by Shakir Ali on 21/02/2013.
//  Copyright (c) 2013 horizon. All rights reserved.
//

#import "DataValidator.h"

@implementation DataValidator

+(id)checkKeyValueForNull:(id)value{
    id checkedValue;
    if ([value isEqual:[NSNull null]]){
        checkedValue = nil;
    }else{
        checkedValue = value;
    }
    return checkedValue;
}

@end
