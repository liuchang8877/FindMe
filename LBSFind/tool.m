//
//  tool.m
//  BaiduMapAddCustomBubble
//
//  Created by liu on 4/9/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import "tool.h"
#import "Reachability.h"

@implementation tool

#pragma  mark CHECK NETWORK
//check the network and show the alter when net is not ok
+ (BOOL)checkNetAlter
{
    Reachability *netStatus=[Reachability reachabilityWithHostName:@"www.baidu.com"];
    
	if ([netStatus currentReachabilityStatus] == NotReachable)
    {
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                      message:@"网络不通，请测网络！"
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"确定",nil];
		[alert show];
		return NO;
	}
	return YES;
}

//check the  network
+ (BOOL)checkNet
{
    Reachability *netStatus=[Reachability reachabilityWithHostName:@"www.baidu.com"];
    
	if ([netStatus currentReachabilityStatus] == NotReachable)
    {
		return NO;
	}
	return YES;
}


@end
