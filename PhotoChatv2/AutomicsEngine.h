//
//  AutomicsEngine.h
//  PhotoChat
//
//  Created by Umar Rashid on 04/04/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

typedef void (^IDBlock)(id object);

#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"

//@protocol AutomicsEngineDelegate;

@interface AutomicsEngine : MKNetworkEngine


//@property (weak) id<AutomicsEngineDelegate> delegate;
-(MKNetworkOperation*) postData:(NSURLRequest*)urlRequest
                 completionHandler:(IDBlock) completionBlock
                      errorHandler:(MKNKErrorBlock) errorBlock;

-(MKNetworkOperation*) uploadData:(NSString*)urlRequest
                            params:(NSDictionary*)dict
                 completionHandler:(IDBlock) completionBlock
                      errorHandler:(MKNKErrorBlock) errorBlock;

@end

/*
@protocol AutomicsEngineDelegate<NSObject>
@optional
-(void)AutomicsEngine:(AutomicsEngine*)automicsEngine didFreezeOperation:(NSString*)responseString;
@end

*/