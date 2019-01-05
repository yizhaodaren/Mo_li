//
//  JABottomShareView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/3/14.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JABottomShareViewType) {
    JABottomShareViewTypeOneLine,
    JABottomShareViewTypeTwoLine,
    JABottomShareViewTypeThreeLine,
};

typedef NS_ENUM(NSUInteger, JABottomShareOneContentType) {
    JABottomShareOneContentTypeNormal,  // 默认(有几行展示几行所有的图标)
    JABottomShareOneContentTypeCustom_one,  // 特殊定制一   只有微信（好友，朋友圈）
    JABottomShareOneContentTypeCustom_two,  // 特殊定制一   只有微信（好友，朋友圈,QQ,微博）
};

typedef NS_ENUM(NSUInteger, JABottomShareTwoContentType) {
    JABottomShareTwoContentTypeNormal,  // 默认(有几行展示几行所有的图标)
    JABottomShareTwoContentTypeCustom_one,  // 特殊定制一  （收藏、删除）
    JABottomShareTwoContentTypeCustom_two,  // 特殊定制二,     （收藏、举报）
};


typedef NS_ENUM(NSUInteger, JABottomShareClickType) {
    JABottomShareClickTypeWX,
    JABottomShareClickTypeWXSession,
    JABottomShareClickTypeQQ,
    JABottomShareClickTypeQQZone,
    JABottomShareClickTypeWB,
    JABottomShareClickTypeCollect,
    JABottomShareClickTypeReport,
    JABottomShareClickTypeDelete,
};

@interface JABottomShareView : UIView

- (instancetype)initWithShareType:(JABottomShareViewType)type
                      contentType:(JABottomShareOneContentType)oneType
                   twoContentType:(JABottomShareTwoContentType)TwoType;


- (void)showBottomShareView;
//- (void)hiddenBottomShareView;

@property (nonatomic, strong) void (^bottomShareClickButton)(JABottomShareClickType clickType,BOOL select,UIButton *button);

@end
