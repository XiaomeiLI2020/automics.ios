//
//  APIWrapper.m
//  PhotoChat
//
//  Created by Shakir Ali on 15/02/2013.
//  Copyright (c) 2013 Horizon. All rights reserved.
//

#import "APIWrapper.h"
#import "APIConstant.h"

@implementation APIWrapper

+(NSString*)getURLForGetPanels{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL,kAPIURL,kPanelURL];
}

+(NSString*)getURLForGetPanelWithId:(int)panelId{
    NSString* inputId = [NSString stringWithFormat:@"%d", panelId];
    return [NSString stringWithFormat:@"%@/%@/%@/%@", kBaseURL,kAPIURL,kPanelURL,inputId];
}

+(NSString*)getAbsoluteURLUsingPanelImageRelativePath:(NSString*)imageURL{
    return [NSString stringWithFormat:@"%@%@", kBaseURL, imageURL];
}

@end
