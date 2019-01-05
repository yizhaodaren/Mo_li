//
//  JALabelSelectViewController.h
//  Jasmine
//
//  Created by xujin on 2018/5/28.
//  Copyright © 2018 xujin. All rights reserved.
//
/*
    展示逻辑：APP第一次启动时，弹出该页面,以后不再弹出（删除APP后会再次弹出）
    1、登录：不需要特殊处理
    2、游客：保存标签后，去调用登录接口时，根据返回数据中isLabel(0没有添加标签  1已经添加标签)
    字段，来判断是否调用标签同步接口
 */

#import "JABaseViewController.h"

@interface JALabelSelectViewController : JABaseViewController

@end
