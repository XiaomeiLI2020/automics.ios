//
//  SelectBubbleStyleViewController.h
//  SnapGab
//
//  Created by Umar Rashid on 28/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
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
- (IBAction)cancelPressed:(id)sender;



@end
