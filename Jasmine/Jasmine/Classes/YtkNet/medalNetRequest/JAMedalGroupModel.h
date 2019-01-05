//
//  JAMedalGroupModel.h
//  Jasmine
//
//  Created by 王树超 on 2018/7/14.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetBaseModel.h"
#import "JAMedalModel.h"
@interface JAMedalGroupModel : JANetBaseModel
@property (nonatomic, strong) NSArray *inviteList;
@property (nonatomic, strong) NSArray *dayList;
@property (nonatomic, strong) NSArray *storyList;
@property (nonatomic, assign) NSInteger medalNum;
@property (nonatomic,strong) NSString *storyMedalRemind;
@property (nonatomic, strong) JAMedalShareModel *shareMsgVO;  //
@end
