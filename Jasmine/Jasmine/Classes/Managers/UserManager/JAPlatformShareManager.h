//
//  JAPlatformShareManager.h
//  Jasmine
//
//  Created by moli-2017 on 2017/6/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, platformShareType) {
    platformShareTypeContent,
    platformShareTypePacket
};

@interface JAShareModel : NSObject

/// 分享的标题
@property (nonatomic, strong) NSString *title;

/// 分享的url
@property (nonatomic, strong) NSString *shareUrl;

/// 分享的描述
@property (nonatomic, strong) NSString *descripe;

/// 分享的图片
@property (nonatomic, strong) NSString *image;

/// 分享的类型
@property (nonatomic, assign) platformShareType shareType;  // 暂时没用

///  2.5.2 小程序
@property (nonatomic, strong) NSString *miniProgramId; // 小程序原始id
@property (nonatomic, strong) NSString *miniProgramPath; // 小程序路径

/// 分享的音乐
@property (nonatomic, strong) NSString *music;

@end

typedef NS_ENUM(NSInteger, QQShareType) {
    QQShareTypeFriend = 0,
    QQShareTypeZone
};

typedef NS_ENUM(NSUInteger, WeiXinShareType) {
    /// 朋友
    WeiXinShareTypeTimeline,
    /// 朋友圈
    WeiXinShareTypeSession     
};

typedef NS_ENUM(NSUInteger, WeiXinMediaObjectType) {
    WeiXinMediaObjectTypeImage,
    WeiXinMediaObjectTypeMusic,
    WeiXinMediaObjectTypeVideo,
    WeiXinMediaObjectTypeWebpage
};

@interface JAPlatformShareManager : NSObject

/// QQ分享
+ (void)qqShare:(QQShareType)type shareContent:(JAShareModel *)model domainType:(NSInteger)domainType;

/// 微信分享
+ (void)wxShare:(WeiXinShareType)type shareContent:(JAShareModel *)model domainType:(NSInteger)domainType;

/// 微博分型
+ (void)wbShareWithshareContent:(JAShareModel *)model domainType:(NSInteger)domainType;

/// 双倍分享图片 - 微信分享图片
+ (void)wxShare:(WeiXinShareType)type shareImage:(UIImage *)image;
// qq分享图片（晒收入）
+ (void)qqShare:(QQShareType)type shareImage:(UIImage *)image;
/// 微信分享图片(url)
+ (void)wxShare:(WeiXinShareType)type shareImageWithUrlString:(NSString *)imageString;

/// 分享小程序
+ (void)wxShareMiniProgram:(WeiXinShareType)type shareContent:(JAShareModel *)model domainType:(NSInteger)domainType;

/***************************************web网页分享图片***********************************/
// 微信
+ (void)web_wxShareImage:(WeiXinShareType)type shareImage:(NSString *)imageStr imageType:(NSInteger)imageType title:(NSString *)title subTitle:(NSString *)subTitle;
// qq分享图片
+ (void)web_qqShareImage:(QQShareType)type shareImage:(NSString *)imageStr imageType:(NSInteger)imageType title:(NSString *)title subTitle:(NSString *)subTitle;
// 微博分享图片
+ (void)web_wbShareImageWithImage:(NSString *)imageStr imageType:(NSInteger)imageType title:(NSString *)title subTitle:(NSString *)subTitle;

/***************************************主帖以音乐形式分享***********************************/
/// QQ分享音乐
+ (void)qqShareMusic:(QQShareType)type shareContent:(JAShareModel *)model;
/// 微信分享音乐
+ (void)wxShareMusic:(WeiXinShareType)type shareContent:(JAShareModel *)model;
/// 微博分享音乐
+ (void)wbShareMusicWithshareContent:(JAShareModel *)model;

/***************************************web 分享音乐类型***********************************/
/// QQ分享音乐
+ (void)qqShareMusic:(QQShareType)type shareContent:(JAShareModel *)model domainType:(NSInteger)domainType;
/// 微信分享音乐
+ (void)wxShareMusic:(WeiXinShareType)type shareContent:(JAShareModel *)model domainType:(NSInteger)domainType;
@end
