//
//  AppDelegate.m
//  SnapGab
//
//  Created by Umar Rashid on 23/11/2012.
//  Copyright (c) 2012 Umar Rashid. All rights reserved.
//

#import "AppDelegate.h"
#import "APIConstant.h"
#import "Reachability.h"
//#import "DataLoader.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize automicsEngine;
@synthesize databaseQueue;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //NSLog(@"didFinishLaunchingWithOptions");
    /*
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    */
    
    	//self.window.rootViewController = self.viewController;
    	//[self.window makeKeyAndVisible];
    
    //Shakir - COMMENT THIS FOR SIMULATOR | UNCOMMENT FOR IPHONE DEPLOYMENT
	// Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];


    
    //Shakir - UNCOMMENT THIS FOR SIMULATOR | COMMENT FOR iPHONE DEPLOYMENT
    //Shakir - FYI: This is a token taken from my own phone (for debugging)
    /*
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"5898b706101991064817e2a187a6cefa1c5262fcc7e4835e0cabcc350160cca7" forKey:@"token"];
    [prefs synchronize];
    */
    
    
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionary];
    [headerFields setValue:@"application/json" forKey:@"Content-Type"];
    //automicsEngine = [[AutomicsEngine alloc] initWithHostName:kBaseURL];
    automicsEngine = [[AutomicsEngine alloc] initWithHostName:kHostName];
    //automicsEngine = [[AutomicsEngine alloc] initWithHostName:kBaseURL customHeaderFields:headerFields];
    [automicsEngine useCache];
    
    databaseQueue = dispatch_queue_create("automics.database", NULL);
    
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    UINavigationController *navCtrlr = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self.window setRootViewController:navCtrlr];
    //navCtrlr.delegate = self;
    navCtrlr.navigationBarHidden = YES;
    */
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"AppDelegate.didReceiveRemoteNotification");
    /*
    UIAlertView *alert = [[UIAlertView alloc]
     initWithTitle: @"PhotoChat"
     message: @"Image Received"
     delegate: nil
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     [alert show];
    //[(MainViewController*)self.window.rootViewController.presentedViewController updateNumImages]; //and if not presented?
    */
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"newPanelNotification" object:nil];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    NSString* token = [[[NSString stringWithFormat:@"%@", deviceToken] //Strip "<> "
                        componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<> "]]
                       componentsJoinedByString:@"" ];
    
    NSLog(@"AppDelegate.My token is: %@", token);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:token forKey:@"device_token"];
    [prefs synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    /*
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Failed to get token, error:"
                          message: [NSString stringWithFormat:@"%@", error]
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
     */
    
    NSLog(@"AppDelegate. Failed to get token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //NSLog(@"applicationWillResignActive");
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
        //NSLog(@"applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //NSLog(@"applicationWillTerminate");
    [DataLoader closeDatabase];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   
}

@end
