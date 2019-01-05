//
//  JANoobPageView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/10/27.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JANoobPageType) {
    JANoobPageTypePersonCenter = 0, // 新手引导 - 左上角的个人中心   JANoobHomeKey
    JANoobPageTypePostsVoice,  // 新手引导 - 发布帖子
    JANoobPageTypeAgreeVoice,  // 新手引导 - 点赞帖子
    
    JANoobPageTypePersonTask,  // 新手引导 - 赚钱任务           JANoobPersonKey
    JANoobPageTypeHelpCenter,  // 新手引导 - 帮助中心
    JANoobPageTypePersonPage,  // 新手引导 - 个人主页
    
    JANoobPageTypePersonLevel,  // 新手引导 - 个人等级          JANoobLevelKey
};

@interface JANoobPageView : UIView
- (void)converLocation:(NSPointerArray *)viewArray rectView:(NSPointerArray *)rectViewArray images:(NSArray <NSString *> *)imagesArray type:(NSArray *)typeArray;

- (void)showNoob;
@end
