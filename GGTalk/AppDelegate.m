//
//  AppDelegate.m
//  GGTalk
//
//  Created by lee yee chuan on 3/7/14.
//  Copyright (c) 2014 lee yee chuan. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate
BOOL enteredBG = NO;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:@"Wp6jZKx6pgMSSDc6A7V93mgHMArjt2bVRG9P4Oy8"
                  clientKey:@"OdmfX5q9cQM7AI19glsTXsCaYu87pvXj8njq7frq"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    return YES;
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
    enteredBG = YES;
    ViewController* vc = (id)self.window.rootViewController;
    [vc applicationDidEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    ViewController* vc = (id)self.window.rootViewController;
    if(enteredBG){
        [vc syncBeacons:@{@"file":@"data", @"fileType":@"json"}];
        
        //NSLog(@"applicationDidBecomeActive from BG");
        
        //[[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        //NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:1024*1024 diskCapacity:1024*1024*4 diskPath:nil];
        //[NSURLCache setSharedURLCache:sharedCache];
    }
    [vc applicationDidBecomeActive];
    enteredBG = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
