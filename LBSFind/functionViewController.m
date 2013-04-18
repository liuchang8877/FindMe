//
//  functionViewController.m
//  LBSFind
//
//  Created by liu on 4/16/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import "functionViewController.h"
#import "BaseSearchViewController.h"
#import "BaseMapViewController.h"
#import "ViewController.h"
#import "DataModel.h"
#import "tool.h"
#import "allConfig.h"

@interface functionViewController ()
{
        UITableView * myTableView;
    
        MAMapView  * myMainMapView;
    
        BaseMapViewController *subViewController;
    
        BaseSearchViewController *subSearchController;
    
        int  openOrCloseUserLocationUpdate;
    
        NSTimer *timer;
}

@property (nonatomic, strong) MASearch *search;

@end

@implementation functionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initTheMap];
        
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        //[self initTheMap];
    }
    
    return self;
}

#pragma mark VIEW START
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    //openOrCloseUserLocationUpdate = [[NSUserDefaults standardUserDefaults] integerForKey: OPEN_CLOSE_LOCATION];
    openOrCloseUserLocationUpdate = 0;
    
    //[self openUserLocation];
    
    [self setTheTableView];
}

//- (void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    
//    /* Reset map view. */
//    myMainMapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 272496, 466656);
//    
//    //self.mapView.rotationDegree = 0.f;
//    
//    [myMainMapView removeAnnotations:myMainMapView.annotations];
//    
//    [myMainMapView removeOverlays:myMainMapView.overlays];
//    
//    myMainMapView.delegate = nil;
//    
//    /* Remove from view hierarchy. */
//    [myMainMapView removeFromSuperview];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark INIT_MAP
- (void)initTheMap{
    
    myMainMapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    //myMainMapView.mapType = MAMapTypeStandard;
    myMainMapView.delegate = self;
    
    CLLocationCoordinate2D center = {39.91669,116.39716};
    MACoordinateSpan span = {0.04,0.03};
    MACoordinateRegion region = {center,span};
    [myMainMapView setRegion:region animated:NO];
    
    self.search = [[MASearch alloc] initWithSearchKey:SearchKey Delegate:self];
    
    subViewController = [[BaseMapViewController alloc] init];
    [subViewController setMapView:myMainMapView];
    subSearchController = [[BaseSearchViewController alloc]init];
    [subSearchController setSearch:self.search];
    
}


#pragma mark UITableView

//init the table view
- (void)setTheTableView{
    //set the table view
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height - 40) style:UITableViewStyleGrouped];
    myTableView.backgroundColor = [UIColor clearColor];
    [myTableView setDelegate:self];
    [myTableView setDataSource:self];
    myTableView.backgroundView = nil;
    myTableView.backgroundColor = [UIColor colorWithRed:244.0/255 green:226.0/255 blue:185.0/255 alpha:1];
    myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:myTableView];
}

//set the number of section in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//set the heigh of  between the section
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if (section == 0)
        return 10;
    else
        return 10;
}

//set the height of every row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 60;
    else if (indexPath.section == 1)
        return 70;
    else
        return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //set the rows number of every section
    if (section == 0)
        return  10;
    else if (section == 1)
        return 1;
    return 0;
}

//init the cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"identifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    cell.textLabel.font = [UIFont boldSystemFontOfSize: 15];
    cell.detailTextLabel.font = [UIFont systemFontOfSize: 13];
    cell.accessoryType = UITableViewCellAccessoryNone;
    //set the backgroundColor
    //cell.backgroundColor = [UIColor colorWithRed:244.0/255 green:226.0/255 blue:185.0/255 alpha:1];
    [self setTheCell:cell indexPath:indexPath];
    
    //[self loadTheView:cell];
    //}
    return cell;
}

