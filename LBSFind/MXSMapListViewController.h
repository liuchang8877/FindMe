//
//  MXSMapListViewController.h
//  xzyApp
//
//  Created by liu on 3/21/13.
//  Copyright (c) 2013 rbyyy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAMapKit.h"
#import "MASearch.h"

@class ASIHTTPRequest;
@class mapList;
@class BaseMapViewController;
@class BaseSearchViewController;
@interface MXSMapListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,MAMapViewDelegate,MASearchDelegate>
{
     UITableView * myTableView;
     NSMutableArray *xzMapArray;       //save map info
     //BOOL  searchFlag;                  //when search is YES
     mapList *mapListForView;           // map info
     //NSMutableArray  *myMapInfoArry;
     NSMutableArray *myMapInfoArry;
 
     MAMapView  * myMainMapView;
    
     BaseMapViewController *subViewController;

     BaseSearchViewController *subSearchController;
}

@property (retain, nonatomic) ASIHTTPRequest  *myRequest;
@property (weak, nonatomic) IBOutlet UISearchBar *localSearch;

@end
