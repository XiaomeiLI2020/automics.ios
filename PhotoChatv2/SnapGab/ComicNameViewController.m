//
//  ComicNameViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 04/07/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ComicNameViewController.h"
#import "ComicAddViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ComicNameViewController ()

@end

@implementation ComicNameViewController

@synthesize comicName;
@synthesize cancelButton;
@synthesize confirmButton;
@synthesize comicNameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    [comicNameLabel setFont:[UIFont fontWithName: @"Transit Display" size:24]];
    
    [self.cancelButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.cancelButton.layer.borderWidth=2.0f;
    self.cancelButton.clipsToBounds = YES;
    self.cancelButton.layer.cornerRadius = 10;//half of the width
    [self.cancelButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
    
    [self.confirmButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    self.confirmButton.layer.borderWidth=2.0f;
    self.confirmButton.clipsToBounds = YES;
    self.confirmButton.layer.cornerRadius = 10;//half of the width
    [self.confirmButton.titleLabel setFont:[UIFont fontWithName: @"Transit Display" size:20]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [self setComicTextField:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelPressed:(id)sender {
    
    self.comicTextField.text = nil;

}

- (IBAction)confirmPressed:(id)sender {
    
    comicName = self.comicTextField.text;
    if(comicName!=nil && ![comicName isEqualToString:@""])
    {

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        ComicAddViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ComicAddViewController"];
        //[self presentViewController:viewController animated:YES completion:nil];
        viewController.comicName = comicName;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField*)theTextField {
    //NSLog(@"textFieldShouldReturn");
    if (theTextField == self.comicTextField) {
        [theTextField resignFirstResponder];
    }
    
    return YES;
}

@end
