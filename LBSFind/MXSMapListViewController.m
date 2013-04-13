//
//  MXSMapListViewController.m
//  xzyApp
//
//  Created by liu on 3/21/13.
//  Copyright (c) 2013 rbyyy. All rights reserved.
//

#import "MXSMapListViewController.h"
//#import "GeocodeDemoViewController.h"
#import "DataModel.h"
#import "DBHandleDAO.h"
#import "ViewController.h"
#import "BaseSearchViewController.h"
#import "BaseMapViewController.h"



@interface MXSMapListViewController ()

@property (nonatomic, strong) MASearch *search;

@end

@implementation MXSMapListViewController
@synthesize myRequest;
@synthesize search    = _search;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma  mark VIEW_START

- (void)viewWillAppear:(BOOL)animated
{
//    NSLog(@"user %@", self.user);
//    
//    if (self.user == nil){
//        NSLog(@"No user, authenticating");
//        LSAuthenticateViewController *authController = [[LSAuthenticateViewController alloc] initWithNibName:@"LSAuthenticateViewController" bundle:nil];
//        authController.delegate = self;
//        
//        [self presentModalViewController:authController animated:YES];
//        //[authController release];
//        
//    }else{
//        // If we have a user stored on the controller, then put the username into a label for display.
//        //self.usernameLabel.text = self.user.username;
//    }


}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor colorWithRed:244.0/255 green:226.0/255 blue:185.0/255 alpha:1]];
    
    //init the left button to back
    [self defineNavBackButton];
    //init the table view
    [self setTheTableView];
    //search bar
    _localSearch.delegate = self;
    _localSearch.placeholder = @"查询";
    //Set the search bar background transparent
    [[_localSearch.subviews objectAtIndex:0]removeFromSuperview];
    //set the right button
    [self setTheRightButton];
    
    //init the data
    [self initTheAllData];
    
    [self getTheMapData];
    //init the Map 
    [self initTheMap];
}
#pragma mark INIT_MAP
- (void)initTheMap{
    
    myMainMapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    myMainMapView.mapType = MAMapTypeStandard;
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
//add the button to  the navigation bar
- (void)setTheRightButton
{
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 51, 30)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.tag = 0;
    button.frame = CGRectMake(0, 0, 51, 30);
    //[button setBackgroundImage:[UIImage imageNamed:@"xz_nav_cancel.png"] forState:UIControlStateNormal];
    //[button setBackgroundImage:[UIImage imageNamed:@"xz_nav_cancel_down.png"] forState:UIControlStateHighlighted];
    [button setTitle:@"注销" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onclickRightButton) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:button];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

//click right button
- (void)onclickRightButton
{
    //find all
    //searchFlag = NO;
    //[self getTheMapData];
    //[myTableView reloadData];
    //self.usernameLabel.text = nil;
//    self.user = nil;
//    
//    // Show the authentication controller since we no longer have a user
//    LSAuthenticateViewController *authController = [[LSAuthenticateViewController alloc] initWithNibName:@"LSAuthenticateViewController" bundle:nil];
//    authController.delegate = self;
//    [self presentModalViewController:authController animated:YES];
    //[authController release]; ;
}

//init the table view
- (void)setTheTableView{
    //set the table view
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,40,self.view.frame.size.width,self.view.frame.size.height - 160) style:UITableViewStyleGrouped];
    myTableView.backgroundColor = [UIColor clearColor];
    [myTableView setDelegate:self];
    [myTableView setDataSource:self];
    myTableView.backgroundView = nil;
    myTableView.backgroundColor = [UIColor colorWithRed:244.0/255 green:226.0/255 blue:185.0/255 alpha:1];
    myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:myTableView];
}

- (void)setTheSearch
{
    _localSearch.delegate = self;
    
}

