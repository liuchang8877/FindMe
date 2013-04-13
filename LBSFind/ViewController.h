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

@interface ViewController : BaseSearchViewController<MAMapViewDelegate>
{
    MAMapView *mapView;

    int delteTarg;

}

@property (nonatomic, strong) MAMapView *mapView;
@end
