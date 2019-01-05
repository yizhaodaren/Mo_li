//
//  JAMessageData.h
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAMessageData : NSObject


// 查找联系人 ： 和其他任何字段互斥
@property (nonatomic, assign) BOOL isContacts;

// 本地图片
@property (nonatomic, strong) NSString *localImgName;

// 头像
@property (nonatomic, strong) NSString *avatar;

// 消息
@property (nonatomic, strong) NSString *message;


// 用户名
@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) NSUInteger unreadCount;

@property (nonatomic, assign) NSUInteger timestamp;

@property (nonatomic, assign) NSUInteger msgID;




@end
