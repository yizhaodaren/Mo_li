//
//  JACheckPostsCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/25.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JANewVoiceWaveView;
@interface JACheckPostsCell : UICollectionViewCell
@property (nonatomic, strong) JAVoiceModel *data;
@property (nonatomic, copy) void(^headActionBlock)(JACheckPostsCell *headV); // 头像姓名点击  个人中心
@property (nonatomic, copy) void(^deleteVoiceBlock)(JACheckPostsCell *headV);    // 删除帖子
@property (nonatomic, copy) void(^playBlock)(JACheckPostsCell *headV);      // 播放故事
@property (nonatomic, copy) void(^commentBlock)(JACheckPostsCell *headV);   // 评论

@property (nonatomic, strong) JANewVoiceWaveView *voiceWaveView;


@end
