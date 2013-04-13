//
//  DBHandleDAO.m
//  BaiduMapAddCustomBubble
//
//  Created by liu on 4/9/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import "DBHandleDAO.h"
#import "FMDatabase.h"
#import "allConfig.h"
#import "DataModel.h"


@implementation DBHandleDAO

static NSString *filePaths;
static FMDatabase *db;

//get the file path
+(NSString *)dataFilePath {
    if(filePaths==nil){
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		filePaths=[documentsDirectory stringByAppendingPathComponent:DB_FILE_NAME];
	}
    return filePaths;
}

//get the db obj
+(FMDatabase *)getDb{
    if(db==nil)
        db = [FMDatabase databaseWithPath:[DBHandleDAO dataFilePath]];
	return db;
}

#pragma mark MAPLIST CREAT
//create the table of the maplist table
+(void)createMapListTable
{
    FMDatabase *db = [DBHandleDAO getDb];
	[db open];
	 BOOL upResult = [db executeUpdate:@"create table maplist(id integer primary key AUTOINCREMENT, locaTel text,x text,y text,locaDec text,locaDate date)"];
    
    //check his result
    if (upResult)
        NSLog(@"createMapListTable---creat maplist ok!");
    else
        NSLog(@"createMapListTable---creat maplist error!");
    [db close];
}

#pragma mark MAPLIST INSERT
//insert the data to the maplist
+(void)insertDataToMapListTable:(NSMutableArray *)MapArray
{
    BOOL resultInsert;
    FMDatabase *db = [DBHandleDAO getDb];
	[db open];
    
    for (int i=0; i<[MapArray count]; i++) {
        
        mapList *xzMapObj = [MapArray objectAtIndex:i];
        resultInsert = [db executeUpdate:@"insert into maplist (locaTel, x, y, locaDec, locaDate) values (?,?,?,?,?)",xzMapObj.locaTel,xzMapObj.x, xzMapObj.y, xzMapObj.locaDec, xzMapObj.locaDate];
	}
	[db close];
    
    if (resultInsert) {
        
        NSLog(@"insertDataToMapListTable---insert ok");
    } else {
    
        NSLog(@"insertDataToMapListTable---insert error");
    }
}

#pragma mark MAPLIST SEARCH
//get the maplistinfo
+(NSMutableArray *)getMapListInfo
{
    FMDatabase *db = [DBHandleDAO getDb];
	[db open];
    NSMutableArray *MapArray = [[NSMutableArray alloc] initWithCapacity:1];
	FMResultSet *MapSet = [db executeQuery:@"select * from maplist"];
    //find info
	while ([MapSet next] ) {
        NSString *tempID = [MapSet stringForColumn:@"id"];
        NSString *tempTel =[MapSet stringForColumn:@"locaTel"];
        NSString *tempX = [MapSet stringForColumn:@"x"];
        NSString *tempY =[MapSet stringForColumn:@"y"];
        NSString *templocaDec =[MapSet stringForColumn:@"locaDec"];
        NSDate *tempLocaDate = [MapSet dateForColumn:@"locaDate"];
        
        //copy the temp info to class and class to the array
        mapList *myMapList = [[mapList alloc] init];
        myMapList.locaID    = tempID;
        myMapList.locaTel   = tempTel;
        myMapList.x         = tempX;
        myMapList.y         = tempY;
        myMapList.locaDec   = templocaDec;
        myMapList.locaDate  = tempLocaDate;

        [MapArray addObject:myMapList];
	}
    
	[MapSet close];
	[db close];
    return MapArray;
}

#pragma mark MAPLIST SEARCH BY
//get the info with id
+(NSMutableArray *)getMapListInfoWithID:(NSString *)locaID
{
    FMDatabase *db = [DBHandleDAO getDb];
	[db open];
    NSMutableArray *MapArray = [[NSMutableArray alloc] initWithCapacity:1];
    NSString *mySql = [NSString stringWithFormat:@"select * from maplist where id == '%@'",locaID];
	FMResultSet *MapSet = [db executeQuery:mySql];
    //find info
	while ([MapSet next] ) {
        NSString *tempID = [MapSet stringForColumn:@"id"];
        NSString *tempTel =[MapSet stringForColumn:@"locaTel"];
        NSString *tempX = [MapSet stringForColumn:@"x"];
        NSString *tempY =[MapSet stringForColumn:@"y"];
        NSString *templocaDec =[MapSet stringForColumn:@"locaDec"];
        NSDate *tempLocaDate = [MapSet dateForColumn:@"locaDate"];
        
        //copy the temp info to class and class to the array
        mapList *myMapList = [[mapList alloc] init];
        myMapList.locaID    = tempID;
        myMapList.x         = tempX;
        myMapList.y         = tempY;
        myMapList.locaDec   = templocaDec;
        myMapList.locaDate  = tempLocaDate;
        myMapList.locaTel   = tempTel;
        
        [MapArray addObject:myMapList];
	}
    
	[MapSet close];
	[db close];
    return MapArray;
    
}

#pragma mark MAPLIST DELETE
//delete the maplist Info
+(void)deleteDataFromMapListTable
{
    FMDatabase *db = [DBHandleDAO getDb];
	[db open];
	[db executeUpdate:@"delete from maplist"];
    if ([db hadError]) {
		NSLog(@"deleteDataFromMapListTable---Err:%d:%@", [db lastErrorCode], [db lastErrorMessage]);
	} else {
        NSLog(@"deleteDataFromMapListTable---delete ok");
        
    }
	[db close];
}

@end
