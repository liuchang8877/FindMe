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
#import "ASIHTTPRequest.h"
#import "allConfig.h"
#import "SBJson.h"


#define PI 3.1415926
enum{
    OverlayViewControllerOverlayTypeCircle = 0,
    OverlayViewControllerOverlayTypePolyline,
    OverlayViewControllerOverlayTypePolygon
};


@interface ViewController () {
    
    MAPointAnnotation *saveCircleCenter;
    double            saveCircleR;
    int               httpFlag;      //0:location 1:getcircle 2:getrect 3:getroad
    RectInfo          *mainRectInfo;

    int               closeFencOrPath;  // 0:close Fenc ,1:close Path, 3 not
    
}

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
@synthesize functionFlag = _functionFlag;

- (void)viewDidLoad
{
    //init the flag
    httpFlag = 0;
    //init the rectinfo
    mainRectInfo = [[RectInfo alloc]init];
    //init close flag
    closeFencOrPath  = 3; // not close
    
    [super viewDidLoad];

    [self initTheFunction];
    
    [self initToolBar];
    
    [self initGestures];
    
    [self setTheRightButton];
    
    [self.view addSubview:mapView];

}

//add the button to  the navigation bar
- (void)setTheRightButton
{
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 51, 30)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.tag = 0;
    button.frame = CGRectMake(0, 0, 51, 30);
    //[button setBackgroundImage:[UIImage imageNamed:@"xz_nav_cancel.png"] forState:UIControlStateNormal];
    //[button setBackgroundImage:[UIImage imageNamed:@"xz_nav_cancel_down.png"] forState:UIControlStateHighlighted];
    [button setTitle:@"设定" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onclickRightButton) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:button];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

//click right button
- (void)onclickRightButton
{
    // use to update the info about the fenc safepath
    if ([self.functionFlag integerValue] == 2) {
        // update the findtel's fenc
    
        if (saveCircleR != 0.0 && saveCircleCenter != nil) {
            NSLog(@"updateTheCirecleInfo---center:%@,R:%f",saveCircleCenter,saveCircleR);
            userInfo *myUserInfo = [[userInfo alloc] init];
            //set the info
            myUserInfo.name = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
            myUserInfo.pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PWD];
            myUserInfo.findTel = [[NSUserDefaults standardUserDefaults] objectForKey:FINDTEL];
            
            //update to the server
            [self updateCircleInfo:saveCircleCenter radius:saveCircleR userInfo:myUserInfo];
            
        } else {
        
            [tool waringInfo:@"圆形围栏信息不全"];
        }
        
    } else if ([self.functionFlag integerValue] == 3) {
        
        // update the findtel's fenc Rect
        
        if ([mainRectInfo.x1 length] != 0) {
            
            userInfo *myUserInfo = [[userInfo alloc] init];
            //set the info
            myUserInfo.name = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
            myUserInfo.pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PWD];
            myUserInfo.findTel = [[NSUserDefaults standardUserDefaults] objectForKey:FINDTEL];
        
            //update to the server
            [self updateRectInfo:mainRectInfo userInfo:myUserInfo];
            
        } else {
            
            [tool waringInfo:@"矩形围栏信息不全"];
        }
    
    } else if ([self.functionFlag integerValue] == 1) {
        // get the save path and update
        
        if ([self.annotations count] >= 2) {
            
            userInfo *myUserInfo = [[userInfo alloc] init];
            //set the info
            myUserInfo.name = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
            myUserInfo.pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PWD];
            myUserInfo.findTel = [[NSUserDefaults standardUserDefaults] objectForKey:FINDTEL];
            
            //update line info to the server
            [self updateLineInfo:self.annotations userInfo:myUserInfo];
        
        } else {
        
            [tool waringInfo:@"安全路径信息不全"];
        }
    
    }

    //NSLog(@"update---functionFlag:%d",[self.functionFlag integerValue]);
}

