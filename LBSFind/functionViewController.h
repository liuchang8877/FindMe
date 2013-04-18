//
//  functionViewController.h
//  LBSFind
//
//  Created by liu on 4/16/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAMapKit.h"
#import "MASearch.h"
#import "BaseMapViewController.h"

@interface functionViewController : BaseMapViewController<UITableViewDataSource,UITableViewDelegate,MAMapViewDelegate,MASearchDelegate>

@end
