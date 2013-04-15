//
//  ViewController.m
//  LBSFind
//
//  Created by liu on 4/11/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import "ViewController.h"
#import "MAMapKit.h"
#import "tool.h"
#import "DataModel.h"
#define PI 3.1415926
enum{
    OverlayViewControllerOverlayTypeCircle = 0,
    OverlayViewControllerOverlayTypePolyline,
    OverlayViewControllerOverlayTypePolygon
};


@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, strong) NSMutableArray *searchOptions;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureGecognizer;
@property (nonatomic, strong) NSMutableArray *overlays;
@property (nonatomic, strong) NSMutableArray *pointForOverlay;
@property (nonatomic, strong) MARouteSearchOption *searchOption;
@property (nonatomic, strong) MAPolyline *pathPolyline;
@property (nonatomic, strong) NSMutableArray *roadAnnotations;
@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *endAnnotation;

@end

@implementation ViewController
@synthesize mapView;
@synthesize annotations     = _annotations;
@synthesize searchOptions   = _searchOptions;
@synthesize longPressGestureGecognizer = _longPressGestureGecognizer;
@synthesize overlays = _overlays;
@synthesize pointForOverlay = _pointForOverlay;
@synthesize searchOption = _searchOption;
@synthesize pathPolyline = _pathPolyline;
@synthesize roadAnnotations = _roadAnnotations;
@synthesize startAnnotation = _startAnnotation;
@synthesize endAnnotation = _endAnnotation;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initToolBar];
    
    [self initGestures];    
    [self.view addSubview:mapView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utility

- (void)addAnnotationForCoordinate:(CLLocationCoordinate2D)coordinate
{
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title      = @"取消";
    
    [self.annotations addObject:annotation];
    
    [self.pointForOverlay addObject:annotation];

    [self.mapView addAnnotation:annotation];
}

- (void)reverseRequestCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    MAReverseGeocodingSearchOption *searchOption = [[MAReverseGeocodingSearchOption alloc] init];
    
    searchOption.config     = @"SPAS";
    searchOption.multiPoint = @"0";
    searchOption.x          = [NSString stringWithFormat:@"%f", coordinate.longitude];
    searchOption.y          = [NSString stringWithFormat:@"%f", coordinate.latitude];
    
    [self.searchOptions addObject:searchOption];
    
    [self.search reverseGeocodingSearchWithOption:searchOption];
}

- (void)receiveOption:(MAReverseGeocodingSearchOption *)geoCodingSearchOption info:(MAReverseGeocodingInfo *)info
{
    NSUInteger index = [self.searchOptions indexOfObject:geoCodingSearchOption];
    if (index == NSNotFound)
    {
        return;
    }
    
    MAPointAnnotation *annotation = [self.annotations objectAtIndex:index];
    
    NSString *title = [NSString stringWithFormat:@"%@%@%@", info.province.name, info.city.name, info.district.name];
    if ([title length] == 0)
    {
        title = @"None";
    }
    annotation.title = title;
    
    NSString *subTitle = nil;
    if ([info.roads count] != 0)
    {
        subTitle = [((MARoad*)([info.roads objectAtIndex:0])).name stringByAppendingString:@"(附近)"];
    }
    
    annotation.subtitle = subTitle;
}

#pragma mark - Gesture Handle

- (void)longPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[gestureRecognizer locationInView:self.view] toCoordinateFromView:self.view];
        
        [self addAnnotationForCoordinate:coordinate];
        
        //[self reverseRequestCoordinate:coordinate];
    }
}

#pragma mark - MASearchDelegate

-(void)reverseGeocodingSearch:(MAReverseGeocodingSearchOption*)geoCodingSearchOption Result:(MAReverseGeocodingSearchResult*)result
{
    if ([result.resultArray count] == 0)
    {
        NSLog(@"%s, result data is invalid", __func__);
        
        return;
    }
    
    [self receiveOption:geoCodingSearchOption info:[result.resultArray objectAtIndex:0]];
}

