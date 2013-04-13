//
//  BaseMapViewController.h
//  Category_demo
//
//  Created by songjian on 13-3-21.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAMapKit.h"

@interface BaseMapViewController : UIViewController<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@end
