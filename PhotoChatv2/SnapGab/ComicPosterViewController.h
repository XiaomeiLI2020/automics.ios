//
//  ComicPosterViewController.h
//  PhotoChat
//
//  Created by Umar Rashid on 13/02/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComicPosterViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) UIImage *image;

@property NSMutableArray *comicContents;

- (IBAction)cancelPressed:(id)sender;

@end
