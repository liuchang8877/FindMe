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

// userInfo
@interface userInfo : NSObject
{
    NSString    *name;             
    NSString    *tel;              
    NSString    *pwd;
    NSString    *anPwd;
    NSString    *findTel;
    
    
}
@property (nonatomic, retain)NSString    *name;
@property (nonatomic, retain)NSString    *tel;
@property (nonatomic, retain)NSString    *pwd;
@property (nonatomic, retain)NSString    *anPwd;
@property (nonatomic, retain)NSString    *findTel;

@end

// RectInfo
@interface RectInfo : NSObject
{
    NSString    *x1;
    NSString    *y1;
    NSString    *x2;
    NSString    *y2;
    NSString    *x3;
    NSString    *y3;
    NSString    *x4;
    NSString    *y4;
    
    
}

@property (nonatomic, retain)NSString    *x1;
@property (nonatomic, retain)NSString    *y1;
@property (nonatomic, retain)NSString    *x2;
@property (nonatomic, retain)NSString    *y2;
@property (nonatomic, retain)NSString    *x3;
@property (nonatomic, retain)NSString    *y3;
@property (nonatomic, retain)NSString    *x4;
@property (nonatomic, retain)NSString    *y4;

@end

// LineNodeInfo
@interface LineNodeInfo : NSObject
{
    NSString    *x;
    NSString    *y;

    
}

@property (nonatomic, retain)NSString    *x;
@property (nonatomic, retain)NSString    *y;

@end