-  (void)closeTheFenc {
    
    
    closeFencOrPath = 0;
    
    userInfo *myUserInfo = [[userInfo alloc] init];
    //set the info
    myUserInfo.name = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
    myUserInfo.pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PWD];
    myUserInfo.findTel = [[NSUserDefaults standardUserDefaults] objectForKey:FINDTEL];
    
    if (closeFencOrPath) {
        
        //update line info to the server  close it
        [self updateLineInfo:self.annotations userInfo:myUserInfo];
        
    } else {
        
        //update to the server
        [self updateCircleInfo:saveCircleCenter radius:saveCircleR userInfo:myUserInfo];
    }


}

-  (void)closeTheLine {
    
    
    closeFencOrPath = 1;
    
    userInfo *myUserInfo = [[userInfo alloc] init];
    //set the info
    myUserInfo.name = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
    myUserInfo.pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PWD];
    myUserInfo.findTel = [[NSUserDefaults standardUserDefaults] objectForKey:FINDTEL];
    
    if (closeFencOrPath) {
        
        //update line info to the server  close it
        [self updateLineInfo:self.annotations userInfo:myUserInfo];
        
    } else {
        
        //update to the server
        [self updateCircleInfo:saveCircleCenter radius:saveCircleR userInfo:myUserInfo];
    }
    
    
}

