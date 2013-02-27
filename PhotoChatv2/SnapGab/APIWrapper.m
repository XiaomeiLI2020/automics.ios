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

<<<<<<< HEAD
+(NSString*)getURLForGetResourcesWithTheme:(int)themeId{
    NSString* inputId = [NSString stringWithFormat:@"%d", themeId];
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@", kBaseURL,kAPIURL,kThemeURL,inputId, kResourceURL];
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

=======
+(NSString*)getURLForGetComics{
    return [NSString stringWithFormat:@"%@/%@/%@", kBaseURL, kAPIURL, kComicURL];
}

+(NSString*)getURLForGetComicWithId:(int)comicId{
    NSString* inputId = [NSString stringWithFormat:@"%d", comicId];
    return [NSString stringWithFormat:@"%@/%@/%@/%@", kBaseURL,kAPIURL,kComicURL,inputId];
}
>>>>>>> 23c7bf76c64119f853fbd8b33486de0ad1acf482

@end
