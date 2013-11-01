//
//  AutomicsEngine.m
//  PhotoChat
//
//  Created by Umar Rashid on 04/04/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "AutomicsEngine.h"
#import "OfflineSupport.h"

@implementation AutomicsEngine


-(MKNetworkOperation*) postData:(NSURLRequest*)urlRequest
                 completionHandler:(IDBlock) completionBlock
                      errorHandler:(MKNKErrorBlock) errorBlock
{
    
    MKNetworkOperation *op = [self operationWithURLRequest:urlRequest httpMethod:@"POST"];
    
    // setFreezable uploads your images after connection is restored!
    [op setFreezable:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        /*
        NSString *xmlString = [completedOperation responseString];
        
        DLog(@"%@", xmlString);
        completionBlock(xmlString);
         */
    }
                errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
                    
                    //errorBlock(error);
                }];
    
    //[self enqueueOperation:op];
 
    return op;
}

-(MKNetworkOperation*) postData:(NSURLRequest*)urlRequest
                panelPlacements:(NSArray*)placements
               panelAnnotations:(NSArray*)annotations
              completionHandler:(IDBlock) completionBlock
                   errorHandler:(MKNKErrorBlock) errorBlock
{
    //DLog(@"");
    MKNetworkOperation *op = [self operationWithPanelUploadRequest:urlRequest panelPlacements:placements panelAnnotations:annotations httpMethod:@"post"];
    // setFreezable uploads your images after connection is restored!
    [op setFreezable:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        /*
         NSString *xmlString = [completedOperation responseString];
         
         DLog(@"%@", xmlString);
         completionBlock(xmlString);
         */
    }
                errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
                    
                    //errorBlock(error);
                }];
    
    //[self enqueueOperation:op];
    
    return op;
}


-(MKNetworkOperation*) uploadData:(NSString*)urlRequest
                 params:(NSDictionary*)dict
                 completionHandler:(IDBlock) completionBlock
                      errorHandler:(MKNKErrorBlock) errorBlock
{

    MKNetworkOperation *op = [self operationWithURLString:urlRequest params:dict httpMethod:@"POST"];
    
    // setFreezable uploads your images after connection is restored!
    [op setFreezable:YES];
    
    [op addCompletionHandler:^(MKNetworkOperation* completedOperation) {
        
        NSString *xmlString = [completedOperation responseString];
        
        //DLog(@"%@", xmlString);
        completionBlock(xmlString);
    }
                errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
                    
                    errorBlock(error);
                }];
    
    //[self enqueueOperation:op];
    return op;

}

@end
