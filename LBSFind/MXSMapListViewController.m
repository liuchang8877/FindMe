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
#import "tool.h"
#import "ASIHTTPRequest.h"
#import "DataModel.h"
#import "allConfig.h"
#import "functionViewController.h"
#import "SBJson.h"



@interface MXSMapListViewController ()
{
    NSMutableArray   *findTelArr;

}

@property (nonatomic, strong) MASearch *search;
@property (nonatomic, strong) NSMutableArray   *findTelArr;

@end

@implementation MXSMapListViewController
@synthesize search     = _search;
@synthesize findTelArr = _findTelArr;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
        [self GetTheRelationInfo];
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

     //[self GetTheRelationInfo];
}

- (void)GetTheRelationInfo
{
    // get the relation
    userInfo *myUserInfo = [[userInfo alloc] init];
    
    myUserInfo.name = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
    myUserInfo.pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PWD];
    
    [self getTheRelation:myUserInfo];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set the flag for get relation
    getOrSetRelationFlag = 1;
    
    // init the arr for save the find tel
    _findTelArr  = [[NSMutableArray alloc] initWithCapacity:2];
    
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
    //[self initTheAllData];
    
    [self getTheMapData];
    //init the Map 
    //[self initTheMap];
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
    //[authController release];
    
       //return back
      [self.navigationController popViewControllerAnimated:YES];
    
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
    //delete the all info when get relation
    if (getOrSetRelationFlag) {
        
        [DBHandleDAO deleteDataFromMapListTable];
    }
    
    NSMutableArray *myMapListArr  = [[NSMutableArray alloc] initWithCapacity:5];
    
    for (int i = 0; i < [_findTelArr count]; i++) {
        
        mapList *myMapList = [[mapList alloc]init];
        myMapList.locaTel = [_findTelArr objectAtIndex:i];
        myMapList.locaDec = @"kaishi";
        myMapList.locaDate = [NSDate date];
        myMapList.x = @"34.405840";
        myMapList.y = @"113.733796";
        [myMapListArr addObject:myMapList];
    
    }
    
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
    functionViewController *mapFunctionView = [[functionViewController alloc]init];
    [self.navigationController pushViewController:mapFunctionView animated:YES];
    if (indexPath.row < [xzMapArray count]) {
  
        mapList *mapListForDidSelected = (mapList*)[xzMapArray objectAtIndex:indexPath.row];
        // set the find tel
        [[NSUserDefaults standardUserDefaults] setObject:mapListForDidSelected.locaTel forKey:FINDTEL];
    }
//    ViewController *mapFindView = [[ViewController alloc]init];
//    mapFindView.search = subSearchController.search;
//    [mapFindView setMapView:subViewController.mapView];
//    [self.navigationController pushViewController:mapFindView animated:YES];

}

//// remove the high light row
//-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 0 )
//        return FALSE;
//    else
//        return TRUE;
//}


#pragma mark http for setTheRelation
- (void)setTheRelation:(userInfo *)myUser
{
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    // se the flag
    getOrSetRelationFlag = 0;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=setrelation&user=%@&pwd=%@&tel=%@",URL_IP,URL_PORT,myUser.name,myUser.pwd,myUser.findTel];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *myRequest;
    NSLog(@"setTheLogin---url:%@",url);
    if ([tool checkNet])
    {
        NSLog(@"setTheLogin---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
        //        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
        //        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
        
    } else {
        
        NSLog(@"setTheLogin---net is NOT ok");
        [tool checkNetAlter];
    }
}

#pragma mark http for getTheRelation
- (void)getTheRelation:(userInfo *)myUser
{
    //[SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    // se the flag
    getOrSetRelationFlag = 1;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:%@/test/lbs/do.php?action=getrelation&user=%@&pwd=%@",URL_IP,URL_PORT,myUser.name,myUser.pwd];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *myRequest;
    NSLog(@"getTheRelation---url:%@",url);
    if ([tool checkNet])
    {
        NSLog(@"getTheRelation---net is ok");
        [myRequest setDelegate:nil];
        [myRequest cancel];
        myRequest = [ASIHTTPRequest requestWithURL:url];
        [myRequest setDelegate:self];
        //        [myRequest setDidFailSelector:@selector(userLocationRequestFinished:)];
        //        [myRequest setDidFinishSelector:@selector(userLocationRequestFailed:)];
        [myRequest startAsynchronous];
        
    } else {
        
        NSLog(@"getTheRelation---net is NOT ok");
        [tool checkNetAlter];
    }
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    // set the relation
    NSString *responseString=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    
    NSLog(@"requestFinished---responseString:%@",responseString);
    
    NSLog(@"%d",[request responseStatusCode]);
    
    if (getOrSetRelationFlag) {
        
        // get relation
        if ([request responseStatusCode] == 200) {
            // this is mean it is ok
            
            NSString *responseString=[[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
            
            SBJsonParser * parser = [[SBJsonParser alloc] init];
            NSError * error = nil;
            NSMutableDictionary *jsonDic = [parser objectWithString:responseString error:&error];
            NSMutableArray * ArrRetInfo = [jsonDic objectForKey:@"getrelation"];
            
            NSString* findTel;
            
            //clean the arr
            [findTelArr removeAllObjects];
            
            for (int i = 0 ; i < [ArrRetInfo count]; i++) {
                
                findTel     = [[ArrRetInfo objectAtIndex:i] objectForKey:@"tel"];
                [_findTelArr addObject:findTel];
            }
            
            //init the data
            [self initTheAllData];
            
            //get the data from db
            [self getTheMapData];
            
            //init the Map
            //[self initTheMap];
            
            [myTableView reloadData];
            
        } else {
            
            // it is wrong  in login
            [tool waringInfo:@"更新失败"];
            
        }
    
    } else {
        
        if ([request responseStatusCode] == 200) {
            // this is mean it is ok
            
            [tool waringInfo:@"查询到该号码信息"];
            
            // Custom initialization
            [self GetTheRelationInfo];
            
            //[myTableView reloadData];
            
            //        //init the data
            //        [self initTheAllData];
            //
            //        //get the data from db
            //        [self getTheMapData];
            //
            //        //init the Map
            //        [self initTheMap];
            //
            //        [myTableView reloadData];
            
        } else {
            // it is wrong  in login
            
            [tool waringInfo:@"请确认查询号码"];
            
        }
        
//        //init the data
//        [self initTheAllData];
//        
//        //get the data from db
//        [self getTheMapData];
//        
//        //init the Map
//        [self initTheMap];
        [myTableView reloadData];
    }
       
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"requestFailed---error:%@",error);
    [tool checkNetAlter];
}



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
    
    NSLog(@"doSearch---%@,length:%d",searchBar.text,[searchBar.text length]);

    //xzMapArray = [NSMutableArray arrayWithArray:[MXSHandleDao getXZMapLocationInfoWithName:searchBar.text]];
    if ([searchBar.text length] != 11) {
        // it is not a  phone number
        
        [tool waringInfo:@"请确认输入的号码无误"];
    
    } else  {
        
        //set the relation
        userInfo *myUserInfo = [[userInfo alloc] init];
        
        myUserInfo.name = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
        myUserInfo.pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PWD];
        myUserInfo.findTel = searchBar.text;
        
        //set the find tel for insert to the table
        theFindTel = searchBar.text;
        
        //remove the arr object and add one
        [findTelArr removeAllObjects];
        
        [_findTelArr addObject:theFindTel];
        
        [self setTheRelation:myUserInfo];

    }
    
    //[myTableView reloadData];

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
