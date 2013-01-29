//
//  SelectBubbleStyleViewController.m
//  SnapGab
//
//  Created by Umar Rashid on 28/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "SelectBubbleStyleViewController.h"
#import "SpeechBubbleView.h"

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

- (void)dealloc {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/
- (IBAction)styleSelectedPressed:(id)sender {
    
    UIButton* styleButton = (UIButton*)sender;
    [self.delegate addBubbleWithStyle:styleButton.tag];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
