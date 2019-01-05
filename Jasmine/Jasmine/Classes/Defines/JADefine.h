//
//  JADefine.h
//  Jasmine
//
//  Created by xujin on 4/14/17.
//  Copyright © 2017 xujin. All rights reserved.
//

#ifndef JADefine_h
#define JADefine_h

// 日志
#ifdef DEBUG

#define NSLog(...) NSLog(__VA_ARGS__)

#else

#define NSLog(...)

#endif

// 平台
#define JA_PLATFORM @"iOS"
// 渠道
#define JA_CHANNEL @"App Store"
// 是否是管理员权限 大V
#define JAPOWER 1  // 管理员
#define JAVPOWER 2  // 大V

// 第三方appkey和appid
#define JA_Tencent_APPID @"101409108"
#define JA_WEIBO_APPID @"3032181475"
#define JA_WECHAT_APPID @"wx7c1df1136554af6a"
#define JA_JPUSH_APPKEY @"edbf38f7dc8a1feffd11c7f1"
#define JA_UMENT_ANALYTICS_APPKEY @"591d4499f5ade425a3000d89"
#define JA_QY_APPID @"0e22db86fb2def0d8d524729704e0eb7"
#define JA_YX_APPKEY @"f5fe4acc05208974ed1225c3efe973f3"
//#define JA_YX_APPKEY_TEST @"e42eb7a7666e19f63fc76676dacbdc49"
#define JA_YX_APPKEY_TEST @"bb9d1dc22f03836c7e5195dc132bbfc9"

//    498be1d8870b2924fee9cde1570cb727
//    c2aed04e605c5367788ed142fd6f708f
//    e51b90053bb7d5fd698137ce888fade2
//    3d498b863537665010e891d714d6958f

// 是否登录
#define IS_LOGIN [[NSUserDefaults standardUserDefaults] boolForKey:User_LoginState]
#define RELEASE_SAFELY(_obj) do { [_obj release]; _obj = nil; } while (0)

//
#define dispatch_async_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

// 当前的网络通畅
#define JA_NETWORK_REACHABLE ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)


//计算高度百分比（以iPhone6为基准）
#define kEstimateHeight(height)  (height/667.0f) * JA_SCREEN_HEIGHT
//计算宽度百分比（以iPhone6为基准）
#define kEstimateWidth(width)   (width/375.0f) * JA_SCREEN_WIDTH

#define JA_SCREEN_SCALE      ([UIScreen mainScreen].scale)
// 1px线条
#define JA_SCREEN_ONE_PIEXL (1.f/JA_SCREEN_SCALE)
// 标准间距
#define JA_PADDING 12
// 屏幕宽
#define JA_SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
// 屏幕高
#define JA_SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
// 宽高适配
#define WIDTH_ADAPTER(w) lrintf(1.0*JA_SCREEN_WIDTH/375.0f*(w))
#define HEIGHT_ADAPTER(h) lrintf(1.0*JA_SCREEN_HEIGHT/375.0f*(h))
#define FONT_ADAPTER(s) lrintf(1.0*JA_SCREEN_WIDTH/375.0f*(s))
// 状态栏高度
#define JA_STATUSBAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height

// Status bar height.
#define  JA_StatusBarHeight      (iPhoneX ? 44.f : 20.f)
// Navigation bar height.
#define  JA_NavigationBarHeight  44.f
// Navigation bar safe top margin.
#define  JA_NavBarSafeTopMargin         (iPhoneX ? 24.f : 0.f)
// Status bar & navigation bar height.
#define  JA_StatusBarAndNavigationBarHeight  (iPhoneX ? 88.f : 64.f)

// Tabbar height.
#define  JA_TabbarHeight         (iPhoneX ? (49.f+34.f) : 49.f)
// Tabbar safe bottom margin.
#define  JA_TabbarSafeBottomMargin         (iPhoneX ? 34.f : 0.f)

