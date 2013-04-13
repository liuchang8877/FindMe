//
//  BaseMapViewController.m
//  Category_demo
//
//  Created by songjian on 13-3-21.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "BaseMapViewController.h"

@implementation BaseMapViewController
@synthesize mapView = _mapView;

#pragma mark - Utility

- (void)loadMapView
{
    self.mapView.frame = self.view.bounds;
    
    self.mapView.delegate = self;
    
    CLLocationCoordinate2D center = {34.824096,113.563210};
    MACoordinateSpan span = {0.04,0.03};
    MACoordinateRegion region = {center,span};
    [self.mapView setRegion:region animated:NO];
    
    
    [self.view addSubview:self.mapView];
}

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /* Load mapView to view hierarchy. */
    [self loadMapView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /* Reset map view. */
    self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
    
    //self.mapView.rotationDegree = 0.f;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
        
    self.mapView.delegate = nil;
    
    /* Remove from view hierarchy. */
    [self.mapView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
