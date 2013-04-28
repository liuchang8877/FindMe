//
//  AppDelegate.m
//  LBSFind
//
//  Created by liu on 4/11/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MXSMapListViewController.h"
#import "UserLoginViewController.h"
#import "tool.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //set the UIApplication
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
        mapListController = [[MXSMapListViewController alloc] init];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    
    //self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MXSMapListViewController alloc] init]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[UserLoginViewController alloc] init]];

    //self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[LSViewController alloc] init]];
    //self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

////在 MAMapViewDelegate 协议中添加了如下回调函数
//-(NSString*)keyForMap
//{
//    return @"78990a4c7a287711bc100e2e2a40c4aa";
//}
////在 MASearchDelegate  协议中添加了如下回调函数
//-(NSString*)keyForSearch
//{
//    return @"78990a4c7a287711bc100e2e2a40c4aa";
//}

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

#pragma mark ios push
//registe
- (void)application:(UIApplication*)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *strone = [NSString stringWithFormat:@"%@",deviceToken];
    NSLog(@">>>>>>>>>>>>>>>>>>strone:%@",strone);
    
    if ([tool checkNet]) {
        
        NSError *error = nil;
        NSString *str = @"http://218.28.20.140:81/test/zw1/do.php?action=savetoken&devicetoken=%@";
        NSString *strone = [NSString stringWithFormat:@"%@",deviceToken];
        NSString *strtwo = [strone stringByReplacingOccurrencesOfString:@"<" withString:@""];
        strtwo = [strtwo stringByReplacingOccurrencesOfString:@">" withString:@""];
        strtwo = [strtwo stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *urlString = [NSString stringWithFormat:str,strtwo];
        NSURL *urlStr = [NSURL URLWithString:urlString];
        NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken---urlStr:%@",urlStr);
        NSURLRequest *request = [NSURLRequest requestWithURL:urlStr];
        NSData *respone = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (respone == nil) {
            return;
        }
        else
        {
            NSDictionary *deviceDic = [NSJSONSerialization JSONObjectWithData:respone options:NSJSONReadingMutableLeaves error:&error];
            NSDictionary *resultDic = [deviceDic objectForKey:@"ret"];
            NSString *resultStr = [resultDic objectForKey:@"result"];
        }
        
    } else  {
    
        // net is not connected
        [tool checkNetAlter];
    }
}

//registe fail
-(void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"注册失败，无法获取设备ID, 具体错误: %@", error);
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"本设备没有推送功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

//show the info
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@">>>>>>>>>>>>>>>>>>userInfo%@",userInfo);
    
}

@end
