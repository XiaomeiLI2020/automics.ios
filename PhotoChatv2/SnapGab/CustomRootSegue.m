//
//  CustomRootSegue.m
//  PhotoChat
//
//  Created by Umar Rashid on 03/07/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "CustomRootSegue.h"
#import "QuartzCore/QuartzCore.h"

@implementation CustomRootSegue

-(void)perform {
    
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    //UIViewController *destinationViewController = (UIViewController*)[self destinationViewController];
    
    NSArray* viewControllers = sourceViewController.navigationController.viewControllers;
    [sourceViewController.navigationController popToViewController:[viewControllers objectAtIndex:1] animated:YES];
    
    //if(viewControllers!=nil)
    {
        /*
         for(int i=0; i<[viewControllers count]; i++)
         {
         if(destinationViewController==[viewControllers objectAtIndex:i])
         {
         [sourceViewController.navigationController popToViewController:[sourceViewController.navigationController.viewControllers objectAtIndex:1] animated:YES];
         
         }
         }
         */
        
        //end for
        
        //NSLog(@"[viewControllers count]=%i", [viewControllers count]);
        //if([viewControllers count]>=1)
        {
            //[sourceViewController.navigationController popViewControllerAnimated:YES];
            //[sourceViewController.navigationController popToRootViewControllerAnimated:YES];
        }
        
    }
    
    //[sourceViewController.navigationController popToViewController:[sourceViewController.navigationController.viewControllers objectAtIndex:1] animated:YES];
    
    //[sourceViewController.navigationController popViewControllerAnimated:YES];
}


@end
