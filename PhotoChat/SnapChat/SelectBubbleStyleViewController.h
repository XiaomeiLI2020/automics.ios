//
//  SelectBubbleStyleViewController.h
//  PhotoChat
//
//  Created by Duncan Rowland on 01/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SelectBubbleStyleDelegateProtocol
- (void)addBubbleWithStyle:(int)styleId;
@end

@interface SelectBubbleStyleViewController : UIViewController {
    id<SelectBubbleStyleDelegateProtocol> delegate;
}

@property id<SelectBubbleStyleDelegateProtocol> delegate;

- (IBAction)styleSelectedPressed:(id)sender;
- (IBAction)cancelPressed;

@end