#pragma mark GET DATA FROM DB
- (void) getTheMapData
{

    xzMapArray = [DBHandleDAO getMapListInfo];

}
//定义返回按钮
- (void)defineNavBackButton
{
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 51, 30)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 0;
    button.frame = CGRectMake(0, 0, 51, 30);
    [button setBackgroundImage:[UIImage imageNamed:@"xz_nav_back_btn.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"xz_nav_back_btn_down.png"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:button];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    self.navigationItem.leftBarButtonItem = leftBarButton;
}
//返回事件
- (IBAction)backButtonClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma UITableView
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

#pragma  mark INIT_DATA
//init the data from server
- (void)initTheAllData{
    

    [DBHandleDAO createMapListTable];
    
    NSMutableArray *myMapListArr  = [[NSMutableArray alloc] initWithCapacity:5];
    
    mapList *myMapList = [[mapList alloc]init];
    myMapList.locaTel = @"13633841517";
    myMapList.locaDec = @"kaishi";
    myMapList.locaDate = [NSDate date];
    myMapList.x = @"34.405840";
    myMapList.y = @"113.733796";
    //X:34.405840,Y:113.733796 新郑轩辕皇帝故里
    [myMapListArr addObject:myMapList];
    
    [DBHandleDAO insertDataToMapListTable:myMapListArr];
    
    NSMutableArray *MapListInfoArr = [DBHandleDAO getMapListInfo];
    
    if ([MapListInfoArr count] > 0) {
        mapList *myListInfo = [MapListInfoArr objectAtIndex:0];
        NSLog(@"myListInfo,tel:%@,dec:%@",myListInfo.locaTel,myListInfo.locaDec);
    }
    
    //[DBHandleDAO deleteDataFromMapListTable];
//    
//    NSMutableArray *MapListInfoArr2 = [DBHandleDAO getMapListInfo];
//    
//    if ([MapListInfoArr2 count] > 0) {
//        mapList *myListInfo2 = [MapListInfoArr2 objectAtIndex:0];
//        NSLog(@"myListInfo,tel:%@,dec:%@",myListInfo2.locaTel,myListInfo2.locaDec);
//    }
    
//    if ([MXSTool checkNet]) {
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:mapFirst])
//        {
//            [MXSHandleDao createXZMapLocationTable];
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:mapFirst];
//            //[self setTheDBinfo];
//        }
//        [self setTheDBinfo];
//    } else {
//        [MXSTool checkNetAlter];
//    }
    
}

//init the cell
- (void)setTheCell:(UITableViewCell*)cell indexPath:(NSIndexPath *)indexPath
{
    //[self getTheMapData];
    
    if (indexPath.row < [xzMapArray count]) {
        mapListForView = (mapList *)[xzMapArray objectAtIndex:indexPath.row];

        //title
        UILabel *titleInfoName = [[UILabel alloc]initWithFrame:CGRectMake(68, 10, 340, 45)];
        [titleInfoName setFont:[UIFont boldSystemFontOfSize: 20]];
        [titleInfoName setTextColor:[UIColor colorWithRed:183.0/255 green:129.0/255 blue:50.0/255 alpha:1]];
        titleInfoName.text = mapListForView.locaTel;
        titleInfoName.backgroundColor = [UIColor clearColor];
        [cell addSubview:titleInfoName];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSLog(@"didSelectRowAtIndexPath---row:%d",indexPath.row);
    
    ViewController *mapFindView = [[ViewController alloc]init];
    mapFindView.search = subSearchController.search;
    [mapFindView setMapView:subViewController.mapView];
    [self.navigationController pushViewController:mapFindView animated:YES];

}

//// remove the high light row
//-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0 )
//        return FALSE;
//    else
//        return TRUE;
//}

#pragma mark search bar
//start to  search
/*search  Cancel button*/
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //	[self doSearch:searchBar];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

/*keyboard search button*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	
    [searchBar resignFirstResponder];
	[self doSearch:searchBar];
}

/*search*/
- (void)doSearch:(UISearchBar *)searchBar{
    
    NSLog(@"doSearch---%@",searchBar.text);

    //xzMapArray = [NSMutableArray arrayWithArray:[MXSHandleDao getXZMapLocationInfoWithName:searchBar.text]];

    [myTableView reloadData];

}

//begein
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

//end editing
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
//    [myRequest setDelegate:nil];
//    [myRequest cancel];
    [self setLocalSearch:nil];
    [super viewDidUnload];
}

#pragma data
- (void) setTheDBinfo
{
    
    //    X:34.405840,Y:113.733796 新郑轩辕皇帝故里
    //    X:34.531461,Y:113.852597 新郑国际机场
    //    X:34.401350,Y:113.743345 炎黄广场
    //    X:34.391103,Y:113.742527 新郑郑王陵博物馆

//    [MXSHandleDao deleteDataFromXZMapLocationTable];
//
//    [SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    [self getTheMapInfo];
}

