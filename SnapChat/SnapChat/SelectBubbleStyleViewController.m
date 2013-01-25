//
//  SelectBubbleStyleViewController.m
//  PhotoChat
//
//  Created by Duncan Rowland on 01/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectBubbleStyleViewController.h"

@interface SelectBubbleStyleViewController ()

@end

@implementation SelectBubbleStyleViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)styleSelectedPressed:(id)sender
{
    UIButton* styleButton = (UIButton*)sender;    
    [self.delegate addBubbleWithStyle:styleButton.tag];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelPressed
{
    [self dismissModalViewControllerAnimated:YES];      
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
