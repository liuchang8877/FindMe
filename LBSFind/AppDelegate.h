//
//  AppDelegate.h
//  LBSFind
//
//  Created by liu on 4/11/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAMapKit.h"

@class ViewController;
@class MXSMapListViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate,MAMapViewDelegate>
{
    MXSMapListViewController *mapListController;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
