//
//  EditBubblesViewController.h
//  PhotoChat
//
//  Created by Duncan Rowland on 29/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectBubbleStyleViewController.h"

@interface EditBubblesViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, SelectBubbleStyleDelegateProtocol>
{
    BOOL newMedia;
}

- (IBAction)useCameraPressed;
- (IBAction)useCameraRollPressed;
- (IBAction)pressedClose;

@property IBOutlet UIImageView* imageView;
@property NSURL* url;
@property BOOL startWithCamera;

@end
