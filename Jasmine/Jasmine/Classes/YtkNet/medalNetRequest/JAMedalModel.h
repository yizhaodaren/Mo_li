//
//  JAMedalModel.h
//  Jasmine
//
//  Created by 王树超 on 2018/7/14.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetBaseModel.h"
#import "JAMedalShareModel.h"
@interface JAMedalModel : JANetBaseModel


@property (nonatomic, strong) NSString *medalId;   //
@property (nonatomic, strong) NSString *medalType;     //
@property (nonatomic, strong) NSString *medalRank;   //
@property (nonatomic, strong) NSString *medalName;  //
@property (nonatomic, strong) NSString *conditionNum;  //
@property (nonatomic, strong) NSString *totalNum;
@property (nonatomic, strong) NSString *createTime;   //
@property (nonatomic, strong) NSString *updateTime;   //
@property (nonatomic, strong) NSString *getImgUrl;
@property (nonatomic, strong) NSString *unImgUrl;
@property (nonatomic, strong) NSString *status;   //0没有阅览 1已阅读  2佩戴中 3未获得
@property (nonatomic, strong) NSString *finishedNum;  //
@property (nonatomic, strong) NSString *nextConditionNum;
@property (nonatomic, strong) NSString *deleted;  //

@property (nonatomic, strong) JAMedalShareModel *shareMsgVO;  //

//{
//    "medalId": 6,//勋章id
//    "medalType": 2,//勋章类型 1连续登录  2邀请 3创作数量
//    "medalRank": 1,//勋章等级（暂时无用）
//    "medalName": "茉莉执事",//勋章名称
//    "conditionNum": 2,//获得勋章条件总数量
//    nextConditionNum;//下一级别获得勋章条件总数量
//    "totalNum": 2,//当前获得勋章的人数
//    "getImgUrl": "http://moli2017.oss-cn-zhangjiakou.aliyuncs.com//file/15064938682224f102cc5-9d74-46cf-b5aa-dc276ebd42ad.png",//获得勋章的展示图片
//    "unImgUrl": "http://moli2017.oss-cn-zhangjiakou.aliyuncs.com//file/15064937147847d358fee-3f88-4232-aec1-b3b814a37be9.png",//未获得勋章的展示图片
//    "status": 1,//勋章的当前状态  0获得未阅读   1获得阅读  2佩戴  3未获得
//    "finishedNum": 0,//已经完成的条件
//    "deleted": 0,
//    "createTime": 1531470670000,勋章获得时间
//    "updateTime": 1531900449000
//}

//排序
- (NSComparisonResult)compareParkInfo:(JAMedalModel *)parkinfo;
@end
