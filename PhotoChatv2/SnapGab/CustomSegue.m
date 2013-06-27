//
//  CustomSegue.m
//  PhotoChat
//
//  Created by Umar Rashid on 26/06/2013.
//  Copyright (c) 2013 Umar Rashid. All rights reserved.
//

#import "CustomSegue.h"
#import "QuartzCore/QuartzCore.h"

@implementation CustomSegue

-(void)perform {
    
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationViewController = (UIViewController*)[self destinationViewController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    //transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    //transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    transition.subtype = kCATransitionFromRight;// kCATransitionFromTop, kCATransitionFromBottom
    
    /*
    NSLog(@"Starting duration...");
    
    [UIView transitionWithView:sourceViewController.navigationController.view duration:0.8
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        
                        NSLog(@"Animation section");
                        
                        [sourceViewController.navigationController pushViewController:destinationViewController animated:YES];
                        
                    }
                    completion:Nil];
    
    NSLog(@"Performance Method Completion");
    */
    
    //[sourceViewController.view.layer addAnimation:transition forKey:@"push-transition"];
    
    //[sourceViewController presentViewController:destinationViewController animated:YES completion:nil];
    
    //[sourceViewController.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    [sourceViewController.navigationController pushViewController:destinationViewController animated:YES];
}
@end