// 系统版本
#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define IOS10 (SYSTEM_VERSION >= 10.0)?YES:NO
#define IOS9 (SYSTEM_VERSION >= 9.0)?YES:NO
#define IOS8 (SYSTEM_VERSION >= 8.0)?YES:NO
#define IOS7 (SYSTEM_VERSION >= 7.0)?YES:NO
#define IOS6 (SYSTEM_VERSION >= 6.0)?YES:NO

// file path
#define PATH_FILENAME(name) [[NSBundle mainBundle] pathForResource:(name.length > 4 && [[name substringWithRange:NSMakeRange(name.length-4, 4)] isEqualToString:@".png"]) ? ((name.length > 7 && [[name substringWithRange:NSMakeRange(name.length-7, 3)] isEqualToString:@"@2x"]) ? [name substringWithRange:NSMakeRange(0, name.length-4)] : ([NSString stringWithFormat:@"%@@2x",[name substringWithRange:NSMakeRange(0, name.length-4)]])) : ((name.length > 3 && [[name substringWithRange:NSMakeRange(name.length-3, 3)] isEqualToString:@"@2x"]) ? name : ([NSString stringWithFormat:@"%@@2x",name])) ofType:@"png"]


// 设备类型
#define iPhoneX   ((JA_SCREEN_HEIGHT==812)?YES:NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iTouch ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6Plus ((JA_SCREEN_WIDTH==414)?YES:NO)
#define iPhone6   ((JA_SCREEN_WIDTH==375)?YES:NO)
#define iPhone320 ((JA_SCREEN_WIDTH==320)?YES:NO)
#define iPhone4 ((JA_SCREEN_HEIGHT==480)?YES:NO)

// ViewController正常界面的布局位置
#define BEGIN_Y   ((SYSTEM_VERSION >= 7.0)?64:44)


//字体
#define JA_LIGHT_FONT(size) [UIFont ja_systemFontOfSize:size weight:UIFontWeightLight]
#define JA_REGULAR_FONT(size) [UIFont ja_systemFontOfSize:size weight:UIFontWeightRegular]
#define JA_MEDIUM_FONT(size) [UIFont ja_systemFontOfSize:size weight:UIFontWeightMedium]

#define TB_10_FONT  [UIFont boldSystemFontOfSize:10]
#define TB_11_FONT  [UIFont boldSystemFontOfSize:11]
#define TB_12_FONT  [UIFont boldSystemFontOfSize:12]
#define TB_14_FONT  [UIFont boldSystemFontOfSize:14]
#define TB_16_FONT  [UIFont boldSystemFontOfSize:16]
#define TB_17_FONT  [UIFont boldSystemFontOfSize:17]
#define TB_18_FONT  [UIFont boldSystemFontOfSize:18]
#define TB_19_FONT  [UIFont boldSystemFontOfSize:19]
#define TB_20_FONT  [UIFont boldSystemFontOfSize:20]
#define TB_24_FONT  [UIFont boldSystemFontOfSize:24]

#define T8_FONT     [UIFont systemFontOfSize:8]
#define T10_FONT    [UIFont systemFontOfSize:10]
#define T11_FONT    [UIFont systemFontOfSize:11]
#define T12_FONT    [UIFont systemFontOfSize:12]
#define T13_FONT    [UIFont systemFontOfSize:13]
#define T14_FONT    [UIFont systemFontOfSize:14]
#define T15_FONT    [UIFont systemFontOfSize:15]
#define T16_FONT    [UIFont systemFontOfSize:16]
#define T17_FONT    [UIFont systemFontOfSize:17]
#define T18_FONT    [UIFont systemFontOfSize:18]
#define T20_FONT    [UIFont systemFontOfSize:20]
#define T24_FONT    [UIFont systemFontOfSize:24]
#define T25_FONT    [UIFont systemFontOfSize:25]
#define T30_FONT    [UIFont systemFontOfSize:30]
#define T35_FONT    [UIFont systemFontOfSize:35]
#define T_FONT(f)   [UIFont systemFontOfSize:(FONT_ADAPTER(f))]

#define JA_FONT(size)    [UIFont systemFontOfSize:size]
#define JA_THIN_FONT(size) [UIFont systemFontOfSize:size weight:UIFontWeightThin]

#define APPName [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]

#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#endif /* JADefine_h */
