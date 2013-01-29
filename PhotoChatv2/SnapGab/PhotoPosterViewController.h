//
//  PhotoPosterViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 11/12/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPosterViewController : UIViewController
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) UIImage *image;

- (IBAction)cancelPressed:(id)sender;

@end