//init the cell
- (void)setTheCell:(UITableViewCell*)cell indexPath:(NSIndexPath *)indexPath
{
    //[self getTheMapData];
    
//    if (indexPath.row < [xzMapArray count]) {
//        mapListForView = (mapList *)[xzMapArray objectAtIndex:indexPath.row];
//        
//        //title
//        UILabel *titleInfoName = [[UILabel alloc]initWithFrame:CGRectMake(68, 10, 340, 45)];
//        [titleInfoName setFont:[UIFont boldSystemFontOfSize: 20]];
//        [titleInfoName setTextColor:[UIColor colorWithRed:183.0/255 green:129.0/255 blue:50.0/255 alpha:1]];
//        titleInfoName.text = mapListForView.locaTel;
//        titleInfoName.backgroundColor = [UIColor clearColor];
//        [cell addSubview:titleInfoName];
//    }
    
    NSString *titleText;
    
    if (indexPath.row == 0)  {

        titleText = @"实时定位";
        
    } else if (indexPath.row == 1) {
    
        titleText = @"安全路线";
    } else if (indexPath.row == 2) {
        
        titleText = @"圆形围栏";
        
    } else if (indexPath.row == 3) {
    
        titleText = @"矩形围栏";
    } else if (indexPath.row == 4) {
        
        //set userlocation update or not
        
        if (openOrCloseUserLocationUpdate) {
             //open
            UIButton *ButtonUserLocation = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            ButtonUserLocation.frame = CGRectMake(78, 10, 150, 30);
            ButtonUserLocation.backgroundColor = [UIColor clearColor];
            [ButtonUserLocation setTitle:@"关闭本机定位" forState:UIControlStateNormal];
            ButtonUserLocation.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
            [ButtonUserLocation setBackgroundImage:[UIImage imageNamed:@"28.png"] forState:UIControlStateNormal];
            [cell addSubview:ButtonUserLocation];
            [ButtonUserLocation addTarget:self action:@selector(openUserLocation) forControlEvents:UIControlEventTouchDown];
            return;
        
        } else {
            
            //close
            UIButton *ButtonUserLocation = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            ButtonUserLocation.frame = CGRectMake(78, 10, 150, 30);
            ButtonUserLocation.backgroundColor = [UIColor clearColor];
            [ButtonUserLocation setTitle:@"开启本机定位" forState:UIControlStateNormal];
            ButtonUserLocation.titleLabel.font = [UIFont fontWithName:@"helvetica" size:12];
            [ButtonUserLocation setBackgroundImage:[UIImage imageNamed:@"28.png"] forState:UIControlStateNormal];
            [cell addSubview:ButtonUserLocation];
            [ButtonUserLocation addTarget:self action:@selector(openUserLocation) forControlEvents:UIControlEventTouchDown];
            return;
        
        }

    }
    
    //title
    UILabel *titleInfoName = [[UILabel alloc]initWithFrame:CGRectMake(98, 10, 340, 45)];
    [titleInfoName setFont:[UIFont boldSystemFontOfSize: 20]];
    [titleInfoName setTextColor:[UIColor colorWithRed:183.0/255 green:129.0/255 blue:50.0/255 alpha:1]];
    titleInfoName.text = titleText;
    titleInfoName.backgroundColor = [UIColor clearColor];
    [cell addSubview:titleInfoName];
}

- (void)openUserLocation {
    
    if (openOrCloseUserLocationUpdate) {
        
        //close
        [timer setFireDate:[NSDate distantFuture]];
        
        //[[NSUserDefaults standardUserDefaults]setInteger:0 forKey:OPEN_CLOSE_LOCATION];
        myMainMapView.showsUserLocation = NO;
        openOrCloseUserLocationUpdate = 0;

        [tool waringInfo:@"关闭成功"];
    } else {
        
        timer = [NSTimer scheduledTimerWithTimeInterval: 15.5
                                                 target: self
                                               selector: @selector(startSetUserLocation)
                                               userInfo: nil
                                                repeats: YES];
        
         // open
        [timer setFireDate:[NSDate distantPast]];
        
        if ([timer isValid]) {
            
            //[[NSUserDefaults standardUserDefaults]setInteger:1 forKey:OPEN_CLOSE_LOCATION];
            myMainMapView.showsUserLocation = YES;
            openOrCloseUserLocationUpdate = 1;
            [tool waringInfo:@"开启成功"];
        }
    }
    
    [myTableView reloadData];
}

- (void)startSetUserLocation {
    
    //myMainMapView.showsUserLocation = YES;
    myMainMapView.userTrackingMode = MAUserTrackingModeFollow;
    
    //jump to  the user location
    if (myMainMapView.userLocation != nil && myMainMapView.userLocation.coordinate.latitude != 0.0 &&myMainMapView.userLocation.coordinate.longitude != 0.0) {
        
        [myMainMapView setCenterCoordinate:myMainMapView.userLocation.coordinate];
        NSLog(@"x:%f---y:%f",myMainMapView.userLocation.coordinate.latitude,myMainMapView.userLocation.coordinate.longitude);
        userLocation *myLocation = [[userLocation alloc] init];
        
        myLocation.tel = [[NSUserDefaults standardUserDefaults] objectForKey:TEL];
        myLocation.x = [NSString stringWithFormat:@"%f",myMainMapView.userLocation.coordinate.longitude];
        myLocation.y = [NSString stringWithFormat:@"%f",myMainMapView.userLocation.coordinate.latitude];
        [self setTheLocation:myLocation];
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

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"setTheLogin---error:%@",error);
    [tool checkNetAlter];
}


#pragma  mark did selected
//did selected
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Custom initialization
    //[self initTheMap];
    
    NSLog(@"didSelectRowAtIndexPath---row:%d",indexPath.row);

    ViewController *mapFindView = [[ViewController alloc]init];
    mapFindView.search = subSearchController.search;
    [mapFindView setMapView:subViewController.mapView];
    [mapFindView setFunctionFlag:[NSString stringWithFormat:@"%d",indexPath.row]];
    [self.navigationController pushViewController:mapFindView animated:YES];
    
}

@end
