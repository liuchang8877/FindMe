//
//  DBHandleDAO.h
//  BaiduMapAddCustomBubble
//
//  Created by liu on 4/9/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBHandleDAO : NSObject

//create the table of the maplist table
+(void)createMapListTable;
//insert the data to the maplist
+(void)insertDataToMapListTable:(NSMutableArray *)MapArray;
//get the maplistinfo
+(NSMutableArray *)getMapListInfo;
//get the info with id
+(NSMutableArray *)getMapListInfoWithID:(NSString *)locaID;
//delete the maplist Info
+(void)deleteDataFromMapListTable;
@end
