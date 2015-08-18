// Copyright 2012 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//

#import "LocalTiledLayerAppDelegate.h"
#import <ArcGIS/ArcGIS.h>

@implementation LocalTiledLayerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    //获取沙盒路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",paths);
    // Override point for customization after application launch.

    NSError *error;
    NSString *clientID = @"1PrXcsgPqCJQxEen";
    [AGSRuntimeEnvironment setClientID:clientID error:&error];
    
    if (error) {
        NSLog(@"Runtime 错误：%@",error);
    }
    
    AGSLicenseResult result = [[AGSRuntimeEnvironment license] setLicenseCode:@"runtimestandard,101,rud335174422,none,A3C63PJS3M00A1GJH208,165AB9E44CDAA9A5DC30722DB8B26BD4C05A3422873FC8DF607129FF38CB50A70C39BD7D0BD541184C85DE9966C3643C72E4AE489B7CB9DE25106DBFB99A407B265A0CAFCF068EE38176290583A5C7B979036EED1A940C8D84B37DC59777A34F9D8E4C1B85C71A8D4BB1EE2CE5568F641D6950FDC50DFB98139711DB9541848F,FID__e57fd7_14bf1f4310b__3501"];
    
    NSLog(@"AGSLicenseResult result:%d",result);
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}



@end