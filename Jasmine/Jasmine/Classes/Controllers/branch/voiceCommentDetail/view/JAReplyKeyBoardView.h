//
//  JAReplyKeyBoardView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/24.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAEmitterView.h"

@interface JAReplyKeyBoardView : UIView

@property (nonatomic, assign) NSInteger type;  // 0 评论  1 回复中

@property (nonatomic, weak) UIButton *recordButton;
@property (nonatomic, weak) UIButton *textButton;
@property (nonatomic, weak) JAEmitterView *likeButton;  // 点赞按钮
@property (nonatomic, weak) UIButton *shareButton;  // 分享按钮
@end