#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reverseGeoReuseIndetifier = @"reverseGeoReuseIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reverseGeoReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reverseGeoReuseIndetifier];
            annotationView.animatesDrop              = YES;
            annotationView.draggable                 = YES;
            UIButton *deleteButton  = [UIButton buttonWithType:UIButtonTypeInfoLight];
            deleteButton.tag = delteTarg;
            NSLog(@"delteTarg---%d",delteTarg);
            delteTarg = delteTarg + 1;
            [deleteButton addTarget:self action:@selector(deleteAnn:) forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = deleteButton;
            [self addLine];
        }
        else
        {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

//delte the annotation
- (void) deleteAnn:(id)sender{
    
    if ([sender tag] == [self.annotations count] - 1) {
        MAPointAnnotation *annotation = [self.annotations objectAtIndex:[sender tag]];
        //[self.annotations removeObjectAtIndex:[sender tag]];
        NSLog(@"self.annotations count:%d",[self.annotations count]);
        NSLog(@"self.annotations count:%d -- tag:%d",[self.annotations count],[sender tag]);
        [self.mapView removeAnnotation:annotation];
        [self.annotations removeObjectAtIndex:[sender tag]];
        delteTarg = delteTarg - 1;
        NSLog(@"self.annotations count:%d",[self.annotations count]);
        //remove the overlays line
        [self.mapView removeOverlays:self.overlays];
        
    } else {
        
        NSLog(@"self.annotations count:%d -- tag:%d---",[self.annotations count],[sender tag]);
    }

}
//#pragma mark DID_SELECT_ANN
//- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
//{
//    NSLog(@"didSelectAnnotationView");
//    
//}
//
//- (void)selectAnnotation:(id < MAAnnotation >)annotation animated:(BOOL)animated
//{
//    NSLog(@"selectAnnotation");
//
//}

#pragma mark - Initialization

- (void)initGestures
{
    /* Long Press gesture. */
    self.longPressGestureGecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    self.longPressGestureGecognizer.minimumPressDuration = 0.5;
    [self.view addGestureRecognizer:self.longPressGestureGecognizer];
}

- (void)initToolBar
{
//    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                                                             target:nil
//                                                                             action:nil];
//    
//    UILabel *prompts = [[UILabel alloc] init];
//    prompts.text            = @"长按添加标注";
//    prompts.textAlignment   = UITextAlignmentCenter;
//    prompts.backgroundColor = [UIColor clearColor];
//    prompts.textColor       = [UIColor whiteColor];
//    prompts.font            = [UIFont systemFontOfSize:20];
//    [prompts sizeToFit];
//    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:prompts];
    
    //Circle
    UIButton *ButtonCircle = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    ButtonCircle.frame = CGRectMake(0, 0, 50, 30);
    ButtonCircle.backgroundColor = [UIColor clearColor];
    [ButtonCircle setTitle:@"Circle" forState:UIControlStateNormal];
    ButtonCircle.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
    [ButtonCircle setBackgroundImage:[UIImage imageNamed:@"28.png"] forState:UIControlStateNormal];
    [self.view addSubview:ButtonCircle];
    [ButtonCircle addTarget:self action:@selector(addOverlay) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *itemCircle = [[UIBarButtonItem alloc] initWithCustomView:ButtonCircle];
    
    //Rect
    UIButton *ButtonRect = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    ButtonRect.frame = CGRectMake(60, self.view.frame.size.height -100, 50, 30);
    ButtonRect.backgroundColor = [UIColor clearColor];
    [ButtonRect setTitle:@"Rect" forState:UIControlStateNormal];
    ButtonRect.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
    [ButtonRect setBackgroundImage:[UIImage imageNamed:@"28.png"] forState:UIControlStateNormal];
    [self.view addSubview:ButtonRect];
    [ButtonRect addTarget:self action:@selector(addRect) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *itemRect = [[UIBarButtonItem alloc] initWithCustomView:ButtonRect];
    
    //Location
    UIButton *ButtonLocation = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    ButtonLocation.frame = CGRectMake(60, self.view.frame.size.height -100, 50, 30);
    ButtonLocation.backgroundColor = [UIColor clearColor];
    [ButtonLocation setTitle:@"Location" forState:UIControlStateNormal];
    ButtonLocation.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
    [ButtonLocation setBackgroundImage:[UIImage imageNamed:@"28.png"] forState:UIControlStateNormal];
    [self.view addSubview:ButtonLocation];
    [ButtonLocation addTarget:self action:@selector(setMyLocationStart) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *itemLocation = [[UIBarButtonItem alloc] initWithCustomView:ButtonLocation];
    
    //Route
    UIButton *ButtonRoute = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    ButtonRoute.frame = CGRectMake(60, self.view.frame.size.height -100, 50, 30);
    ButtonRoute.backgroundColor = [UIColor clearColor];
    [ButtonRoute setTitle:@"Route" forState:UIControlStateNormal];
    ButtonRoute.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
    [ButtonRoute setBackgroundImage:[UIImage imageNamed:@"28.png"] forState:UIControlStateNormal];
    [self.view addSubview:ButtonRoute];
    [ButtonRoute addTarget:self action:@selector(searchTheRoute) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *itemRoute = [[UIBarButtonItem alloc] initWithCustomView:ButtonRoute];
    
    self.toolbarItems = [NSArray arrayWithObjects:itemCircle,itemRect,itemLocation,itemRoute,nil];
}

#pragma mark -DRAW electronic fence

- (double) getTheDistancey1:(double)lon1 x1:(double)lat1 y2:
(double)lon2 x2:(double)lat2
{
	double er = 6378137; // 6378700.0f;
	//ave. radius = 6371.315 (someone said more accurate is 6366.707)
	//equatorial radius = 6378.388
	//nautical mile = 1.15078
	double radlat1 = PI*lat1/180.0f;
	double radlat2 = PI*lat2/180.0f;
	//now long.
	double radlong1 = PI*lon1/180.0f;
	double radlong2 = PI*lon2/180.0f;
	if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
	if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
	if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
	if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
	if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
	if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
	//spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
	//zero ag is up so reverse lat
	double x1 = er * cos(radlong1) * sin(radlat1);
	double y1 = er * sin(radlong1) * sin(radlat1);
	double z1 = er * cos(radlat1);
	double x2 = er * cos(radlong2) * sin(radlat2);
	double y2 = er * sin(radlong2) * sin(radlat2);
	double z2 = er * cos(radlat2);
	double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
	//side, side, side, law of cosines and arccos
	double theta = acos((er*er+er*er-d*d)/(2*er*er));
	double dist  = theta*er;
	return dist;
}

//add  the circle
- (void)addOverlay
{
    NSLog(@"addOverlay---START");
    //self.overlays = [NSMutableArray array];
    
    if ([self.annotations  count] >= 2) {
        //get the poit for draw circle
        MAPointAnnotation *myPointAnn = [self.annotations objectAtIndex:0];
        MAPointAnnotation *myAtherPoint = [self.annotations objectAtIndex:1];
        //get the circle R 
        //float longA = fabs(myPointAnn.coordinate.latitude - myAtherPoint.coordinate.latitude);
        //float longB = fabs(myPointAnn.coordinate.longitude - myAtherPoint.coordinate.longitude);
        double circleR = [self getTheDistancey1:myPointAnn.coordinate.longitude x1:myPointAnn.coordinate.latitude y2:myAtherPoint.coordinate.longitude x2:myAtherPoint.coordinate.latitude]*1.22;

        NSLog(@"X1:%f,Y1:%f,X2:%f,Y2:%f---R:%f",myPointAnn.coordinate.latitude,myAtherPoint.coordinate.longitude,myAtherPoint.coordinate.latitude,myAtherPoint.coordinate.longitude,circleR);
        /* Circle. */
        MACircle *circle = [MACircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(myPointAnn.coordinate.latitude, myPointAnn.coordinate.longitude) radius:circleR];
        //[self.overlays insertObject:circle atIndex:OverlayViewControllerOverlayTypeCircle];
        [self.mapView addOverlay:circle];
        
    } else {
    
        NSLog(@"there not have two point!");
    }
}

// add the Rect
- (void)addRect
{
    
    if ([self.annotations  count] >= 2) {
        //get the poit for draw circle
        MAPointAnnotation *myPointAnn = [self.annotations objectAtIndex:0];
        MAPointAnnotation *myAtherPoint = [self.annotations objectAtIndex:1];
        
        float x1 = myPointAnn.coordinate.latitude;
        float y1 = myPointAnn.coordinate.longitude;
        float x2 = myAtherPoint.coordinate.latitude;
        float y2 = myAtherPoint.coordinate.longitude;
        /* Polygon. */
        CLLocationCoordinate2D coordinates[5];
        coordinates[0].latitude = x1;
        coordinates[0].longitude = y1;
    
        coordinates[1].latitude = x2;
        coordinates[1].longitude = y1;
    
        coordinates[2].latitude = x2;
        coordinates[2].longitude = y2;
    
        coordinates[3].latitude = x1;
        coordinates[3].longitude = y2;
    
        coordinates[4].latitude = x1;
        coordinates[4].longitude = y1;
        MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:4];
        //[self.overlays insertObject:polygon atIndex:OverlayViewControllerOverlayTypePolygon];
        [self.mapView addOverlay:polygon];
    } else {
    
        NSLog(@"there not have two point!");
    }
}

//add the polyline
- (void)addLine {

    CLLocationCoordinate2D coordinates[[self.annotations count]];
    if ([self.annotations count] >= 2) {
        for (int i = 0; i < [self.annotations count]; i++) {
            //remove the overlays line
            [self.mapView removeOverlays:self.overlays];
            MAPointAnnotation *myPointAnn = [self.annotations objectAtIndex:i];
            coordinates[i].latitude = myPointAnn.coordinate.latitude;
            coordinates[i].longitude = myPointAnn.coordinate.longitude;
        }

        MAPolyline *myPolyLine = [MAPolyline polylineWithCoordinates:coordinates count:[self.annotations count]];
        [self.overlays insertObject:myPolyLine atIndex:delteTarg - 2];
        [self.mapView addOverlay:myPolyLine];
    } else {
    
        NSLog(@"there not have two point!");
    }
}


//get the Route
- (void)searchTheRoute {
    
    /* Remove prior path overlay. */
    //[self.mapView removeOverlay:self.pathPolyline];
    
    /* Remove prior road annotations. */
    //[self.mapView removeAnnotations:self.roadAnnotations];
    
    [self.roadAnnotations removeAllObjects];
    
    if ([self.annotations  count] >= 2) {
        //get the poit for draw circle
        MAPointAnnotation *myPointAnn = [self.annotations objectAtIndex:0];
        MAPointAnnotation *myAtherPoint = [self.annotations objectAtIndex:1];
        
        float y1 = myPointAnn.coordinate.latitude;
        float x1 = myPointAnn.coordinate.longitude;
        float y2 = myAtherPoint.coordinate.latitude;
        float x2 = myAtherPoint.coordinate.longitude;
        
        self.searchOption=[[MARouteSearchOption alloc]init];
        self.searchOption.x1= [NSString stringWithFormat:@"%f",x1];
        self.searchOption.y1= [NSString stringWithFormat:@"%f",y1];
        self.searchOption.x2= [NSString stringWithFormat:@"%f",x2];
        self.searchOption.y2= [NSString stringWithFormat:@"%f",y2];
        self.searchOption.config=@"R";
        self.searchOption.encode = @"UTF-8";
        self.searchOption.routeType = [NSString stringWithFormat:@"%d",10];
        self.searchOption.avoidanceType = [NSString stringWithFormat:@"%d",3];
        [self.search routeSearchWithOption:self.searchOption];

    }
}


#pragma mark - Route Delegate

- (void)initAnnotations
{
    self.roadAnnotations = [NSMutableArray array];
    
//    self.startAnnotation = [[MAPointAnnotation alloc] init];
//    self.startAnnotation.coordinate = CLLocationCoordinate2DMake(39.907951, 116.282875);
//    self.startAnnotation.title = @"Start Point";
//    
//    self.endAnnotation = [[MAPointAnnotation alloc] init];
//    self.endAnnotation.coordinate = CLLocationCoordinate2DMake(39.910150, 116.495743);
//    self.endAnnotation.title = @"End Point";
}

/* Parse coordinate string to CLLocationCoordinate2D structure,
 The caller must be responsible for releasing the result memmory.
 */
- (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string coordinateCount:(NSUInteger *)coordinateCount
{
    if (string == nil)
    {
        return NULL;
    }
    
    NSArray *components = [string componentsSeparatedByString:@","];
    
    NSUInteger count = [components count] / 2;
    if (coordinateCount != NULL)
    {
        *coordinateCount = count;
    }
    
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++)
    {
        coordinates[i].longitude = [[components objectAtIndex:2 * i]     doubleValue];
        coordinates[i].latitude  = [[components objectAtIndex:2 * i + 1] doubleValue];
    }
    
    return coordinates;
}

-(void)routeSearch:(MARouteSearchOption*)routeSearchOption Result:(MARouteSearchResult*)result
{
    if (self.searchOption != routeSearchOption)
    {
        return;
    }
    
    NSUInteger pathCoordinateCount = 0;
    CLLocationCoordinate2D *pathCoordinates = [self coordinatesForString:result.coors coordinateCount:&pathCoordinateCount];
    if (pathCoordinates == NULL)
    {
        NSLog(@"%s: path coordinates is invalid. ", __func__);
        
        return;
    }
    
    self.pathPolyline = [MAPolyline polylineWithCoordinates:pathCoordinates count:pathCoordinateCount];
    [self.mapView addOverlay:self.pathPolyline];
    
    [result.routes enumerateObjectsUsingBlock:^(MARoute *route, NSUInteger idx, BOOL *stop) {
        
        MAPointAnnotation *roadAnnotation = [[MAPointAnnotation alloc] init];
        roadAnnotation.title = route.roadName;
        roadAnnotation.subtitle = route.accessorialInfo;
        
        CLLocationCoordinate2D *roadCoordinates = [self coordinatesForString:route.coor coordinateCount:NULL];
        if (roadCoordinates == NULL)
        {
            return;
        }
        roadAnnotation.coordinate = roadCoordinates[0];
        
        free(roadCoordinates), roadCoordinates = NULL;
        
        [self.roadAnnotations addObject:roadAnnotation];
        
    }];
    
    [self.mapView addAnnotations:self.roadAnnotations];
    
    free(pathCoordinates), pathCoordinates = NULL;
}

#pragma mark GET Location
- (void)setMyLocationStart{
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    //jump to  the user location
    if (self.mapView.userLocation != nil) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate];
        NSLog(@"x:%f---y:%f",self.mapView.userLocation.coordinate.latitude,self.mapView.userLocation.coordinate.longitude);
        userLocation *myLocation = [[userLocation alloc] init];
        myLocation.tel = @"13633841518";
        myLocation.x = [NSString stringWithFormat:@"%f",mapView.userLocation.coordinate.longitude];
        myLocation.y = [NSString stringWithFormat:@"%f",mapView.userLocation.coordinate.latitude];
        [tool setTheLocation:myLocation];
        
        
    }
}

#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        self.annotations   = [NSMutableArray array];
        self.searchOptions = [NSMutableArray array];
        self.pointForOverlay = [[NSMutableArray alloc]initWithCapacity:2];
        self.overlays = [NSMutableArray array];
        delteTarg = 0;
        [self initAnnotations];
    }
    
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
    self.navigationController.toolbar.translucent   = YES;
    [self.navigationController setToolbarHidden:NO animated:animated];
    self.mapView.showsUserLocation = YES;
    //[self.mapView addOverlays:self.overlays];
}

- (void)viewDidDisappear:(BOOL)animated
{
    /* Reset mapView. */
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode  = MAUserTrackingModeNone;
    
    //[self.mapView removeObserver:self forKeyPath:@"showsUserLocation"];
    
    [super viewDidDisappear:animated];
}

#pragma mark - viewForOverlay

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleView *circleView = [[MACircleView alloc] initWithCircle:overlay];
        
        circleView.lineWidth   = 7;
        circleView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        circleView.fillColor   = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        
        return circleView;
    }
    else if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygonView *polygonView = [[MAPolygonView alloc] initWithPolygon:overlay];
        polygonView.lineWidth   = 7;
        polygonView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        polygonView.fillColor   = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        
        return polygonView;
    }
    else if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth   = 7;
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        
        return polylineView;
    }
    
    return nil;
}


@end
