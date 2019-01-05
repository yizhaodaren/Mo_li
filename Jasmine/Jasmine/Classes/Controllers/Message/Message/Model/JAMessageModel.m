//
//  JAMessageModel.m
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAMessageModel.h"

@interface JAMessageModel ()

@property (nonatomic, strong) NSMutableArray *messageArray;


@end

@implementation JAMessageModel

- (id)init
{
    self = [super init];
    if (self)
    {
        self.messageArray = [NSMutableArray arrayWithCapacity:3];
    }
    return self;
}

- (void)getMessage:(void(^)(void))success failure:(void(^)(void))error
{
//#if DEBUG
    
    // 官方
//    JAMessageData *officeData = [[JAMessageData alloc] init];
//    officeData.localImgName = @"kj_fenxiang";
//    officeData.name = @"官方";
//    officeData.message = @"欢迎来到茉莉";
//    officeData.msgID = 100;
//    [self.messageArray addObject:officeData];
//    
//    
//    // 客服
//    JAMessageData *seviceData = [[JAMessageData alloc] init];
//    seviceData.localImgName = @"qq_fenxiang";
//    seviceData.name = @"官方";
//    seviceData.message = @"Hi~我是茉莉官方客服";
//    seviceData.msgID = 101;
//    [self.messageArray addObject:seviceData];
//    
//    // 联系人
//    JAMessageData *contactData = [[JAMessageData alloc] init];
//    contactData.isContacts = YES;
//    contactData.msgID = 102;
//    [self.messageArray addObject:contactData];
    

    // 消息
    JAMessageData *firstData = [[JAMessageData alloc] init];
    firstData.avatar = @"http://img.tupianzj.com/uploads/allimg/160821/9-160R1150K2.jpg";
    firstData.unreadCount = 5;
    firstData.timestamp = [NSDate date].timeIntervalSince1970;
    firstData.name = @"独家记忆";
    firstData.message = @"不要期待对方为你做质的改变";
    firstData.msgID = 103;
    [self.messageArray addObject:firstData];
    
    JAMessageData *secondData = [[JAMessageData alloc] init];
    secondData.avatar = @"http://img.tupianzj.com/uploads/allimg/160821/9-160R1150P1.jpg";
    secondData.unreadCount = 5;
    secondData.timestamp = [NSDate date].timeIntervalSince1970;
    secondData.name = @"进击的小学生";
    secondData.message = @"仪式感不强的人带你见了亲友不代表任何，不过这是一个很强烈的信号";
    secondData.msgID = 104;
    [self.messageArray addObject:secondData];
    
    JAMessageData *thirdData = [[JAMessageData alloc] init];
    thirdData.avatar = @"http://img.tupianzj.com/uploads/allimg/160821/9-160R1150T0.jpg";
    thirdData.unreadCount = 15;
    thirdData.timestamp = [NSDate date].timeIntervalSince1970;
    thirdData.name = @"福建莆田吴亦凡";
    thirdData.message = @"分手无情的人不要问他为什么";
    thirdData.msgID = 105;
    [self.messageArray addObject:thirdData];
    
    self.dataCount = self.messageArray.count;
    if (success)
    {
        success();
    }
    
    
//#endif
    
}

- (JAMessageData *)dataAtIndex:(NSInteger)index
{
    if (index < self.dataCount)
    {
        return self.messageArray[index];
    }
    return nil;
}

@end
