//
//  JACheckCommentCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/25.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JACheckCommentCell : UICollectionViewCell

@property (nonatomic, strong) JAVoiceCommentModel *commentModel;

// 可点击事件
@property (nonatomic, strong) void(^admin_jumpPersonalCenterBlock)(JACheckCommentCell *cell);
@property (nonatomic, strong) void(^admin_playCommentOrReplyBlock)(JACheckCommentCell *cell);
@property (nonatomic, strong) void(^admin_jumpReplyPersonalViewControlBlock)(JACheckCommentCell *cell);  // 评论界面 底部回复者姓名（暂未用）

// 2.4.1
@property (nonatomic, strong) void(^admin_personalPointClickBlock)(JACheckCommentCell *cell);  // 三个点按钮
@end
