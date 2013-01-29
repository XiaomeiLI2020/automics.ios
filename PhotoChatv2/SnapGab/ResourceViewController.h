//
//  ResourceViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 17/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ResourceDelegateProtocol
- (void)addResourceWithStyle:(int)styleId;
@end

@interface ResourceViewController : UIViewController{
     id<ResourceDelegateProtocol> delegate;
}

@property id<ResourceDelegateProtocol> delegate;


- (IBAction)cancelPressed:(id)sender;
- (IBAction)selectResource:(id)sender;


@end
