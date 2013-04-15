//
//  tool.m
//  BaiduMapAddCustomBubble
//
//  Created by liu on 4/9/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import "tool.h"
#import "Reachability.h"
#import "allConfig.h"
#import "DataModel.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"

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

#pragma mark http for map info
+ (void)setTheLocation:(userLocation *)myLocation
{
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=sendloc&tel=%@&longi=%@&lati=%@",URL_IP,URL_PORT,myLocation.tel,myLocation.x,myLocation.y];
    NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *myRequest;
    NSLog(@"setTheLocation---url:%@",url);
    if ([self checkNet])
    {
        NSLog(@"setTheLocation---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
        
    } else {
        
        NSLog(@"setTheLocation---net is NOT ok");
        [self checkNetAlter];
    }
}

+ (void)userLocationRequestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    //NSData *responseData = [request responseData];
    
    NSString *responseString=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    
    NSLog(@"userLocationRequestFinished---responseString:%@",responseString);
    
//    SBJsonParser * parser = [[SBJsonParser alloc] init];
//    NSError * error = nil;
//    NSMutableDictionary *jsonDic = [parser objectWithString:responseString error:&error];
//    
//    NSMutableDictionary * dicRetInfo = [jsonDic objectForKey:@"ret"];

}


+ (void)userLocationRequestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"userLocationRequestFailed---error:%@",error);
    [self checkNetAlter];
}


@end