#pragma mark http for updateCircleInfo
- (void)updateCircleInfo:(MAPointAnnotation *)center radius:(double) circleR userInfo:(userInfo*)myUserInfo
{
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString  *closeFlag;
    
    if (closeFencOrPath != 3) {
        
        closeFlag = @"0";
        
    } else {
        
        closeFlag = @"1";
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=setfence&user=%@&pwd=%@&tel=%@&switch=%@&type=%@&param=%f,%f,%f",URL_IP,URL_PORT,myUserInfo.name,myUserInfo.pwd,myUserInfo.findTel,closeFlag,@"circle",center.coordinate.longitude,center.coordinate.latitude,circleR];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *myRequest;
    NSLog(@"setTheLocation---url:%@",url);
    if ([tool checkNet])
    {
        NSLog(@"setTheLocation---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
        //        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
        //        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
        
    } else {
        
        NSLog(@"setTheLocation---net is NOT ok");
        [tool checkNetAlter];
    }
}

#pragma mark http for updateRectInfo
- (void)updateRectInfo:(RectInfo *)myRect userInfo:(userInfo*)myUserInfo
{
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=setfence&user=%@&pwd=%@&tel=%@&switch=%@&type=%@&param=%@,%@,%@,%@,%@,%@,%@,%@",URL_IP,URL_PORT,myUserInfo.name,myUserInfo.pwd,myUserInfo.findTel,@"1",@"rectangle",myRect.x1,myRect.y1,myRect.x2,myRect.y2,myRect.x3,myRect.y3,myRect.x4,myRect.y4];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *myRequest;
    NSLog(@"setTheLocation---url:%@",url);
    if ([tool checkNet])
    {
        NSLog(@"setTheLocation---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
        //        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
        //        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
        
    } else {
        
        NSLog(@"setTheLocation---net is NOT ok");
        [tool checkNetAlter];
    }
}


#pragma mark http for updateLineInfo
- (void)updateLineInfo:(NSMutableArray *)myLineArr userInfo:(userInfo*)myUserInfo
{
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString  *closeFlag;
    
    if (closeFencOrPath != 3) {
        
        closeFlag = @"0";
        
    } else {
        
        closeFlag = @"1";
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=setsafepath&user=%@&pwd=%@&tel=%@&switch=%@&param=",URL_IP,URL_PORT,myUserInfo.name,myUserInfo.pwd,myUserInfo.findTel,closeFlag];
    
    for (int i = 0; i < [myLineArr count]; i++) {
        //add str about the line node to the string
        
        MAPointAnnotation *myPointAnn = [myLineArr objectAtIndex:i];
        
        NSString *lineX = [NSString stringWithFormat:@"%f",myPointAnn.coordinate.longitude];
        NSString *lineY = [NSString stringWithFormat:@"%f",myPointAnn.coordinate.latitude];
        
        urlStr = [urlStr stringByAppendingString:lineX];
        urlStr = [urlStr stringByAppendingString:@","];
        urlStr = [urlStr stringByAppendingString:lineY];
        
        if ( i != [myLineArr count] - 1)
            urlStr = [urlStr stringByAppendingString:@","];
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *myRequest;
    NSLog(@"setTheLocation---url:%@",url);
    if ([tool checkNet])
    {
        NSLog(@"setTheLocation---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
        //        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
        //        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
        
    } else {
        
        NSLog(@"setTheLocation---net is NOT ok");
        [tool checkNetAlter];
    }
}


- (void)initTheFunction {
    
    //this is the find location
    if ([self.functionFlag integerValue] == 0) {
    
        userInfo *myUserInfo  = [[userInfo alloc] init];
        myUserInfo.name     = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
        myUserInfo.pwd      = [[NSUserDefaults standardUserDefaults] objectForKey:PWD];
        myUserInfo.findTel  = [[NSUserDefaults standardUserDefaults] objectForKey:FINDTEL];
        [self findTheLocation:myUserInfo];
    
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utility

- (void)addAnnotationForCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    if ([self.functionFlag integerValue] == 0) {
        
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        annotation.coordinate = coordinate;
        annotation.title      = [[NSUserDefaults standardUserDefaults] objectForKey:FINDTEL];
        [self.mapView addAnnotation:annotation];
    
    } else {
        
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        annotation.coordinate = coordinate;
        annotation.title      = @"取消";
        
        [self.annotations addObject:annotation];
        
        [self.pointForOverlay addObject:annotation];
        
        [self.mapView addAnnotation:annotation];
    
    }

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
    if ([self.functionFlag integerValue] != 0) {
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[gestureRecognizer locationInView:self.view] toCoordinateFromView:self.view];
            
            [self addAnnotationForCoordinate:coordinate];
            
            //[self reverseRequestCoordinate:coordinate];
        }
        
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
            if ([self.functionFlag integerValue] != 0)
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
    
    //Line
    UIButton *ButtonLine = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    ButtonLine.frame = CGRectMake(60, self.view.frame.size.height -100, 50, 30);
    ButtonLine.backgroundColor = [UIColor clearColor];
    [ButtonLine setTitle:@"Line" forState:UIControlStateNormal];
    ButtonLine.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
    [ButtonLine setBackgroundImage:[UIImage imageNamed:@"28.png"] forState:UIControlStateNormal];
    [self.view addSubview:ButtonLine];
    [ButtonLine addTarget:self action:@selector(addLine) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *itemLine = [[UIBarButtonItem alloc] initWithCustomView:ButtonLine];
    
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
    
    //Route not add first
    UIButton *ButtonRoute = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    ButtonRoute.frame = CGRectMake(60, self.view.frame.size.height -100, 50, 30);
    ButtonRoute.backgroundColor = [UIColor clearColor];
    [ButtonRoute setTitle:@"Route" forState:UIControlStateNormal];
    ButtonRoute.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
    [ButtonRoute setBackgroundImage:[UIImage imageNamed:@"28.png"] forState:UIControlStateNormal];
    [self.view addSubview:ButtonRoute];
    [ButtonRoute addTarget:self action:@selector(searchTheRoute) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *itemRoute = [[UIBarButtonItem alloc] initWithCustomView:ButtonRoute];
    
    //CloseFenc
    UIButton *ButtonCloseFenc = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    ButtonCloseFenc.frame = CGRectMake(60, self.view.frame.size.height -100, 50, 30);
    ButtonCloseFenc.backgroundColor = [UIColor clearColor];
    [ButtonCloseFenc setTitle:@"reFenc" forState:UIControlStateNormal];
    ButtonCloseFenc.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
    [ButtonCloseFenc setBackgroundImage:[UIImage imageNamed:@"28.png"] forState:UIControlStateNormal];
    [self.view addSubview:ButtonRoute];
    [ButtonCloseFenc addTarget:self action:@selector(closeTheFenc) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *itemButtonCloseFenc = [[UIBarButtonItem alloc] initWithCustomView:ButtonCloseFenc];
    
    //Route not add first
    UIButton *ButtonCloseLine = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    ButtonCloseLine.frame = CGRectMake(60, self.view.frame.size.height -100, 50, 30);
    ButtonCloseLine.backgroundColor = [UIColor clearColor];
    [ButtonCloseLine setTitle:@"reLine" forState:UIControlStateNormal];
    ButtonCloseLine.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
    [ButtonCloseLine setBackgroundImage:[UIImage imageNamed:@"28.png"] forState:UIControlStateNormal];
    [self.view addSubview:ButtonRoute];
    [ButtonCloseLine addTarget:self action:@selector(closeTheLine) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *itemCloseLine = [[UIBarButtonItem alloc] initWithCustomView:ButtonCloseLine];
    
    self.toolbarItems = [NSArray arrayWithObjects:itemCircle,itemRect,itemLine,itemButtonCloseFenc,itemCloseLine,nil];
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
    
    if ([self.functionFlag integerValue] == 0) {
        
        // get server info about the fenc and path
        [self getFromServerForFencCircle];
        
    } else if ([self.functionFlag integerValue] == 2) {
        
        //when it is not in the “Real time positioning”
        [self drawTheCircle];

    } else {
    
        [tool waringInfo:@"此处无法设置圆形围栏"];
    }

}

- (void)getFromServerForFencCircle
{
    // it is in the “Real time positioning”, you have to get fenc
    userInfo *myUserInfo = [[userInfo alloc]init];
    //set the info
    myUserInfo.name = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
    myUserInfo.pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PWD];
    myUserInfo.findTel = [[NSUserDefaults standardUserDefaults] objectForKey:FINDTEL];
    //get the circleinfo
    [self getTheCircleInfo:myUserInfo];
}

- (void)getFromServerForFencRect
{
    // it is in the “Real time positioning”, you have to get fenc
    userInfo *myUserInfo = [[userInfo alloc]init];
    //set the info
    myUserInfo.name = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
    myUserInfo.pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PWD];
    myUserInfo.findTel = [[NSUserDefaults standardUserDefaults] objectForKey:FINDTEL];
    //get the circleinfo
    [self getTheRectInfo:myUserInfo];
}

- (void)getFromServerForLine
{
    // it is in the “Real time positioning”, you have to get fenc
    userInfo *myUserInfo = [[userInfo alloc]init];
    //set the info
    myUserInfo.name = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
    myUserInfo.pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PWD];
    myUserInfo.findTel = [[NSUserDefaults standardUserDefaults] objectForKey:FINDTEL];
    //get the line info
    [self getTheLineInfo:myUserInfo];
}

#pragma mark http for getTheCircleInfo
- (void)getTheCircleInfo:(userInfo*)myUserInfo
{
    
    //init the flag for get the location
    httpFlag = 1;
    
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=getuser&user=%@&pwd=%@&tel=%@",URL_IP,URL_PORT,myUserInfo.name,myUserInfo.pwd,myUserInfo.findTel];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *myRequest;
    NSLog(@"setTheLocation---url:%@",url);
    if ([tool checkNet])
    {
        NSLog(@"setTheLocation---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
        //        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
        //        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
        
    } else {
        
        NSLog(@"setTheLocation---net is NOT ok");
        [tool checkNetAlter];
    }
}

#pragma  mark draw cicle
-(void)drawTheDownloadCircle:(NSString *)circleX circleY:(NSString *)circleY radius:(NSString *)circleR{
    
    NSLog(@"addOverlay---START");
    //self.overlays = [NSMutableArray array];
    
    if ([circleX length] != 0 && [circleY length] != 0 && [circleR length] != 0) {

        /* Circle. */
        MACircle *circle = [MACircle circleWithCenterCoordinate:CLLocationCoordinate2DMake([circleY doubleValue], [circleX doubleValue]) radius:[circleR doubleValue]];
        //[self.overlays insertObject:circle atIndex:OverlayViewControllerOverlayTypeCircle];
        [self.mapView addOverlay:circle];
        
    } else {
        
        NSLog(@"there not have two point!");
    }

}

#pragma  mark draw cicle
-(void)drawTheCircle {

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
        
        //save the center and  R
        saveCircleR = circleR;
        saveCircleCenter = myPointAnn;
        
        /* Circle. */
        MACircle *circle = [MACircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(myPointAnn.coordinate.latitude, myPointAnn.coordinate.longitude) radius:circleR];
        //[self.overlays insertObject:circle atIndex:OverlayViewControllerOverlayTypeCircle];
        [self.mapView addOverlay:circle];
        
    } else {
        
        NSLog(@"there not have two point!");
    }


}

#pragma mark http for getTheRectInfo
- (void)getTheRectInfo:(userInfo*)myUserInfo
{
    
    //init the flag for get the location
    httpFlag = 2;
    
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=getuser&user=%@&pwd=%@&tel=%@",URL_IP,URL_PORT,myUserInfo.name,myUserInfo.pwd,myUserInfo.findTel];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *myRequest;
    NSLog(@"setTheLocation---url:%@",url);
    if ([tool checkNet])
    {
        NSLog(@"setTheLocation---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
        //        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
        //        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
        
    } else {
        
        NSLog(@"setTheLocation---net is NOT ok");
        [tool checkNetAlter];
    }
}

// add the Rect
- (void)addRect
{
    if ([self.functionFlag integerValue] == 0) {
        
        [self getFromServerForFencRect];
        
    } else if ([self.functionFlag integerValue] == 3){
        
        // draw the rect info
        [self drawTheRect];
        
    } else {
    
        [tool waringInfo:@"此处不能设置矩形围栏"];
    }

}

#pragma mark Draw the rect
- (void)drawTheRect
{
    if ([self.annotations  count] >= 2) {
        //get the poit for draw circle
        MAPointAnnotation *myPointAnn = [self.annotations objectAtIndex:0];
        MAPointAnnotation *myAtherPoint = [self.annotations objectAtIndex:1];
        
        float y1 = myPointAnn.coordinate.latitude;
        float x1 = myPointAnn.coordinate.longitude;
        float y2 = myAtherPoint.coordinate.latitude;
        float x2 = myAtherPoint.coordinate.longitude;
        /* Polygon. */
        CLLocationCoordinate2D coordinates[5];
        coordinates[0].latitude = y1;
        coordinates[0].longitude = x1;
        
        coordinates[1].latitude = y2;
        coordinates[1].longitude = x1;
        
        coordinates[2].latitude = y2;
        coordinates[2].longitude = x2;
        
        coordinates[3].latitude = y1;
        coordinates[3].longitude = x2;
        
        coordinates[4].latitude = y1;
        coordinates[4].longitude = x1;
        
        //save the rect info in mainRectInfo
        mainRectInfo.x1 = [NSString stringWithFormat:@"%f",x1];
        mainRectInfo.y1 = [NSString stringWithFormat:@"%f",y1];
        mainRectInfo.x2 = [NSString stringWithFormat:@"%f",x2];
        mainRectInfo.y2 = [NSString stringWithFormat:@"%f",y1];
        mainRectInfo.x3 = [NSString stringWithFormat:@"%f",x2];
        mainRectInfo.y3 = [NSString stringWithFormat:@"%f",y2];
        mainRectInfo.x4 = [NSString stringWithFormat:@"%f",x1];
        mainRectInfo.y4 = [NSString stringWithFormat:@"%f",y2];
        
        MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:4];
        //[self.overlays insertObject:polygon atIndex:OverlayViewControllerOverlayTypePolygon];
        [self.mapView addOverlay:polygon];
    } else {
        
        NSLog(@"there not have two point!");
    }


}

#pragma  mark  DRAW download rect
- (void)drawDownloadRect
{
    
    if ([mainRectInfo.x1 length]!= 0) {

        /* Polygon. */
        CLLocationCoordinate2D coordinates[5];
        coordinates[0].latitude  = [mainRectInfo.y1 floatValue];
        coordinates[0].longitude = [mainRectInfo.x1 floatValue];
        
        coordinates[1].latitude  = [mainRectInfo.y2 floatValue];
        coordinates[1].longitude = [mainRectInfo.x2 floatValue];
        
        coordinates[2].latitude  = [mainRectInfo.y3 floatValue];
        coordinates[2].longitude = [mainRectInfo.x3 floatValue];
        
        coordinates[3].latitude  = [mainRectInfo.y4 floatValue];
        coordinates[3].longitude = [mainRectInfo.x4 floatValue];
        
        coordinates[4].latitude  = [mainRectInfo.y1 floatValue];
        coordinates[4].longitude = [mainRectInfo.x1 floatValue];
        

        
        MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:4];
        //[self.overlays insertObject:polygon atIndex:OverlayViewControllerOverlayTypePolygon];
        [self.mapView addOverlay:polygon];
        
    } else {
        
        NSLog(@"there not have two point!");
    }

}

#pragma mark http for getTheLineInfo
- (void)getTheLineInfo:(userInfo*)myUserInfo
{
    
    //init the flag for get the line
    httpFlag = 3;
    
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=getuser&user=%@&pwd=%@&tel=%@",URL_IP,URL_PORT,myUserInfo.name,myUserInfo.pwd,myUserInfo.findTel];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *myRequest;
    NSLog(@"setTheLocation---url:%@",url);
    if ([tool checkNet])
    {
        NSLog(@"setTheLocation---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
        //        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
        //        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
        
    } else {
        
        NSLog(@"setTheLocation---net is NOT ok");
        [tool checkNetAlter];
    }
}


//add the polyline
- (void)addLine {
    
    if ([self.functionFlag integerValue] == 0) {
        
        [self getFromServerForLine];
        
    } else if ([self.functionFlag integerValue] == 1){
        
        // draw the line info
        [self drawTheLine];
        
    } else {
    
        //[tool waringInfo:@"此处无法设置安全路径"];
    }

}

#pragma mark draw the line
- (void)drawTheLine {

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
        //[self.overlays insertObject:myPolyLine atIndex:delteTarg - 2];
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
        
        myLocation.tel = [[NSUserDefaults standardUserDefaults] objectForKey:TEL];
        myLocation.x = [NSString stringWithFormat:@"%f",mapView.userLocation.coordinate.longitude];
        myLocation.y = [NSString stringWithFormat:@"%f",mapView.userLocation.coordinate.latitude];
       // [self setTheLocation:myLocation];
        
        
    }
}

#pragma mark http for setTheLocation
- (void)setTheLocation:(userLocation *)myLocation
{
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=sendloc&tel=%@&longi=%@&lati=%@",URL_IP,URL_PORT,myLocation.tel,myLocation.x,myLocation.y];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *myRequest;
    NSLog(@"setTheLocation---url:%@",url);
    if ([tool checkNet])
    {
        NSLog(@"setTheLocation---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
//        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
//        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
        
    } else {
        
        NSLog(@"setTheLocation---net is NOT ok");
        [tool checkNetAlter];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    //NSData *responseData = [request responseData];
    
    NSString *responseString=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    
    NSLog(@"userLocationRequestFinished---responseString:%@",responseString);
    
    
    if ([self.functionFlag integerValue] == 0) {
        
        if (httpFlag == 0) {

            [self HttpFinishedForGetLocation:request];
            
        } else if (httpFlag == 1) {
        
            [self HttpFinishedForGetCircle:request];
            
            //[tool waringInfo:@"设置圆形围栏成功！"];
            
        } else if (httpFlag == 2) {
        
            [self HttpFinishedForGetRect:request];
            
            //[tool waringInfo:@"设置矩形围栏成功！"];
            
        } else if (httpFlag == 3) {
        
            [self HttpFinishedForGetLine:request];
            
            //[tool waringInfo:@"设置安全路径成功！"];
        }

    } else if ([self.functionFlag integerValue] == 1) {
        
        if ([request responseStatusCode] == 200) {
            
            [tool waringInfo:@"上传安全路径成功！"];
        }
    
    } else if ([self.functionFlag integerValue] == 2) {
    
        if ([request responseStatusCode] == 200) {
            
            [tool waringInfo:@"上传圆形围栏成功！"];
        }
        
    } else if ([self.functionFlag integerValue] == 3) {
    
        if ([request responseStatusCode] == 200) {
            
            [tool waringInfo:@"上传矩形围栏成功！"];
        }
    }
    
    //    SBJsonParser * parser = [[SBJsonParser alloc] init];
    //    NSError * error = nil;
    //    NSMutableDictionary *jsonDic = [parser objectWithString:responseString error:&error];
    //
    //    NSMutableDictionary * dicRetInfo = [jsonDic objectForKey:@"ret"];
    
}

// for the get location
- (void)HttpFinishedForGetLocation:(ASIHTTPRequest *)request
{
    //find the location
    NSString *responseString=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    
    SBJsonParser * parser = [[SBJsonParser alloc] init];
    NSError * error = nil;
    NSMutableDictionary *jsonDic = [parser objectWithString:responseString error:&error];
    NSMutableArray * ArrRetInfo = [jsonDic objectForKey:@"getuserloc"];
    
    NSString* findTel;
    NSString* findTime;
    NSString* findLongti;
    NSString* findLati;
    
    for (int i = 0 ; i < [ArrRetInfo count]; i++) {
        
        findTel     = [[ArrRetInfo objectAtIndex:i] objectForKey:@"tel"];
        findTime    = [[ArrRetInfo objectAtIndex:i] objectForKey:@"time"];
        findLongti  = [[ArrRetInfo objectAtIndex:i] objectForKey:@"longti"];
        findLati    = [[ArrRetInfo objectAtIndex:i] objectForKey:@"lati"];
    }
    
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [findLongti doubleValue];
    coordinate.latitude  = [findLati doubleValue];
    [self addAnnotationForCoordinate:coordinate];
    
    //NSMutableDictionary * dicRetInfo = [jsonDic objectForKey:@"tel"];
}

//for get circle info
- (void)HttpFinishedForGetCircle:(ASIHTTPRequest *)request {
    
    //find the circle 
    NSString *responseString=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    
    SBJsonParser * parser = [[SBJsonParser alloc] init];
    NSError * error = nil;
    NSMutableDictionary *jsonDic = [parser objectWithString:responseString error:&error];
    NSMutableArray * ArrRetInfo = [jsonDic objectForKey:@"getuser"];
    
    NSString* findTel;
    NSString* findFence;

    
    for (int i = 0 ; i < [ArrRetInfo count]; i++) {
        
        findTel     = [[ArrRetInfo objectAtIndex:i] objectForKey:@"tel"];
        findFence    = [[ArrRetInfo objectAtIndex:i] objectForKey:@"fence"];

    }

    NSArray *listItems = [findFence componentsSeparatedByString:@"|"];

    NSString *centerAndR;

    if ([listItems count] == 3) {
        
       centerAndR = [listItems objectAtIndex:2];
        
    } else {
        
        NSLog(@"listItems---not enough");
    }

    NSArray *centerAndRArr = [centerAndR componentsSeparatedByString:@","];

    NSString *circleCenterX, *circleCenterY,*circleR;

    if ([centerAndRArr count] == 3){
        
        circleCenterX = [centerAndRArr objectAtIndex:0];
        circleCenterY = [centerAndRArr objectAtIndex:1];
        circleR       = [centerAndRArr objectAtIndex:2];
        
    } else {
        
         NSLog(@"centerAndRArr---not enough");
        
    }
    
    // draw the download circle on the map
    [self drawTheDownloadCircle:circleCenterX circleY:circleCenterY radius:circleR];
}


//for get Rect info
- (void)HttpFinishedForGetRect:(ASIHTTPRequest *)request {
    
    //find the Rect
    NSString *responseString=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    
    SBJsonParser * parser = [[SBJsonParser alloc] init];
    NSError * error = nil;
    NSMutableDictionary *jsonDic = [parser objectWithString:responseString error:&error];
    NSMutableArray * ArrRetInfo = [jsonDic objectForKey:@"getuser"];
    
    NSString* findTel;
    NSString* findFence;
    
    
    for (int i = 0 ; i < [ArrRetInfo count]; i++) {
        
        findTel     = [[ArrRetInfo objectAtIndex:i] objectForKey:@"tel"];
        findFence    = [[ArrRetInfo objectAtIndex:i] objectForKey:@"fence"];
        
    }
    
    NSArray *listItems = [findFence componentsSeparatedByString:@"|"];
    
    NSString *centerAndR;
    
    if ([listItems count] == 3) {
        
        centerAndR = [listItems objectAtIndex:2];
        
    } else {
        
        NSLog(@"listItems---not enough");
    }
    
    NSArray *myRectInfo = [centerAndR componentsSeparatedByString:@","];
    
    //NSString *circleCenterX, *circleCenterY,*circleR;
    
    if ([myRectInfo count] == 8){
        
        mainRectInfo.x1 = [myRectInfo objectAtIndex:0];
        mainRectInfo.y1 = [myRectInfo objectAtIndex:1];
        mainRectInfo.x2 = [myRectInfo objectAtIndex:2];
        mainRectInfo.y2 = [myRectInfo objectAtIndex:3];
        mainRectInfo.x3 = [myRectInfo objectAtIndex:4];
        mainRectInfo.y3 = [myRectInfo objectAtIndex:5];
        mainRectInfo.x4 = [myRectInfo objectAtIndex:6];
        mainRectInfo.y4 = [myRectInfo objectAtIndex:7];
        
    } else {
        
        NSLog(@"myRectInfo---not enough");
        
    }
    
    // draw the download Rect on the map
    [self drawDownloadRect];
}


//for get Line info
- (void)HttpFinishedForGetLine:(ASIHTTPRequest *)request {
    
    //find the Rect
    NSString *responseString=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    
    SBJsonParser * parser = [[SBJsonParser alloc] init];
    NSError * error = nil;
    NSMutableDictionary *jsonDic = [parser objectWithString:responseString error:&error];
    NSMutableArray * ArrRetInfo = [jsonDic objectForKey:@"getuser"];
    
    NSString* findTel;
    NSString* findPath;
    
    
    for (int i = 0 ; i < [ArrRetInfo count]; i++) {
        
        findTel     = [[ArrRetInfo objectAtIndex:i] objectForKey:@"tel"];
        findPath    = [[ArrRetInfo objectAtIndex:i] objectForKey:@"safepath"];
        
    }
    
    NSArray *listItems = [findPath componentsSeparatedByString:@"|"];
    
    NSString *centerAndR;
    
    if ([listItems count] == 2) {
        
        centerAndR = [listItems objectAtIndex:1];
        
    } else {
        
        NSLog(@"listItems---not enough");
    }
    
    NSArray *myLineInfo = [centerAndR componentsSeparatedByString:@","];
    
    //NSString *circleCenterX, *circleCenterY,*circleR;
    
    if ([myLineInfo count] != 0){
        
        for (int i = 0 ; i < [myLineInfo count] - 1; ) {
            
            MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
            
            // set the coordinate 
            CLLocationCoordinate2D coordinate;
            coordinate.longitude = [[myLineInfo objectAtIndex:i] doubleValue];
            coordinate.latitude  = [[myLineInfo objectAtIndex:i+1] doubleValue];
            annotation.coordinate = coordinate;
            annotation.title      = @"取消";
            
            [self.annotations addObject:annotation];
            
            i  =  i + 2;
        }
        
    } else {
        
        NSLog(@"myLineInfo---not enough");
        
    }
    
    // draw the download Line on the map
    [self drawTheLine];
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"setTheLogin---error:%@",error);
    [tool checkNetAlter];
}

#pragma mark http for findTheLocation
- (void)findTheLocation:(userInfo *)myUserInfo
{
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
 
    //init the flag for get the location
    httpFlag = 0;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=getuserloc&user=%@&pwd=%@&tel=%@&type=now&begin=NULL&end=NULL",URL_IP,URL_PORT,myUserInfo.name,myUserInfo.pwd,myUserInfo.findTel];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *myRequest;
    NSLog(@"setTheLocation---url:%@",url);
    if ([tool checkNet])
    {
        NSLog(@"setTheLocation---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
//        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
//        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
    } else {
        
        NSLog(@"setTheLocation---net is NOT ok");
        [tool checkNetAlter];
    }
}

- (void)userLocationRequestFinished:(ASIHTTPRequest *)request
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



- (void)userLocationRequestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"userLocationRequestFailed---error:%@",error);
    [tool checkNetAlter];
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
//        NSTimer *timer;
//        
//        timer = [NSTimer scheduledTimerWithTimeInterval: 30.5
//                                                 target: self
//                                               selector: @selector(setMyLocationStart)
//                                               userInfo: nil
//                                                repeats: YES];
    }
    
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
    self.navigationController.toolbar.translucent   = YES;
    [self.navigationController setToolbarHidden:NO animated:animated];
    //self.mapView.showsUserLocation = YES;
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
