//
//  BaseSearchViewController.h
//  Category_demo
//
//  Created by songjian on 13-3-22.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "BaseMapViewController.h"
#import "MASearchKit.h"

#define SearchKey @"78990a4c7a287711bc100e2e2a40c4aa"

@interface BaseSearchViewController : BaseMapViewController<MASearchDelegate>

@property (nonatomic, strong) MASearch *search;

@end
