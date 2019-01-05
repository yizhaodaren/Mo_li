//
//  JAPersonBlankCell.h
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/5.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPersonBlankCell : UITableViewCell
@property (nonatomic, strong) NSString *userId; // 用户的id
@property (nonatomic, strong) NSString *sex;    // 个人中心cell 用
@property (nonatomic, assign) NSInteger type;  // 1 主帖 2 评论 3 收藏
@property (nonatomic, strong) void(^goToPublishVoice)();  // 去发帖

@property (nonatomic, strong) NSString *topicNoDataName;  // 话题cell用

@property (nonatomic, assign) NSInteger requestStatus; // 评论详情cell用
@property (nonatomic, strong) void(^requestAginBlock)();

@end
