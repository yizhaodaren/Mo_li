//
//  JAPersonalReplyCell.h
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/19.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAPersonalReplyCell,JANewCommentModel;
@interface JAPersonalReplyCell : UITableViewCell
@property (nonatomic, strong) JANewCommentModel *model;

@property (nonatomic, strong) void(^jumpPersonalCenterBlock)(JAPersonalReplyCell *cell);
@property (nonatomic, strong) void(^playCommentOrReplyBlock)(JAPersonalReplyCell *cell);
@property (nonatomic, strong) void(^jumpReplyPersonalViewControlBlock)(JAPersonalReplyCell *cell);  // 评论界面 底部回复者姓名（暂未用）

// 2.4.1
@property (nonatomic, strong) void(^personalPointClickBlock)(JAPersonalReplyCell *cell);  // 三个点按钮

@property (nonatomic, copy) void(^commentAtPersonBlock)(NSString *userName, NSArray *atList);
@end
