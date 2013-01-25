//
//  PhotoPosterViewController.h
//  SnapChat
//
//  Created by Duncan Rowland on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPosterViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) UIImage *image;

- (IBAction)cancelPressed;

@end
