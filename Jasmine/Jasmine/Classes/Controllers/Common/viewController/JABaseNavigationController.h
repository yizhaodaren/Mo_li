//
//  JABaseNavigationController.h
//  Jasmine
//
//  Created by xujin on 4/14/17.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JABaseNavigationController : UINavigationController

/**
 *  通知tabBarViewController内容视图滚动了
 *  此方法会根据ScrollView滚动的距离,做出一些响应
 *
 *  @param scrollView 滚动的Scrollview
 */
-(void)scrollViewDidScroll:(UIScrollView*)scrollView;


/**
 *  配置Tabbar是否隐藏
 *
 */
- (void)setTabbarHidden:(BOOL)hidden;

/**
 * 配置navigation bar 背景图片 设置线是否隐藏
 */
- (void)setNavigationBarLineHidden:(BOOL)hidden;

@end
