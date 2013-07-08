//
//  ComicNameViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 04/07/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComicNameViewController : UIViewController
<UITextFieldDelegate>

- (IBAction)cancelPressed:(id)sender;
- (IBAction)confirmPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *comicTextField;


@property NSString* comicName;

@end
