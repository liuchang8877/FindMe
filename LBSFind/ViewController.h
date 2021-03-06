//
//  ViewController.h
//  LBSFind
//
//  Created by liu on 4/11/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAMapKit.h"
#import "BaseSearchViewController.h"
#import "ASIHTTPRequest.h"

@interface ViewController : BaseSearchViewController<MAMapViewDelegate,ASIHTTPRequestDelegate>
{
    MAMapView *mapView;

    int delteTarg;

}

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) NSString *functionFlag;
@end
