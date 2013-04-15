//
//  DataModel.h
//  BaiduMapAddCustomBubble
//
//  Created by liu on 4/9/13.
//  Copyright (c) 2013 liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModel : NSObject

@end

//mapList info
@interface mapList : NSObject
{
    NSString    *locaID;          //location ID
    NSString    *locaTel;         //tel
    NSString    *x;               //location in map's coordinate x
    NSString    *y;               //location in map's coordinate y
    NSString    *locaDec;         //description
    NSDate      *locaDate;        //date
}

@property (nonatomic, retain)NSString    *locaID;
@property (nonatomic, retain)NSString    *locaTel;
@property (nonatomic, retain)NSString    *x;
@property (nonatomic, retain)NSString    *y;
@property (nonatomic, retain)NSString    *locaDec;
@property (nonatomic, retain)NSDate      *locaDate;

@end


//userlocation info
@interface userLocation : NSObject
{
    NSString    *tel;             //tel
    NSString    *x;               //location in user coordinate x
    NSString    *y;               //location in user coordinate y

}
@property (nonatomic, retain)NSString    *tel;
@property (nonatomic, retain)NSString    *x;
@property (nonatomic, retain)NSString    *y;

@end