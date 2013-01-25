//
//  AppDelegate.m
//  SnapChat
//
//  Created by Duncan Rowland on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

@synthesize window = _window;

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//{
//    // Override point for customization after application launch.
//    return YES;
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//	self.window.rootViewController = self.viewController;
//	[self.window makeKeyAndVisible];
    
    //Shakir - COMMENT THIS FOR SIMULATOR | UNCOMMENT FOR IPHONE DEPLOYMENT
	// Let the device know we want to receive push notifications
	//[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    //Shakir - UNCOMMENT THIS FOR SIMULATOR | COMMENT FOR iPHONE DEPLOYMENT
    //Shakir - FYI: This is a token taken from my own phone (for debugging)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"90db491efc9dc76e5910eaf442092e8c2649f5b9b1257210da431ae4fb3d372e"
              forKey:@"token"];
    [prefs synchronize];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
/* 	 UIAlertView *alert = [[UIAlertView alloc]
     initWithTitle: @"PhotoChat"
     message: @"Image Received"
     delegate: nil
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     [alert show];*/
    //[(MainViewController*)self.window.rootViewController.presentedViewController updateNumImages]; //and if not presented?
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newImageNotification" object:nil];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    NSString* token = [[[NSString stringWithFormat:@"%@", deviceToken] //Strip "<> "
                        componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<> "]]
                       componentsJoinedByString:@"" ];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];    
    [prefs setObject:token forKey:@"token"];
    [prefs synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Failed to get token, error:"
                          message: [NSString stringWithFormat:@"%@", error]
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
