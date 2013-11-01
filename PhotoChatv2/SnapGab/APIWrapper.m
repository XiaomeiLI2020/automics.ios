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
    return [NSString stringWithFormat:@"%@/%@/%@?sid=%i", kBaseURL,kAPIURL,kPanelURL, [APIWrapper genRandomID]];
}

+(NSString*)getURLForGetPanelWithId:(int)panelId{
    NSString* inputId = [NSString stringWithFormat:@"%d", panelId];
    return [NSString stringWithFormat:@"%@/%@/%@/%@?sid=%i", kBaseURL,kAPIURL,kPanelURL,inputId, [APIWrapper genRandomID]];
}

+(NSString*)getURLForPostNotification{
        return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL,kAPIURL,kNotificationURL];
}

+(NSString*)getURLForPostPanel{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL,kAPIURL,kPanelURL];
}

+(NSString*)getURLForPostPhoto{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL,kAPIURL,kPhotoURL];
}

+(NSString*)getURLForGetPhotoWithId:(int)photoId{
    NSString* inputId = [NSString stringWithFormat:@"%d", photoId];
    return [NSString stringWithFormat:@"%@/%@/%@/%@?sid=%i", kBaseURL,kAPIURL,kPhotoURL,inputId, [APIWrapper genRandomID]];
}

+(NSString*)getAbsoluteURLUsingImageRelativePath:(NSString*)imageURL{
    return [NSString stringWithFormat:@"%@%@", kBaseURL, imageURL];
}

+(NSString*)getURLForGetResourcesWithTheme:(int)themeId{
    NSString* inputId = [NSString stringWithFormat:@"%d", themeId];
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@?sid=%i", kBaseURL,kAPIURL,kThemeURL,inputId, kResourceURL, [APIWrapper genRandomID]];
}

+(NSString*)getURLForGetResourceWithResourceId:(int)resourceId{
    NSString* inputId = [NSString stringWithFormat:@"%d", resourceId];
    return [NSString stringWithFormat:@"%@/%@/%@/%@", kBaseURL,kAPIURL,kResourceURL,inputId];
}

+(NSString*)getURLForGetResourceWithId:(int)resourceId{
    NSString* inputId = [NSString stringWithFormat:@"%d", resourceId];
    return [NSString stringWithFormat:@"%@/%@/%@/%@", kBaseURL,kAPIURL,kResourceURL,inputId];
}


+(NSString*)getURLForGetAnnotations{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL,kAPIURL,kAnnotationURL];
}

+(NSString*)getURLForGetAnnotationWithId:(int)annotationId{
    NSString* inputId = [NSString stringWithFormat:@"%d", annotationId];
    return [NSString stringWithFormat:@"%@/%@/%@/%@", kBaseURL,kAPIURL,kAnnotationURL,inputId];
}

+(NSString*)getURLForGetComics{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL, kAPIURL, kComicURL];
}

+(NSString*)getURLForGetComicWithId:(int)comicId{
    NSString* inputId = [NSString stringWithFormat:@"%d", comicId];
    return [NSString stringWithFormat:@"%@/%@/%@/%@?sid=%i", kBaseURL,kAPIURL,kComicURL,inputId, [APIWrapper genRandomID]];
}

+(NSString*)getURLForPostLogin{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL, kAPIURL, kLoginURL];
}

+(NSString*)getURLForGetGroups{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL, kAPIURL, kGroupsURL];
}

+(NSString*)getURLForGetGroup{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL, kAPIURL, kGroupURL];
}

+(NSString*)getURLForGetGroup:(NSString*)hashId{
    return [NSString stringWithFormat:@"%@/%@/%@/%@", kBaseURL, kAPIURL, kGroupURL, hashId];
}

+(NSString*)getURLForJoinGroupWithHashId:(NSString*)hashId{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL, kJoinGroupURL, hashId];
}

+(NSString*)getURLForPostGroupMembership{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL, kAPIURL, kMembershipURL];
}

+(NSString*)getURLForGetPhotosForGroup:(NSString*)groupHashId{
    return [NSString stringWithFormat:@"%@/%@/%@",[self getURLForGetGroup], groupHashId, kPhotoURL];
}

+(NSString*)getURLForGetPhotosForTheme:(int)themeId{
        return [NSString stringWithFormat:@"%@/%i/%@",[self getURLForGetGroup], themeId, kPhotoURL];
}

+(NSString*)getURLForGetOrganisations{
        return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL, kAPIURL, kOrganisationURL];
}

+(NSString*)getURLForGetOrganisation:(int)organisationId{
    //NSString* inputId = [NSString stringWithFormat:@"%d", organisationId];
    return [NSString stringWithFormat:@"%@/%@/%@/%i", kBaseURL, kAPIURL, kOrganisationURL, organisationId];
}

+(NSString*)getURLForGetThemesForOrganisation:(int)organisationId{
    //NSString* inputId = [NSString stringWithFormat:@"%d", organisationId];
    return [NSString stringWithFormat:@"%@/%@/%@/%i/%@", kBaseURL, kAPIURL, kOrganisationURL, organisationId, kThemeURL];
}

+(NSString*)getURLForPostRegister{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL, kAPIURL, kRegisterURL];
}

+(NSString*)getURLForPostUser{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL, kAPIURL, kUserURL];
}

+(NSString*)getURLForPostUserWithId:(int)userId{
        return [NSString stringWithFormat:@"%@/%@/%@/%i", kBaseURL, kAPIURL, kUserURL, userId];
}


+(int) genRandomID{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    return [[NSString stringWithFormat:@"%0.0f", timeStamp] intValue];
}


@end
