//
//  tool.h
//  BaiduMapAddCustomBubble
//
//  Created by liu on 4/9/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class userLocation;
@interface tool : NSObject


+ (BOOL)checkNetAlter;
+ (BOOL)checkNet;
+ (void)waringInfo:(NSString *) msgInfo;
@end
