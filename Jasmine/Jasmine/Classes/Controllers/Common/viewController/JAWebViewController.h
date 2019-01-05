//
//  JAWebViewController.h
//  Jasmine
//
//  Created by xujin on 02/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseViewController.h"

typedef NS_ENUM(NSUInteger, JAActivityEnterType) {
    JAActivityEnterTypeHomeBanner,   //  首页banner
    JAActivityEnterTypeActivetyCenter,   //  活动中心
    JAActivityEnterTypeOfficMessage,   //  官方私信
    JAActivityEnterTypeHomeFloat,    //  首页弹窗
    JAActivityEnterTypePush,    //  推送
    JAActivityEnterTypePackBanner,   //  邀请页面banner,
    JAActivityEnterTypeLaunchAD    //  开屏广告
};

@interface JAWebViewController : JABaseViewController

@property (nonatomic, assign) NSString *enterType;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *titleString;

@property (nonatomic, assign) NSInteger fromType;  // 页面来源  0 其他 1 帮助中心
@end
