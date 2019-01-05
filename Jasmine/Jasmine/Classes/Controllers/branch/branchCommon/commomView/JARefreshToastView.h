//
//  JARefreshToastView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/1/26.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JARefreshToastView : UIView

/*
    1 关注    更新了xx条新内容
    2 推荐    为你推荐了xx条新内容
    3 发现    为你推荐了xx条新内容
    4 最新    更新了xx条新内容
 */
- (void)refreshContentWithCount:(NSInteger)count type:(NSInteger)typeChannel;

@end
