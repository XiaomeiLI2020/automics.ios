//
//  ComicNameViewController.m
//  PhotoChat
//
//  Created by Umar Rashid on 04/07/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "ComicNameViewController.h"
#import "ComicAddViewController.h"

@interface ComicNameViewController ()

@end

@implementation ComicNameViewController

@synthesize comicName;

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
    
    [self setComicTextField:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelPressed:(id)sender {
    
    comicName = self.comicTextField.text;
    //if(groupName!=nil && ![groupName isEqualToString:@""])
    {
        self.comicTextField.text = nil;
        
        /*
         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
         ThemeViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ThemeViewController"];
         [self presentViewController:viewController animated:YES completion:nil];
         */
    }

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