#pragma mark http for map info
- (void)getTheMapInfo
{
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
//    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/zw1/do.php?action=getmapinfo&clienttype=%@",URL_IP,URL_PORT,@"ios"];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    //NSURL  *url =[NSURL URLWithString:@"http://firefrog.sinaapp.com/xzyApp/mapInfo.html"];
//    
//    NSLog(@"MXSMapListViewController---url:%@",url);
//    if ([MXSTool checkNet])
//    {
//        NSLog(@"MXSMapListViewController---net is ok");
//        [myRequest setDelegate:nil];
//        [myRequest cancel];
//        myRequest = [ASIHTTPRequest requestWithURL:url];
//        [myRequest setDelegate:self];
//        [myRequest startAsynchronous];
//        
//    } else {
//        
//        NSLog(@"MXSMapListViewController---net is NOT ok");
//        [MXSTool checkNetAlter];
//    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    
    // Use when fetching binary data
    //NSData *responseData = [request responseData];
    
//    NSString *responseString=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
//    
//    NSLog(@"MXSMapListViewController---responseString:%@",responseString);
//    
//    SBJsonParser * parser = [[SBJsonParser alloc] init];
//    NSError * error = nil;
//    NSMutableDictionary *jsonDic = [parser objectWithString:responseString error:&error];
//    
//    NSMutableDictionary * dicRetInfo = [jsonDic objectForKey:@"ret"];
//    NSLog(@"MXSMapListViewController---dicUserInfo:%@",[dicRetInfo objectForKey:@"result"]);
//    mapInfo *myMap = [[mapInfo alloc] init];
//    myMapInfoArry = [[NSMutableArray alloc]initWithCapacity:2];
//    myMap.result = [dicRetInfo objectForKey:@"result"];
//    myMap.msg = [dicRetInfo objectForKey:@"msg"];
//    NSLog(@"MXSMapListViewController---Result:%@,Msg:%@",myMap.result,myMap.msg);
//    [myMapInfoArry addObject:myMap];
//    for (NSMutableDictionary * dicLoginInfo in [jsonDic objectForKey:@"getmapinfo"])
//    {
//        mapInfo *myMapInfo  = [[mapInfo alloc] init];
//        myMapInfo.mapID  = [dicLoginInfo objectForKey:@"id"];
//        myMapInfo.mapLongitude  = [dicLoginInfo objectForKey:@"longitude"];
//        myMapInfo.mapLatitude  = [dicLoginInfo objectForKey:@"latitude"];
//        myMapInfo.tel  = [dicLoginInfo objectForKey:@"tel"];
//        myMapInfo.title  = [dicLoginInfo objectForKey:@"title"];
//        NSLog(@"MXSMapListViewController---id:%@,x:%@,y:%@,tel:%@,title:%@",myMapInfo.mapID,myMapInfo.mapLongitude,myMapInfo.mapLatitude,myMapInfo.tel,myMapInfo.title);
//        [myMapInfoArry addObject:myMapInfo];
//    }
//    
//    //myMapInfoArry = [NSArray arrayWithArray:mapArray];
//    [self insertTheInfoToDB];
//    [SVProgressHUD dismiss];
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
//    NSError *error = [request error];
//    NSLog(@"MXSMapListViewController---error:%@",error);
//    [SVProgressHUD dismiss];
//    
//    [MXSTool checkNetAlter];
}

// load the info to the db
- (void)insertTheInfoToDB{

//    NSString *mapResult;
//    NSString *mapMsg;
//    NSMutableArray * mapArry = [[NSMutableArray alloc] initWithCapacity:2];
//    //NSMutableArray *mapArray
//    for (int i = 0; i < [myMapInfoArry count]; i++) {
//        mapInfo *myMapInfo = [myMapInfoArry objectAtIndex:i];
//        if (i == 0) {
//            mapResult = myMapInfo.result;
//            mapMsg  = myMapInfo.msg;
//            NSLog(@"setTheDBinfo---result:%@,msg:%@",myMapInfo.result,myMapInfo.msg);
//        }
//        
//        if ([mapResult isEqualToString:@"1"] && i != 0) {
//            
//            xzMapLocation *myMap = [[xzMapLocation alloc]init];
//            myMap.name = myMapInfo.title;
//            myMap.locaTel = myMapInfo.tel;
//            myMap.x  = myMapInfo.mapLongitude;
//            myMap.y  = myMapInfo.mapLatitude;
//            //myMap.locaImage = [@"YOU ARE RIGHT" dataUsingEncoding:NSUTF8StringEncoding];
//            UIImage * localPhoto = [UIImage imageNamed:@"hdgl.png"];
//            myMap.locaImage = UIImagePNGRepresentation(localPhoto);
//            myMap.locaDec = nil;
//            myMap.locaDate = [NSDate date];
//            //NSMutableArray * mapArry = [[NSMutableArray alloc] init];
//            [mapArry addObject:myMap];
//   
//        }
//    }
//    
//    //insert
//    BOOL reInsert = [MXSHandleDao insertDataToXZMapLocationTable:mapArry];
//    if (reInsert) {
//        NSLog(@"insert ok date:%@",[NSDate date]);
//    } else {
//        NSLog(@"insert error ");
//    }
//    
//    //set the map data
//    xzMapArray =[[NSMutableArray alloc] initWithCapacity:2];
//    [self getTheMapData];
//    
//    //reload the data
//    [myTableView reloadData];
}

@end
